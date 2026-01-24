//
// Eau+TitleBarButtons.m
// Eau Theme - Titlebar button rendering for window manager integration
//

#import "Eau+TitleBarButtons.h"
#import "AppearanceMetrics.h"

@implementation Eau (TitleBarButtons)

#pragma mark - Geometry Queries

- (CGFloat)titlebarHeight
{
    return METRICS_TITLEBAR_HEIGHT;
}

- (NSRect)closeButtonRectForTitlebarWidth:(CGFloat)width
{
    // Close button at left edge, full height
    return NSMakeRect(0, 0, METRICS_TITLEBAR_EDGE_BUTTON_WIDTH, METRICS_TITLEBAR_HEIGHT);
}

- (NSRect)minimizeButtonRectForTitlebarWidth:(CGFloat)width
{
    // Minimize button on left side of right region
    CGFloat x = width - METRICS_TITLEBAR_RIGHT_REGION_WIDTH;
    CGFloat buttonWidth = METRICS_TITLEBAR_RIGHT_REGION_WIDTH / 2.0;
    return NSMakeRect(x, 0, buttonWidth, METRICS_TITLEBAR_HEIGHT);
}

- (NSRect)maximizeButtonRectForTitlebarWidth:(CGFloat)width
{
    // Maximize button on right side of right region
    CGFloat x = width - (METRICS_TITLEBAR_RIGHT_REGION_WIDTH / 2.0);
    CGFloat buttonWidth = METRICS_TITLEBAR_RIGHT_REGION_WIDTH / 2.0;
    return NSMakeRect(x, 0, buttonWidth, METRICS_TITLEBAR_HEIGHT);
}

- (NSRect)rightButtonRegionRectForTitlebarWidth:(CGFloat)width
{
    // Combined minimize+maximize region
    return NSMakeRect(width - METRICS_TITLEBAR_RIGHT_REGION_WIDTH, 0,
                      METRICS_TITLEBAR_RIGHT_REGION_WIDTH, METRICS_TITLEBAR_HEIGHT);
}

#pragma mark - Drawing Methods

- (void)drawTitlebarInRect:(NSRect)rect withTitle:(NSString *)title active:(BOOL)active
{
    // Get button rects
    CGFloat width = NSWidth(rect);
    NSRect closeRect = [self closeButtonRectForTitlebarWidth:width];
    NSRect rightRegion = [self rightButtonRegionRectForTitlebarWidth:width];

    // Draw titlebar background (main area between buttons)
    NSRect titleRect = NSMakeRect(NSMaxX(closeRect), 0,
                                  NSMinX(rightRegion) - NSMaxX(closeRect),
                                  METRICS_TITLEBAR_HEIGHT);
    [self drawTitleBarBackground:titleRect];

    // Draw buttons
    GSThemeControlState state = GSThemeNormalState;
    [self drawCloseButtonInRect:closeRect state:state active:active];
    [self drawMinimizeButtonInRect:[self minimizeButtonRectForTitlebarWidth:width] state:state active:active];
    [self drawMaximizeButtonInRect:[self maximizeButtonRectForTitlebarWidth:width] state:state active:active];

    // Draw title text centered in title area
    if (title && [title length] > 0) {
        [self drawTitleText:title inRect:titleRect active:active];
    }
}

- (void)drawCloseButtonInRect:(NSRect)rect state:(GSThemeControlState)state active:(BOOL)active
{
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionLeft
                        active:active
                   highlighted:(state == GSThemeHighlightedState)];
    [self drawCloseIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                    withColor:[self iconColorForActive:active highlighted:(state == GSThemeHighlightedState)]];
}

- (void)drawMinimizeButtonInRect:(NSRect)rect state:(GSThemeControlState)state active:(BOOL)active
{
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionRightLeft
                        active:active
                   highlighted:(state == GSThemeHighlightedState)];
    [self drawMinimizeIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                       withColor:[self iconColorForActive:active highlighted:(state == GSThemeHighlightedState)]];
}

- (void)drawMaximizeButtonInRect:(NSRect)rect state:(GSThemeControlState)state active:(BOOL)active
{
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionRightRight
                        active:active
                   highlighted:(state == GSThemeHighlightedState)];
    [self drawMaximizeIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                       withColor:[self iconColorForActive:active highlighted:(state == GSThemeHighlightedState)]];
}

#pragma mark - Icon Drawing

- (void)drawCloseIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];

    // X icon
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
    [path moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
    [path lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];

    [color setStroke];
    [path stroke];
}

- (void)drawMinimizeIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];

    // Down triangle (minimize)
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - 2)];
    [path lineToPoint:NSMakePoint(NSMidX(rect), NSMinY(rect) + 2)];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 2)];

    [color setStroke];
    [path stroke];
}

- (void)drawMaximizeIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];

    // Up triangle (maximize)
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) + 2)];
    [path lineToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect) - 2)];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + 2)];

    [color setStroke];
    [path stroke];
}

#pragma mark - Private Helpers

- (void)drawEdgeButtonInRect:(NSRect)rect
                    position:(EauTitleBarButtonPosition)position
                      active:(BOOL)active
                 highlighted:(BOOL)highlighted
{
    // Get gradient colors
    NSColor *gradientColor1;
    NSColor *gradientColor2;

    if (active) {
        gradientColor1 = [NSColor colorWithCalibratedRed:0.833 green:0.833 blue:0.833 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.667 green:0.667 blue:0.667 alpha:1];
    } else {
        gradientColor1 = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1];
    }

    if (highlighted) {
        gradientColor1 = [gradientColor1 shadowWithLevel:0.15];
        gradientColor2 = [gradientColor2 shadowWithLevel:0.15];
    }

    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientColor1
                                                         endingColor:gradientColor2];

    NSColor *borderColor = [Eau controlStrokeColor];

    // Create path with appropriate corner rounding
    NSBezierPath *path = [self buttonPathForRect:rect position:position];

    // Fill with gradient
    [gradient drawInBezierPath:path angle:-90];

    // Stroke border
    [borderColor setStroke];
    [path setLineWidth:1.0];
    [path stroke];

    // Draw divider for minimize button
    if (position == EauTitleBarButtonPositionRightLeft) {
        NSBezierPath *divider = [NSBezierPath bezierPath];
        [divider moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + 4)];
        [divider lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 4)];
        [borderColor setStroke];
        [divider setLineWidth:1.0];
        [divider stroke];
    }
}

- (NSBezierPath *)buttonPathForRect:(NSRect)frame position:(EauTitleBarButtonPosition)position
{
    CGFloat radius = METRICS_TITLEBAR_BUTTON_INNER_RADIUS;
    NSBezierPath *path = [NSBezierPath bezierPath];

    switch (position) {
        case EauTitleBarButtonPositionLeft:
            // Close button: rounded on right side only, plus top-left corner for window
            [path moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
            [path lineToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMinY(frame))];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame) - radius, NSMinY(frame) + radius)
                                             radius:radius
                                         startAngle:270
                                           endAngle:0];
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - radius)];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:0
                                           endAngle:90];
            [path lineToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame))];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:90
                                           endAngle:180];
            [path lineToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
            [path closePath];
            break;

        case EauTitleBarButtonPositionRightLeft:
            // Minimize button: rounded on left side only
            [path moveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame))];
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];
            [path lineToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame))];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:90
                                           endAngle:180];
            [path lineToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame) + radius)];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(frame) + radius, NSMinY(frame) + radius)
                                             radius:radius
                                         startAngle:180
                                           endAngle:270];
            [path closePath];
            break;

        case EauTitleBarButtonPositionRightRight:
            // Maximize button: top-right corner rounded
            [path moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - radius)];
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:0
                                           endAngle:90];
            [path lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
            [path closePath];
            break;
    }

    return path;
}

- (NSColor *)iconColorForActive:(BOOL)active highlighted:(BOOL)highlighted
{
    NSColor *color;
    if (active) {
        color = [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    } else {
        color = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }

    if (highlighted) {
        color = [color shadowWithLevel:0.2];
    }

    return color;
}

- (void)drawTitleText:(NSString *)title inRect:(NSRect)rect active:(BOOL)active
{
    static NSDictionary *activeAttrs = nil;
    static NSDictionary *inactiveAttrs = nil;

    if (!activeAttrs) {
        NSMutableParagraphStyle *p = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [p setAlignment:NSCenterTextAlignment];
        [p setLineBreakMode:NSLineBreakByTruncatingTail];

        NSColor *activeColor = [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1];
        NSColor *inactiveColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1];

        activeAttrs = @{
            NSFontAttributeName: [NSFont titleBarFontOfSize:0],
            NSForegroundColorAttributeName: activeColor,
            NSParagraphStyleAttributeName: p
        };

        inactiveAttrs = @{
            NSFontAttributeName: [NSFont titleBarFontOfSize:0],
            NSForegroundColorAttributeName: inactiveColor,
            NSParagraphStyleAttributeName: p
        };
    }

    NSDictionary *attrs = active ? activeAttrs : inactiveAttrs;
    NSSize titleSize = [title sizeWithAttributes:attrs];

    // Center vertically
    NSRect drawRect = rect;
    drawRect.origin.y = NSMidY(rect) - titleSize.height / 2.0;
    drawRect.size.height = titleSize.height;

    [title drawInRect:drawRect withAttributes:attrs];
}

@end
