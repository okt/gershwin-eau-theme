// The purpose of this code is to draw command key equivalents in the menu using the Command key symbol

#import <AppKit/NSMenuItemCell.h>

@interface NSMenuItemCell (EauTheme)
- (void) EAUdrawKeyEquivalentWithFrame: (NSRect)cellFrame inView: (NSView*)controlView;
- (NSString*) EAUconvertKeyEquivalentToMacStyle: (NSString*)keyEquivalent withModifiers: (NSUInteger)modifierMask;
@end
