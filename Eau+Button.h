#import "Eau.h"
#include <AppKit/NSAnimation.h>

@interface Eau(EauButton)
{
}
@end


@interface NSButtonCell(EauDefaultButtonAnimation)
  @property (nonatomic, copy) NSNumber* isDefaultButton;
  @property (nonatomic, copy) NSNumber* pulseProgress;
@end
