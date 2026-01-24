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

    // Draw titlebar background gradient
    NSColor *gradientColor1 = [NSColor colorWithCalibratedRed:0.833 green:0.833 blue:0.833 alpha:1];
    NSColor *gradientColor2 = [NSColor colorWithCalibratedRed:0.667 green:0.667 blue:0.667 alpha:1];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientColor1
                                                         endingColor:gradientColor2];
    [gradient drawInRect:titleRect angle:-90];

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
    BOOL hovered = (state == GSThemeHighlightedState);
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionLeft
                    buttonType:0
                        active:active
                       hovered:hovered];
    [self drawCloseIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                    withColor:[self iconColorForActive:active highlighted:hovered]];
}

- (void)drawMinimizeButtonInRect:(NSRect)rect state:(GSThemeControlState)state active:(BOOL)active
{
    BOOL hovered = (state == GSThemeHighlightedState);
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionRightLeft
                    buttonType:1
                        active:active
                       hovered:hovered];
    [self drawMinimizeIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                       withColor:[self iconColorForActive:active highlighted:hovered]];
}

- (void)drawMaximizeButtonInRect:(NSRect)rect state:(GSThemeControlState)state active:(BOOL)active
{
    BOOL hovered = (state == GSThemeHighlightedState);
    [self drawEdgeButtonInRect:rect
                      position:EauTitleBarButtonPositionRightRight
                    buttonType:2
                        active:active
                       hovered:hovered];
    [self drawMaximizeIconInRect:NSInsetRect(rect, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET)
                       withColor:[self iconColorForActive:active highlighted:hovered]];
}

#pragma mark - Icon Drawing

- (void)drawCloseIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    if (!color) return;  // Don't draw on inactive windows

    // Make icon rect square by adding extra horizontal inset if needed
    CGFloat extraHInset = (NSWidth(rect) - NSHeight(rect)) / 2.0;
    if (extraHInset > 0) {
        rect = NSInsetRect(rect, extraHInset, 0);
    }

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];

    // Lowercase x style - shorter strokes, more square
    CGFloat inset = NSWidth(rect) * 0.15;
    [path moveToPoint:NSMakePoint(NSMinX(rect) + inset, NSMinY(rect) + inset)];
    [path lineToPoint:NSMakePoint(NSMaxX(rect) - inset, NSMaxY(rect) - inset)];
    [path moveToPoint:NSMakePoint(NSMaxX(rect) - inset, NSMinY(rect) + inset)];
    [path lineToPoint:NSMakePoint(NSMinX(rect) + inset, NSMaxY(rect) - inset)];

    [color setStroke];
    [path stroke];
}

- (void)drawMinimizeIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    if (!color) return;  // Don't draw on inactive windows

    // Make icon rect square by adding extra horizontal inset if needed
    CGFloat extraHInset = (NSWidth(rect) - NSHeight(rect)) / 2.0;
    if (extraHInset > 0) {
        rect = NSInsetRect(rect, extraHInset, 0);
    }

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];

    // Squat down triangle - reduce height by 30%
    CGFloat heightReduction = NSHeight(rect) * 0.3;
    CGFloat top = NSMaxY(rect) - heightReduction / 2.0;
    CGFloat bottom = NSMinY(rect) + heightReduction / 2.0;
    [path moveToPoint:NSMakePoint(NSMinX(rect), top)];
    [path lineToPoint:NSMakePoint(NSMidX(rect), bottom)];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), top)];
    [path closePath];

    [color setStroke];
    [path stroke];
}

- (void)drawMaximizeIconInRect:(NSRect)rect withColor:(NSColor *)color
{
    if (!color) return;  // Don't draw on inactive windows

    // Make icon rect square by adding extra horizontal inset if needed
    CGFloat extraHInset = (NSWidth(rect) - NSHeight(rect)) / 2.0;
    if (extraHInset > 0) {
        rect = NSInsetRect(rect, extraHInset, 0);
    }

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];

    // Squat up triangle - reduce height by 30%
    CGFloat heightReduction = NSHeight(rect) * 0.3;
    CGFloat top = NSMaxY(rect) - heightReduction / 2.0;
    CGFloat bottom = NSMinY(rect) + heightReduction / 2.0;
    [path moveToPoint:NSMakePoint(NSMinX(rect), bottom)];
    [path lineToPoint:NSMakePoint(NSMidX(rect), top)];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), bottom)];
    [path closePath];

    [color setStroke];
    [path stroke];
}

#pragma mark - Private Helpers

// buttonType: 0=close, 1=minimize, 2=maximize
- (void)drawEdgeButtonInRect:(NSRect)rect
                    position:(EauTitleBarButtonPosition)position
                  buttonType:(NSInteger)buttonType
                      active:(BOOL)active
                     hovered:(BOOL)hovered
{
    // Get button gradient colors
    NSColor *gradientColor1;
    NSColor *gradientColor2;

    if (hovered) {
        // Hover colors - traffic light colors (apply to ALL windows, active and inactive)
        switch (buttonType) {
            case 0:  // Close - Red
                gradientColor1 = [NSColor colorWithCalibratedRed:0.95 green:0.45 blue:0.42 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.85 green:0.30 blue:0.27 alpha:1];
                break;
            case 1:  // Minimize - Yellow
                gradientColor1 = [NSColor colorWithCalibratedRed:0.95 green:0.75 blue:0.25 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.85 green:0.65 blue:0.15 alpha:1];
                break;
            case 2:  // Maximize - Green
                gradientColor1 = [NSColor colorWithCalibratedRed:0.35 green:0.78 blue:0.35 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.25 green:0.68 blue:0.25 alpha:1];
                break;
            default:
                // Fallback to gray
                gradientColor1 = [NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1];
                break;
        }
    } else if (active) {
        // Active window - dark gray gradient for strong button contrast
        gradientColor1 = [NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1];
    } else {
        // Inactive window - dimmed gray colors
        gradientColor1 = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1];
    }

    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientColor1
                                                         endingColor:gradientColor2];

    NSColor *borderColor = [Eau controlStrokeColor];

    // Top border color - matches titlebar top edge (slightly lighter for visual trick)
    NSColor *topBorderColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0];

    // Create path with appropriate corner rounding
    NSBezierPath *path = [self buttonPathForRect:rect position:position];

    // Fill with gradient
    [gradient drawInBezierPath:path angle:-90];

    // Stroke border
    [borderColor setStroke];
    [path setLineWidth:1.0];
    [path stroke];

    // Draw top border line (replicates titlebar top edge on buttons)
    NSBezierPath *topLine = [NSBezierPath bezierPath];
    CGFloat radius = METRICS_TITLEBAR_BUTTON_INNER_RADIUS;
    if (position == EauTitleBarButtonPositionLeft) {
        // Close button: line from after top-left arc to right edge
        [topLine moveToPoint:NSMakePoint(NSMinX(rect) + radius, NSMaxY(rect) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 0.5)];
    } else if (position == EauTitleBarButtonPositionRightRight) {
        // Maximize/edge button: line from left edge to before top-right arc
        [topLine moveToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(rect) - radius, NSMaxY(rect) - 0.5)];
    } else {
        // Middle button (minimize when both exist): full width line
        [topLine moveToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 0.5)];
    }
    [topBorderColor setStroke];
    [topLine setLineWidth:1.0];
    [topLine stroke];

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
            // Close button: ONLY top-left corner rounded, inner edge (right) is straight
            [path moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];  // bottom-left
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];  // bottom-right (straight)
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];  // top-right (straight inner edge)
            [path lineToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame))];  // to top-left arc start
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:90
                                           endAngle:180];  // top-left corner
            [path closePath];
            break;

        case EauTitleBarButtonPositionRightLeft:
            // Minimize button: NO rounding at all (middle button, both edges face title)
            [path appendBezierPathWithRect:frame];
            break;

        case EauTitleBarButtonPositionRightRight:
            // Maximize button: ONLY top-right corner rounded, inner edge (left) is straight
            [path moveToPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];  // bottom-left
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];  // bottom-right
            [path lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - radius)];  // up right edge to arc
            [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame) - radius)
                                             radius:radius
                                         startAngle:0
                                           endAngle:90];  // top-right corner
            [path lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];  // straight inner edge (left)
            [path closePath];
            break;
    }

    return path;
}

- (NSColor *)iconColorForActive:(BOOL)active highlighted:(BOOL)highlighted
{
    // Don't draw icons on inactive windows
    if (!active) {
        return nil;
    }

    // Darker icon color for active windows (0.20)
    NSColor *color = [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.0];

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
