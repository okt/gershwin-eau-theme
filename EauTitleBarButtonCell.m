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
    // Get titlebar gradient colors
    NSColor *gradientColor1;
    NSColor *gradientColor2;

    if (_isActive) {
        // Active window - use normal titlebar gradient
        gradientColor1 = [NSColor colorWithCalibratedRed:0.833 green:0.833 blue:0.833 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.667 green:0.667 blue:0.667 alpha:1];
    } else {
        // Inactive window - dimmed colors
        gradientColor1 = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1];
        gradientColor2 = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1];
    }

    // Slightly differentiate button from titlebar
    if (_cell.is_highlighted) {
        gradientColor1 = [gradientColor1 shadowWithLevel:0.15];
        gradientColor2 = [gradientColor2 shadowWithLevel:0.15];
    }

    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:gradientColor1
                                                         endingColor:gradientColor2];

    NSColor *borderColor = [Eau controlStrokeColor];

    // Create path with rounded corner only on inner edge
    NSBezierPath *path = [self buttonPathForRect:frame];

    // Fill with gradient
    [gradient drawInBezierPath:path angle:-90];

    // Stroke border
    [borderColor setStroke];
    [path setLineWidth:1.0];
    [path stroke];

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
            // Close button: rounded on right side only
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
            [path lineToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
            [path closePath];
            break;

        case EauTitleBarButtonPositionRightLeft:
            // Minimize button: rounded on left side only (part of right region)
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
            // Maximize button: no rounded corners (right edge of window)
            [path appendBezierPathWithRect:frame];
            break;
    }

    return path;
}

- (void)drawIconInRect:(NSRect)frame
{
    NSRect iconRect = NSInsetRect(frame, METRICS_TITLEBAR_ICON_INSET, METRICS_TITLEBAR_ICON_INSET);

    // Icon color
    NSColor *iconColor;
    if (_isActive) {
        iconColor = [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    } else {
        iconColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }

    if (_cell.is_highlighted) {
        iconColor = [iconColor shadowWithLevel:0.2];
    }

    [iconColor setStroke];

    NSBezierPath *iconPath = [NSBezierPath bezierPath];
    [iconPath setLineWidth:METRICS_TITLEBAR_ICON_STROKE];
    [iconPath setLineCapStyle:NSRoundLineCapStyle];
    [iconPath setLineJoinStyle:NSRoundLineJoinStyle];

    switch (_buttonType) {
        case EauTitleBarButtonTypeClose:
            // X icon
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect), NSMinY(iconRect))];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect), NSMaxY(iconRect))];
            [iconPath moveToPoint:NSMakePoint(NSMaxX(iconRect), NSMinY(iconRect))];
            [iconPath lineToPoint:NSMakePoint(NSMinX(iconRect), NSMaxY(iconRect))];
            break;

        case EauTitleBarButtonTypeMinimize:
            // Down triangle (minimize)
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect), NSMaxY(iconRect) - 2)];
            [iconPath lineToPoint:NSMakePoint(NSMidX(iconRect), NSMinY(iconRect) + 2)];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect), NSMaxY(iconRect) - 2)];
            break;

        case EauTitleBarButtonTypeMaximize:
            // Up triangle (maximize)
            [iconPath moveToPoint:NSMakePoint(NSMinX(iconRect), NSMinY(iconRect) + 2)];
            [iconPath lineToPoint:NSMakePoint(NSMidX(iconRect), NSMaxY(iconRect) - 2)];
            [iconPath lineToPoint:NSMakePoint(NSMaxX(iconRect), NSMinY(iconRect) + 2)];
            break;
    }

    [iconPath stroke];
}

@end
