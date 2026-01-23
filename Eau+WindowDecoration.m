#import "Eau.h"
#import "AppearanceMetrics.h"

@interface Eau(EauWindowDecoration)

@end


#define TITLE_HEIGHT 24.0
#define RESIZE_HEIGHT 9.0

@implementation Eau(EauWindowDecoration)

static NSDictionary *titleTextAttributes[3] = {nil, nil, nil};


- (float) resizebarHeight {
    return 0.0;  // No resize bar
}

- (float) titlebarHeight {
    return TITLE_HEIGHT;
}

- (void) drawWindowBackground: (NSRect) frame view: (NSView*) view
{

  NSColor* backgroundColor = [[view window] backgroundColor];

  NSBezierPath* backgroundPath = [NSBezierPath bezierPath];
  NSRect backgroundRect = frame;
  [backgroundPath appendBezierPathWithRect: backgroundRect];

  [backgroundColor setFill];

  [backgroundPath fill];
}

- (void) drawWindowBorder: (NSRect)rect
                withFrame: (NSRect)frame
             forStyleMask: (unsigned int)styleMask
                    state: (int)inputState
                 andTitle: (NSString*)title
{
  if (styleMask & (NSTitledWindowMask | NSClosableWindowMask
                  | NSMiniaturizableWindowMask))
    {
      NSRect titleRect;

      titleRect = NSMakeRect(0.0, frame.size.height - TITLE_HEIGHT,
                                frame.size.width, TITLE_HEIGHT);

      if (NSIntersectsRect(rect, titleRect))
        [self drawtitleRect: titleRect
              forStyleMask: styleMask
              state: inputState
              andTitle: title];

    }
}


- (void) drawtitleRect: (NSRect)titleRect
             forStyleMask: (unsigned int)styleMask
                    state: (int)inputState
                 andTitle: (NSString*)title
{

  if (!titleTextAttributes[0])
    {
      [self prepareTitleTextAttributes];
    }

  NSRect workRect;

  workRect = titleRect;
  workRect.origin.x -= 0.5;
  workRect.origin.y -= 0.5;
  [self drawTitleBarBackground:workRect];

  // Draw the title.
  if (styleMask & NSTitledWindowMask)
    {
      NSSize titleSize;
      if (styleMask & NSMiniaturizableWindowMask)
        {
          workRect.origin.x += 17;
          workRect.size.width -= 17;
        }
      if (styleMask & NSClosableWindowMask)
        {
          workRect.size.width -= 17;
        }
      titleSize = [title sizeWithAttributes: titleTextAttributes[inputState]];
      if (titleSize.width <= workRect.size.width)
        workRect.origin.x = NSMidX(workRect) - titleSize.width / 2;
      workRect.origin.y = NSMidY(workRect) - titleSize.height / 2;
      workRect.size.height = titleSize.height;
      [title drawInRect: workRect
          withAttributes: titleTextAttributes[inputState]];
    }
}

- (void) drawTitleBarBackground: (NSRect)rect {

  NSGradient* gradient = [self _windowTitlebarGradient];
  CGFloat r = METRICS_TITLEBAR_CORNER_RADIUS;

  // Work with local coordinates like Menu's RoundedCornersView does
  CGFloat x = floor(rect.origin.x);
  CGFloat y = floor(rect.origin.y);
  CGFloat width = floor(rect.size.width);
  CGFloat height = floor(rect.size.height);

  // Build path with rounded top corners only (matches Menu's RoundedCornersView approach)
  NSBezierPath* titleBarPath = [NSBezierPath bezierPath];

  // Start at bottom-left, go clockwise
  [titleBarPath moveToPoint: NSMakePoint(x, y)];
  // Bottom edge
  [titleBarPath lineToPoint: NSMakePoint(x + width, y)];
  // Right edge up to arc start
  [titleBarPath lineToPoint: NSMakePoint(x + width, y + height - r)];
  // Top-right arc
  [titleBarPath appendBezierPathWithArcWithCenter: NSMakePoint(x + width - r, y + height - r)
                                           radius: r
                                       startAngle: 0
                                         endAngle: 90];
  // Top edge
  [titleBarPath lineToPoint: NSMakePoint(x + r, y + height)];
  // Top-left arc
  [titleBarPath appendBezierPathWithArcWithCenter: NSMakePoint(x + r, y + height - r)
                                           radius: r
                                       startAngle: 90
                                         endAngle: 180];
  // Left edge (closePath will complete this)
  [titleBarPath closePath];

  [gradient drawInBezierPath: titleBarPath angle: -90];

  // Clear the corner areas to transparent for compositing
  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx setCompositingOperation: NSCompositeClear];

  // Top-left corner cutout
  NSBezierPath *leftCorner = [NSBezierPath bezierPath];
  [leftCorner moveToPoint: NSMakePoint(x, y + height)];
  [leftCorner lineToPoint: NSMakePoint(x + r, y + height)];
  [leftCorner appendBezierPathWithArcWithCenter: NSMakePoint(x + r, y + height - r)
                                         radius: r
                                     startAngle: 90
                                       endAngle: 180
                                      clockwise: NO];
  [leftCorner closePath];
  [[NSColor blackColor] setFill];
  [leftCorner fill];

  // Top-right corner cutout
  NSBezierPath *rightCorner = [NSBezierPath bezierPath];
  [rightCorner moveToPoint: NSMakePoint(x + width, y + height)];
  [rightCorner lineToPoint: NSMakePoint(x + width - r, y + height)];
  [rightCorner appendBezierPathWithArcWithCenter: NSMakePoint(x + width - r, y + height - r)
                                          radius: r
                                      startAngle: 90
                                        endAngle: 0
                                       clockwise: YES];
  [rightCorner closePath];
  [rightCorner fill];

  // Reset compositing operation
  [ctx setCompositingOperation: NSCompositeSourceOver];

  // Draw 1px highlight line at top edge
  NSBezierPath* highlightPath = [NSBezierPath bezierPath];
  [highlightPath moveToPoint: NSMakePoint(x + r, y + height - 1)];
  [highlightPath lineToPoint: NSMakePoint(x + width - r, y + height - 1)];

  NSColor *highlightColor = [NSColor colorWithCalibratedRed:0.92 green:0.92 blue:0.92 alpha:1.0];
  [highlightColor setStroke];
  [highlightPath setLineWidth: 1.0];
  [highlightPath stroke];
}

- (void) drawResizeBarRect: (NSRect)resizeBarRect
{
  //I don't want to draw the resize bar
  //TODO change the mouse cursor on hover
}

- (void)prepareTitleTextAttributes
{

  NSMutableParagraphStyle *p;
  NSColor *keyColor, *normalColor, *mainColor;

  p = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [p setLineBreakMode: NSLineBreakByClipping];


  normalColor = [NSColor colorWithCalibratedRed: 0.1 green: 0.1 blue: 0.1 alpha: 1];

  mainColor = normalColor;
  keyColor = normalColor;

  titleTextAttributes[0] = [[NSMutableDictionary alloc]
    initWithObjectsAndKeys:
      [NSFont titleBarFontOfSize: 0], NSFontAttributeName,
      keyColor, NSForegroundColorAttributeName,
      p, NSParagraphStyleAttributeName,
      nil];

  titleTextAttributes[1] = [[NSMutableDictionary alloc]
    initWithObjectsAndKeys:
    [NSFont titleBarFontOfSize: 0], NSFontAttributeName,
    normalColor, NSForegroundColorAttributeName,
    p, NSParagraphStyleAttributeName,
    nil];

  titleTextAttributes[2] = [[NSMutableDictionary alloc]
    initWithObjectsAndKeys:
    [NSFont titleBarFontOfSize: 0], NSFontAttributeName,
    mainColor, NSForegroundColorAttributeName,
    p, NSParagraphStyleAttributeName,
    nil];
}



@end
