#import "NSTableView+Eau.h"
#import <objc/runtime.h>

@implementation NSTableView (Eau)

+ (void) load
{
  // Exchange the initWithFrame: method to enable alternating row colors by default
  Method originalInit = class_getInstanceMethod([NSTableView class], @selector(initWithFrame:));
  Method eauInit = class_getInstanceMethod([NSTableView class], @selector(eau_initWithFrame:));
  
  if (originalInit && eauInit)
    {
      method_exchangeImplementations(originalInit, eauInit);
    }
}

- (id) eau_initWithFrame: (NSRect)frameRect
{
  // Call the original initialization
  self = [self eau_initWithFrame: frameRect];
  
  if (self)
    {
      // Enable alternating row background colors by default in Eau theme
      [self setUsesAlternatingRowBackgroundColors: YES];
    }
  
  return self;
}

@end
