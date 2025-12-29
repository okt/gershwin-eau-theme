#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Eau(NSButtonCell)
- (NSImage *) _overrideNSButtonCellMethod_image;
- (NSImage *) _overrideNSButtonCellMethod_alternateImage;
@end

@interface NSButtonCell(EauTheme)
- (NSImage *) EAUimage;
- (NSImage *) EAUalternateImage;
- (void) safelyMakeButtonSelectedAndHighlighted;
@end
