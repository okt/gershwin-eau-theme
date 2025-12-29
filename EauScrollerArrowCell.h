#import <AppKit/NSButtonCell.h>

typedef enum {
  EauScrollerArrowLeft,
  EauScrollerArrowRight,
  EauScrollerArrowUp,
  EauScrollerArrowDown
} EauScrollerArrowType;

@interface EauScrollerArrowCell : NSButtonCell
{
  EauScrollerArrowType scroller_arrow_type;
}
-(void) setArrowType: (EauScrollerArrowType) t;
@end

