//
// EauTitleBarButtonCell.m
// Eau Theme - Rectangular edge buttons for titlebar
//

#import <AppKit/AppKit.h>
#import "EauTitleBarButtonCell.h"
#import "AppearanceMetrics.h"
#import "Eau.h"

@implementation EauTitleBarButtonCell

@synthesize buttonType = _buttonType;
@synthesize buttonPosition = _buttonPosition;
@synthesize isActive = _isActive;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _buttonType = EauTitleBarButtonTypeClose;
        _buttonPosition = EauTitleBarButtonPositionLeft;
        _isActive = YES;
    }
    return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (NSIsEmptyRect(cellFrame))
        return;

    [self drawButtonInRect:cellFrame];
    [self drawIconInRect:cellFrame];
}

- (void)drawButtonInRect:(NSRect)frame
{
    // Get button gradient colors
    NSColor *gradientColor1;
    NSColor *gradientColor2;

    // Check if button is hovered (highlighted)
    BOOL isHovered = _cell.is_highlighted;

    if (isHovered) {
        // Hover colors - traffic light colors (apply to ALL windows, active and inactive)
        switch (_buttonType) {
            case EauTitleBarButtonTypeClose:  // Red
                gradientColor1 = [NSColor colorWithCalibratedRed:0.95 green:0.45 blue:0.42 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.85 green:0.30 blue:0.27 alpha:1];
                break;
            case EauTitleBarButtonTypeMinimize:  // Yellow
                gradientColor1 = [NSColor colorWithCalibratedRed:0.95 green:0.75 blue:0.25 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.85 green:0.65 blue:0.15 alpha:1];
                break;
            case EauTitleBarButtonTypeMaximize:  // Green
                gradientColor1 = [NSColor colorWithCalibratedRed:0.35 green:0.78 blue:0.35 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.25 green:0.68 blue:0.25 alpha:1];
                break;
            default:
                // Fallback to gray
                gradientColor1 = [NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1];
                gradientColor2 = [NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1];
                break;
        }
    } else if (_isActive) {
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

    // Create path with rounded corner only on inner edge
    NSBezierPath *path = [self buttonPathForRect:frame];

    // Fill with gradient
    [gradient drawInBezierPath:path angle:-90];

    // Stroke border
    [borderColor setStroke];
    [path setLineWidth:1.0];
    [path stroke];

    // Draw top border line (replicates titlebar top edge on buttons)
    NSBezierPath *topLine = [NSBezierPath bezierPath];
    CGFloat radius = METRICS_TITLEBAR_BUTTON_INNER_RADIUS;
    if (_buttonPosition == EauTitleBarButtonPositionLeft) {
        // Close button: line from after top-left arc to right edge
        [topLine moveToPoint:NSMakePoint(NSMinX(frame) + radius, NSMaxY(frame) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 0.5)];
    } else if (_buttonPosition == EauTitleBarButtonPositionRightRight) {
        // Maximize/edge button: line from left edge to before top-right arc
        [topLine moveToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(frame) - radius, NSMaxY(frame) - 0.5)];
    } else {
        // Middle button (minimize when both exist): full width line
        [topLine moveToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame) - 0.5)];
        [topLine lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 0.5)];
    }
    [topBorderColor setStroke];
    [topLine setLineWidth:1.0];
    [topLine stroke];

    // Draw divider line for right-region buttons
    if (_buttonPosition == EauTitleBarButtonPositionRightLeft) {
        // Draw vertical divider on right edge
        NSBezierPath *divider = [NSBezierPath bezierPath];
        [divider moveToPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame) + 4)];
        [divider lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 4)];
        [borderColor setStroke];
        [divider setLineWidth:1.0];
        [divider stroke];
    }
}

- (NSBezierPath *)buttonPathForRect:(NSRect)frame
{
    CGFloat radius = METRICS_TITLEBAR_BUTTON_INNER_RADIUS;
    NSBezierPath *path = [NSBezierPath bezierPath];

    switch (_buttonPosition) {
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

- (void)drawIconInRect:(NSRect)frame
{
    // Don't draw icons on inactive windows
    if (!_isActive) {
        return;
    }

    NSRect iconRect = NSInsetRect(frame, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET);

    // Make icon rect square by adding extra horizontal inset if needed
    CGFloat extraHInset = (NSWidth(iconRect) - NSHeight(iconRect)) / 2.0;
    if (extraHInset > 0) {
        iconRect = NSInsetRect(iconRect, extraHInset, 0);
    }

    // Darker icon color for active windows (0.20)
    NSColor *iconColor = [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.0];

    if (_cell.is_highlighted) {
        iconColor = [iconColor shadowWithLevel:0.2];
    }

    [iconColor setStroke];

    NSBezierPath *iconPath = [NSBezierPath bezierPath];
    [iconPath setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [iconPath setLineCapStyle:NSRoundLineCapStyle];
    [iconPath setLineJoinStyle:NSRoundLineJoinStyle];

    switch (_buttonType) {
        case EauTitleBarButtonTypeClose: {
            // Lowercase x style - shorter strokes, more square
            CGFloat inset = NSWidth(iconRect) * 0.15;
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect) + inset, NSMinY(iconRect) + inset)];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect) - inset, NSMaxY(iconRect) - inset)];
            [iconPath moveToPoint:NSMakePoint(NSMaxX(iconRect) - inset, NSMinY(iconRect) + inset)];
            [iconPath lineToPoint:NSMakePoint(NSMinX(iconRect) + inset, NSMaxY(iconRect) - inset)];
            break;
        }

        case EauTitleBarButtonTypeMinimize: {
            // Squat down triangle - reduce height by 30%
            CGFloat heightReduction = NSHeight(iconRect) * 0.3;
            CGFloat top = NSMaxY(iconRect) - heightReduction / 2.0;
            CGFloat bottom = NSMinY(iconRect) + heightReduction / 2.0;
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect), top)];
            [iconPath lineToPoint:NSMakePoint(NSMidX(iconRect), bottom)];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect), top)];
            [iconPath closePath];
            break;
        }

        case EauTitleBarButtonTypeMaximize: {
            // Squat up triangle - reduce height by 30%
            CGFloat heightReduction = NSHeight(iconRect) * 0.3;
            CGFloat top = NSMaxY(iconRect) - heightReduction / 2.0;
            CGFloat bottom = NSMinY(iconRect) + heightReduction / 2.0;
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect), bottom)];
            [iconPath lineToPoint:NSMakePoint(NSMidX(iconRect), top)];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect), bottom)];
            [iconPath closePath];
            break;
        }
    }

    [iconPath stroke];
}

@end
