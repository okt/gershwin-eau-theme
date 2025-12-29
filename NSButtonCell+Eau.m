/*
 * NSButtonCell+Eau.m
 * Eau Theme - Button Cell Enhancements
 *
 * This file uses the method swizzling pattern for NSButtonCell to:
 * 1. Intercept common_ret/common_retH images and hide them
 * 2. Automatically set buttons with these images as default buttons
 * 3. Enable pulsing animation for default buttons
 * 4. Make default buttons appear selected with highlighted border
 * 5. Ensure crash-safe operation even when windows/buttons cannot be found
 * While 2, 3, and 4 could be done by the application,
 * most applications will not do this, so we handle it here. 
 */

#import "NSCell+Eau.h"
#import "Eau+Button.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSButtonCell(EauTheme)
- (NSImage *) EAUimage;
- (NSImage *) EAUalternateImage;
- (BOOL) isProcessingReturnButton;
- (void) setIsProcessingReturnButton:(BOOL)processing;
- (void) safelyMakeButtonSelectedAndHighlighted;
@end

@implementation Eau(NSButtonCell)
// Override image method using GSTheme method swizzling pattern
- (NSImage *) _overrideNSButtonCellMethod_image
{
  NSButtonCell *xself = (NSButtonCell*) self;
  return [xself EAUimage];
}

// Override alternateImage method using GSTheme method swizzling pattern
- (NSImage *) _overrideNSButtonCellMethod_alternateImage
{
  NSButtonCell *xself = (NSButtonCell*) self;
  return [xself EAUalternateImage];
}
@end

@implementation NSButtonCell(EauTheme)

// Prevent infinite recursion during image processing
static NSMutableSet *processingCells = nil;
static NSMutableSet *defaultButtonSetCells = nil;

+ (void)load
{
  processingCells = [[NSMutableSet alloc] init];
  defaultButtonSetCells = [[NSMutableSet alloc] init];
}

// Helper methods to track processing state
- (BOOL) isProcessingReturnButton
{
  @synchronized(processingCells) {
    return [processingCells containsObject:[NSValue valueWithPointer:self]];
  }
}

- (void) setIsProcessingReturnButton:(BOOL)processing
{
  @synchronized(processingCells) {
    NSValue *cellPtr = [NSValue valueWithPointer:self];
    if (processing) {
      [processingCells addObject:cellPtr];
    } else {
      [processingCells removeObject:cellPtr];
    }
  }
}

// Handle common_ret/common_retH images: hide them and enable button pulsing
- (NSImage *) EAUimage
{
  NSImage *originalImage = [super image];
  if (originalImage)
    {
      NSString *imageName = [originalImage name];
      
      if (imageName && ([imageName isEqualToString:@"common_ret"] || 
                       [imageName isEqualToString:@"common_retH"]))
        {
          // Prevent infinite loops
          if (![self isProcessingReturnButton]) {
            [self setIsProcessingReturnButton:YES];
            [self setIsDefaultButton:@YES];
            [self enablePulsing];
            [self setIsProcessingReturnButton:NO];
          }
          
          return nil; // Hide the image
        }
    }
  
  return originalImage;
}

// Intercept setImage to handle common_ret/common_retH images
- (void) setImage:(NSImage *)image
{
  if (image) {
    NSString *imageName = [image name];
    
    if (imageName && ([imageName isEqualToString:@"common_ret"] || 
                     [imageName isEqualToString:@"common_retH"])) {
      
      // Prevent infinite loops
      if (![self isProcessingReturnButton]) {
        [self setIsProcessingReturnButton:YES];
        [self setIsDefaultButton:@YES];
        [self setIsProcessingReturnButton:NO];
        [self enablePulsing];
      }
      
      return; // Don't set the image
    }
  }
  
  [super setImage:image];
}

// Handle common_ret/common_retH alternate images
- (NSImage *) EAUalternateImage
{
  NSImage *originalImage = nil;

  if ([self respondsToSelector:@selector(alternateImage)]) {
    originalImage = ((NSButtonCell *)self).alternateImage;
  }

  if (originalImage)
    {
      NSString *imageName = [originalImage name];
      
      if (imageName && ([imageName isEqualToString:@"common_ret"] || 
                       [imageName isEqualToString:@"common_retH"]))
        {
          // Prevent infinite loops
          if (![self isProcessingReturnButton]) {
            [self setIsProcessingReturnButton:YES];
            [self setIsDefaultButton:@YES];
            [self enablePulsing];
            [self setIsProcessingReturnButton:NO];
          }
          
          return nil; // Hide the image
        }
    }
  
  return originalImage;
}

// Intercept setAlternateImage to handle common_ret/common_retH images
- (void) EAU_setAlternateImage:(NSImage *)alternateImage
{
  if (alternateImage) {
    NSString *imageName = [alternateImage name];
    
    if (imageName && ([imageName isEqualToString:@"common_ret"] || 
                     [imageName isEqualToString:@"common_retH"])) {
      // Prevent infinite loops
      if (![self isProcessingReturnButton]) {
        [self setIsProcessingReturnButton:YES];
        [self setIsDefaultButton:@YES];
        [self setIsProcessingReturnButton:NO];
        [self enablePulsing];
      }
      
      return; // Don't set the image
    }
  }
  if ([self respondsToSelector:@selector(setAlternateImage:)]) {
    [(NSButtonCell *)self setAlternateImage:alternateImage];
  }
}

// Enable pulsing animation for default buttons and make them selected
- (void) enablePulsing
{
  EAULOG(@"NSButtonCell+Eau: enablePulsing called for button cell %p", self);
  
  @try {
    // Prevent multiple enablePulsing calls for the same cell
    @synchronized(defaultButtonSetCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      if ([defaultButtonSetCells containsObject:cellPtr]) {
        EAULOG(@"NSButtonCell+Eau: Button cell %p already enabled for pulsing, skipping", self);
        return;
      }
    }
    
    EAULOG(@"NSButtonCell+Eau: Setting button cell %p as default button", self);
    [self setIsDefaultButton:@YES];
    
    EAULOG(@"NSButtonCell+Eau: Making button cell %p selected and highlighted", self);
    [self safelyMakeButtonSelectedAndHighlighted];
    
    EAULOG(@"NSButtonCell+Eau: Starting strategy to set default button for cell %p", self);
    [self trySetAsDefaultButtonWithStrategy];
    
    EAULOG(@"NSButtonCell+Eau: enablePulsing completed successfully for button cell %p", self);
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in enablePulsing for button cell %p: %@", self, exception);
  }
}

// Try multiple strategies to find the window and set default button
- (void) trySetAsDefaultButtonWithStrategy
{
  EAULOG(@"NSButtonCell+Eau: trySetAsDefaultButtonWithStrategy called for button cell %p", self);
  
  @try {
    // Prevent multiple attempts for the same cell
    @synchronized(defaultButtonSetCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      if ([defaultButtonSetCells containsObject:cellPtr]) {
        EAULOG(@"NSButtonCell+Eau: Button cell %p already processed, skipping", self);
        return;
      }
    }
    
    // Try immediate window access
    EAULOG(@"NSButtonCell+Eau: Trying direct window access for button cell %p", self);
    if ([self tryDirectWindowAccess]) {
      EAULOG(@"NSButtonCell+Eau: Direct window access succeeded for button cell %p", self);
      return;
    }
    
    // Search all windows for this button cell
    EAULOG(@"NSButtonCell+Eau: Trying to search all windows for button cell %p", self);
    if ([self trySearchAllWindows]) {
      EAULOG(@"NSButtonCell+Eau: Window search succeeded for button cell %p", self);
      return;
    }
    
    // Only schedule ONE delayed attempt to prevent loops
    EAULOG(@"NSButtonCell+Eau: Scheduling single delayed attempt for button cell %p", self);
    @try {
      [self performSelector:@selector(finalAttemptSetAsDefaultButton) withObject:nil afterDelay:1.0];
    }
    @catch (NSException *performException) {
      EAULOG(@"NSButtonCell+Eau: ERROR scheduling delayed attempt for cell %p: %@", self, performException);
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in trySetAsDefaultButtonWithStrategy for cell %p: %@", self, exception);
  }
}

// Final attempt to set as default button (only called once)
- (void) finalAttemptSetAsDefaultButton
{
  EAULOG(@"NSButtonCell+Eau: finalAttemptSetAsDefaultButton called for button cell %p", self);
  
  @try {
    // Check if already processed
    @synchronized(defaultButtonSetCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      if ([defaultButtonSetCells containsObject:cellPtr]) {
        EAULOG(@"NSButtonCell+Eau: Button cell %p already processed in final attempt", self);
        return;
      }
    }
    
    // Try one more time with direct access
    if ([self tryDirectWindowAccess]) {
      EAULOG(@"NSButtonCell+Eau: Final direct window access succeeded for button cell %p", self);
      return;
    }
    
    // Try one more time with window search
    if ([self trySearchAllWindows]) {
      EAULOG(@"NSButtonCell+Eau: Final window search succeeded for button cell %p", self);
      return;
    }
    
    EAULOG(@"NSButtonCell+Eau: Final attempt failed for button cell %p - giving up", self);
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in finalAttemptSetAsDefaultButton for cell %p: %@", self, exception);
  }
}

// Strategy 1: Try direct window access through controlView
- (BOOL) tryDirectWindowAccess
{
  EAULOG(@"NSButtonCell+Eau: tryDirectWindowAccess called for button cell %p", self);
  
  @try {
    NSView *controlView = nil;
    if ([self respondsToSelector:@selector(controlView)]) {
      controlView = [self controlView];
      EAULOG(@"NSButtonCell+Eau: Found control view %p for button cell %p", controlView, self);
    }
    
    NSWindow *window = nil;
    
    if (controlView) {
      @try {
        window = [controlView window];
        EAULOG(@"NSButtonCell+Eau: Found window %p for control view %p", window, controlView);
      }
      @catch (NSException *windowException) {
        EAULOG(@"NSButtonCell+Eau: ERROR getting window from control view %p: %@", controlView, windowException);
      }
      
      if (!window) {
        // Try to find window by traversing the view hierarchy
        EAULOG(@"NSButtonCell+Eau: Traversing view hierarchy to find window for control view %p", controlView);
        NSView *currentView = controlView;
        while (currentView && !window) {
          @try {
            currentView = [currentView superview];
            if (currentView) {
              window = [currentView window];
              if (window) {
                EAULOG(@"NSButtonCell+Eau: Found window %p through view hierarchy traversal", window);
              }
            }
          }
          @catch (NSException *hierarchyException) {
            EAULOG(@"NSButtonCell+Eau: ERROR traversing view hierarchy: %@", hierarchyException);
            break;
          }
        }
      }
      
      if (window) {
        @try {
          [self markAsDefaultButtonSet];
          EAULOG(@"NSButtonCell+Eau: Setting window %p default button cell to %p", window, self);
          [window setDefaultButtonCell:self];
          
          // Also make the button visually selected/highlighted
          [self safelyMakeButtonSelectedAndHighlighted];
          
          EAULOG(@"NSButtonCell+Eau: Successfully set default button cell for window %p", window);
          return YES;
        }
        @catch (NSException *setDefaultException) {
          EAULOG(@"NSButtonCell+Eau: ERROR setting default button cell for window %p: %@", window, setDefaultException);
        }
      } else {
        EAULOG(@"NSButtonCell+Eau: No window found for control view %p", controlView);
      }
    } else {
      EAULOG(@"NSButtonCell+Eau: No control view found for button cell %p", self);
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in tryDirectWindowAccess for cell %p: %@", self, exception);
  }
  
  return NO;
}

// Strategy 2: Search all windows for this button cell
- (BOOL) trySearchAllWindows
{
  EAULOG(@"NSButtonCell+Eau: trySearchAllWindows called for button cell %p", self);
  
  @try {
    NSArray *windows = nil;
    if ([NSApp respondsToSelector:@selector(windows)]) {
      windows = [NSApp windows];
      EAULOG(@"NSButtonCell+Eau: Found %lu windows to search", (unsigned long)[windows count]);
    } else {
      EAULOG(@"NSButtonCell+Eau: NSApp does not respond to windows selector");
      return NO;
    }
    
    for (NSWindow *candidateWindow in windows) {
      @try {
        EAULOG(@"NSButtonCell+Eau: Searching window %p for button cell %p", candidateWindow, self);
        if ([self findButtonWithCellInWindow:candidateWindow]) {
          EAULOG(@"NSButtonCell+Eau: Found button cell %p in window %p", self, candidateWindow);
          [self markAsDefaultButtonSet];
          [candidateWindow setDefaultButtonCell:self];
          
          // Also make the button visually selected/highlighted
          [self safelyMakeButtonSelectedAndHighlighted];
          
          EAULOG(@"NSButtonCell+Eau: Successfully set default button cell for window %p", candidateWindow);
          return YES;
        }
      }
      @catch (NSException *windowSearchException) {
        EAULOG(@"NSButtonCell+Eau: ERROR searching window %p: %@", candidateWindow, windowSearchException);
        continue;
      }
    }
    
    EAULOG(@"NSButtonCell+Eau: Button cell %p not found in any of %lu windows", self, (unsigned long)[windows count]);
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in trySearchAllWindows for cell %p: %@", self, exception);
  }
  
  return NO;
}

// Helper to mark this cell as having its default button set
- (void) markAsDefaultButtonSet
{
  @try {
    @synchronized(defaultButtonSetCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      [defaultButtonSetCells addObject:cellPtr];
      EAULOG(@"NSButtonCell+Eau: Marked button cell %p as default button set", self);
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR marking button cell %p as default: %@", self, exception);
  }
}

// Recursively search for a button that has this cell
- (BOOL) findButtonWithCellInWindow:(NSWindow *)window
{
  @try {
    NSView *contentView = [window contentView];
    if (contentView) {
      return [self findButtonWithCellInView:contentView];
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR finding button in window %p: %@", window, exception);
  }
  return NO;
}

- (BOOL) findButtonWithCellInView:(NSView *)view
{
  @try {
    if ([view isKindOfClass:[NSButton class]]) {
      NSButton *button = (NSButton*)view;
      if ([button cell] == self) {
        EAULOG(@"NSButtonCell+Eau: Found matching button %p for cell %p", button, self);
        return YES;
      }
    }
    
    // Recursively search subviews
    NSArray *subviews = [view subviews];
    if (subviews) {
      for (NSView *subview in subviews) {
        if ([self findButtonWithCellInView:subview]) {
          return YES;
        }
      }
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR searching view %p: %@", view, exception);
  }
  
  return NO;
}

// Safely make the button selected and highlighted with extensive error handling
- (void) safelyMakeButtonSelectedAndHighlighted
{
  EAULOG(@"NSButtonCell+Eau: safelyMakeButtonSelectedAndHighlighted called for button cell %p", self);
  
  @try {
    // DON'T set the cell as highlighted permanently - this interferes with pressed state detection
    // The default button appearance will come from the pulsing animation instead
    EAULOG(@"NSButtonCell+Eau: Skipping setHighlighted to allow proper pressed state detection");
    
    // DON'T set setShowsFirstResponder to avoid interfering with text field focus

  }
  @catch (NSException *cellException) {
    EAULOG(@"NSButtonCell+Eau: ERROR setting cell %p properties: %@", self, cellException);
  }
    
  // Try to get the control view safely
  NSView *controlView = nil;
  @try {
    if ([self respondsToSelector:@selector(controlView)]) {
      controlView = [self controlView];
      EAULOG(@"NSButtonCell+Eau: Found control view %p for button cell %p", controlView, self);
    } else {
      EAULOG(@"NSButtonCell+Eau: Button cell %p does not respond to controlView selector", self);
    }
    
    if (controlView && [controlView isKindOfClass:[NSButton class]]) {
      NSButton *button = (NSButton *)controlView;
      EAULOG(@"NSButtonCell+Eau: Control view is NSButton %p for cell %p", button, self);
      
      // Make the button highlighted with crash protection but without taking focus
      @try {

        
        // Set as key equivalent for Enter/Return key handling but don't take focus
        EAULOG(@"NSButtonCell+Eau: Setting button %p properties for Return key handling", button);
        
        // Try to set as key equivalent if possible
        if ([button respondsToSelector:@selector(setKeyEquivalent:)]) {
          EAULOG(@"NSButtonCell+Eau: Setting button %p key equivalent to return", button);
          [button setKeyEquivalent:@"\r"];
        }
        
        // DON'T force the button cell to be highlighted - this interferes with pressed state detection
        // The default button appearance will come from the pulsing animation instead
        EAULOG(@"NSButtonCell+Eau: Skipping setHighlighted to preserve pressed state detection");
        
        // Force the button to redraw to show changes
        EAULOG(@"NSButtonCell+Eau: Marking button %p as needing display", button);
        [button setNeedsDisplay:YES];
        
        // Make this button the first responder ONLY if the current first responder is already a button
        NSWindow *window = [button window];
        if (window) {
          NSResponder *currentFirstResponder = [window firstResponder];
          EAULOG(@"NSButtonCell+Eau: Current first responder: %p (class: %@)", currentFirstResponder, [currentFirstResponder class]);
          
          if (currentFirstResponder && [currentFirstResponder isKindOfClass:[NSButton class]]) {
            EAULOG(@"NSButtonCell+Eau: Current first responder is a button, making default button %p first responder", button);
            [window makeFirstResponder:button];
          } else {
            EAULOG(@"NSButtonCell+Eau: Current first responder is not a button (%@), preserving focus", [currentFirstResponder class]);
          }
        } else {
          EAULOG(@"NSButtonCell+Eau: No window found for button %p", button);
        }
        
        EAULOG(@"NSButtonCell+Eau: Successfully configured button %p with conditional focus", button);
      }
      @catch (NSException *buttonException) {
        EAULOG(@"NSButtonCell+Eau: ERROR setting button %p properties: %@", button, buttonException);
      }
    } else {
      EAULOG(@"NSButtonCell+Eau: Control view %p is not an NSButton or is nil for cell %p", controlView, self);
    }
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in safelyMakeButtonSelectedAndHighlighted for cell %p: %@", self, exception);
  }
}

// Clean up when the cell is deallocated
- (void) dealloc
{
  EAULOG(@"NSButtonCell+Eau: dealloc called for button cell %p", self);
  
  @try {
    // Cancel any pending operations
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // Remove from tracking sets
    @synchronized(processingCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      [processingCells removeObject:cellPtr];
    }
    
    @synchronized(defaultButtonSetCells) {
      NSValue *cellPtr = [NSValue valueWithPointer:self];
      [defaultButtonSetCells removeObject:cellPtr];
    }
    
    EAULOG(@"NSButtonCell+Eau: Cleanup completed for button cell %p", self);
  }
  @catch (NSException *exception) {
    EAULOG(@"NSButtonCell+Eau: ERROR in dealloc for cell %p: %@", self, exception);
  }
  
  [super dealloc];
}

@end