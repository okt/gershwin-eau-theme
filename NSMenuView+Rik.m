// NSMenuView+Rik.m
// Rik Theme NSMenuView Extensions

#import "Rik.h"
#import "NSMenuView+Rik.h"
#import <AppKit/NSMenuView.h>
#import <objc/runtime.h>

@implementation NSMenuView (RikTheme)

- (NSPoint)rik_locationForSubmenu:(NSMenu *)aSubmenu
{
  NSLog(@"NSMenuView+Rik: rik_locationForSubmenu: called for submenu %@", aSubmenu);

  NSMenuView *menuView = (NSMenuView *)self;

  // Call the original implementation - it correctly calculates Y position.
  // After swizzling, -rik_locationForSubmenu: points to the original
  // -locationForSubmenu: implementation.
  NSPoint originalPoint = [self rik_locationForSubmenu:aSubmenu];

  // If this menu view itself is horizontal (the menu bar), use original positioning entirely
  if ([menuView isHorizontal]) {
    NSLog(@"NSMenuView+Rik: Menu is horizontal, using original submenu position {%.1f, %.1f}",
          originalPoint.x, originalPoint.y);
    return originalPoint;
  }

  // For vertical dropdown menus, adjust only the X position to remove overlap
  // Keep the original Y position which correctly aligns with the parent item
  NSWindow *window = [menuView window];
  if (!window) {
    NSLog(@"NSMenuView+Rik: No window for menu view, using original submenu position {%.1f, %.1f}",
          originalPoint.x, originalPoint.y);
    return originalPoint;
  }

  NSRect frame = [window frame];

  // X position: right edge of parent menu window (just touching, no overlap)
  CGFloat xPos = NSMaxX(frame);

  // Y position: use the original calculation which correctly handles item position
  CGFloat yPos = originalPoint.y;

  NSLog(@"NSMenuView+Rik: Adjusted submenu position from {%.1f, %.1f} to {%.1f, %.1f}",
        originalPoint.x, originalPoint.y, xPos, yPos);

  return NSMakePoint(xPos, yPos);
}

@end

// This function runs when the bundle is loaded
__attribute__((constructor))
static void initMenuViewSwizzling(void) {
  NSLog(@"NSMenuView+Rik: Constructor called - setting up swizzling");

  Class menuViewClass = objc_getClass("NSMenuView");
  if (!menuViewClass) {
    NSLog(@"NSMenuView+Rik: ERROR - NSMenuView class not found");
    return;
  }

  // Swizzle locationForSubmenu: with rik_locationForSubmenu:
  SEL originalSelector = sel_registerName("locationForSubmenu:");
  SEL swizzledSelector = @selector(rik_locationForSubmenu:);

  Method originalMethod = class_getInstanceMethod(menuViewClass, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(menuViewClass, swizzledSelector);

  if (!originalMethod) {
    NSLog(@"NSMenuView+Rik: ERROR - Could not find original locationForSubmenu: method");
    return;
  }

  if (!swizzledMethod) {
    NSLog(@"NSMenuView+Rik: ERROR - Could not find rik_locationForSubmenu: method on NSMenuView");
    return;
  }

  // Avoid double-swizzling: if the IMPs are already the same, do nothing.
  IMP originalIMP = method_getImplementation(originalMethod);
  IMP swizzledIMP = method_getImplementation(swizzledMethod);
  if (originalIMP == swizzledIMP) {
    NSLog(@"NSMenuView+Rik: Swizzling skipped - implementations already identical");
    return;
  }

  method_exchangeImplementations(originalMethod, swizzledMethod);
  NSLog(@"NSMenuView+Rik: Successfully swizzled locationForSubmenu: with rik_locationForSubmenu:");
}
