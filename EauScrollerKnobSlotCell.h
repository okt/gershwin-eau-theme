#import <AppKit/NSButtonCell.h>

@interface EauScrollerKnobSlotCell : NSButtonCell
{
  BOOL horizontal;
}
- (void) drawWithFrame: (NSRect)cellFrame inView: (NSView*)controlView;
@property(assign) BOOL horizontal;
@end
