//
// NSAlert+Eau.h
//
// Comprehensive NSAlert customization for Eau theme.
// Provides a complete custom alert panel implementation.
//

#import <AppKit/AppKit.h>

@class EauAlertPanel;

// Category on NSAlert to hook into the alert system
@interface NSAlert (Eau)
@end

// Custom alert panel class for Eau theme
@interface EauAlertPanel : NSPanel
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
- (NSButton *) defaultButton;
- (BOOL) isActivePanel;

// Internal methods for GSAlertPanel swizzling (dynamically called)
- (id) eau_initWithoutGModelHelper;
- (NSInteger) eau_runModalHelper;
- (NSButton *) eau_getDefButton;

@end
