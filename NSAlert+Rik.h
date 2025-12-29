//
// NSAlert+Rik.h
//
// Comprehensive NSAlert customization for Rik theme.
// Provides a complete custom alert panel implementation.
//

#import <AppKit/AppKit.h>

@class RikAlertPanel;

// Category on NSAlert to hook into the alert system
@interface NSAlert (Rik)
@end

// Custom alert panel class for Rik theme
@interface RikAlertPanel : NSPanel
{
  NSButton      *defButton;
  NSButton      *altButton;
  NSButton      *othButton;
  NSButton      *icoButton;
  NSTextField   *titleField;
  NSTextField   *messageField;
  NSScrollView  *scroll;
  NSInteger     result;
  BOOL          isGreen;
}

- (id) initWithContentRect: (NSRect)rect;
- (NSInteger) runModal;
- (void) setTitleBar: (NSString *)titleBar
                icon: (NSImage *)icon
               title: (NSString *)title
             message: (NSString *)message;
- (void) setTitleBar: (NSString *)titleBar
                icon: (NSImage *)icon
               title: (NSString *)title
             message: (NSString *)message
                 def: (NSString *)defaultButton
                 alt: (NSString *)alternateButton
               other: (NSString *)otherButton;
- (void) setButtons: (NSArray *)buttons;
- (void) sizePanelToFit;
- (void) buttonAction: (id)sender;
- (NSInteger) result;
- (BOOL) isActivePanel;

// Internal method for GSAlertPanel swizzling (dynamically called)
- (id) rik_initWithoutGModel;
- (id) rik_initWithoutGModelHelper;

@end
