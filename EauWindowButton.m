#import "EauWindowButton.h"
#import "EauWindowButtonCell.h"

@implementation EauWindowButton

+ (Class) cellClass
{
  return [EauWindowButtonCell class];
}
- (void) setBaseColor: (NSColor*)c
{
  [_cell setBaseColor: c];
}
- (BOOL) isFlipped
{
  return NO;
}

@end
