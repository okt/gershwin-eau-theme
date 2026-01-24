//
// EauTitleBarButton.m
// Eau Theme - Rectangular edge button for titlebar
//

#import "EauTitleBarButton.h"
#import "EauTitleBarButtonCell.h"
#import "AppearanceMetrics.h"

@implementation EauTitleBarButton

+ (Class)cellClass
{
    return [EauTitleBarButtonCell class];
}

+ (instancetype)closeButton
{
    EauTitleBarButton *button = [[EauTitleBarButton alloc] init];
    button.buttonType = EauTitleBarButtonTypeClose;
    button.buttonPosition = EauTitleBarButtonPositionLeft;
    [button setTag:NSWindowCloseButton];
    return button;
}

+ (instancetype)minimizeButton
{
    EauTitleBarButton *button = [[EauTitleBarButton alloc] init];
    button.buttonType = EauTitleBarButtonTypeMinimize;
    button.buttonPosition = EauTitleBarButtonPositionRightLeft;
    [button setTag:NSWindowMiniaturizeButton];
    return button;
}

+ (instancetype)maximizeButton
{
    EauTitleBarButton *button = [[EauTitleBarButton alloc] init];
    button.buttonType = EauTitleBarButtonTypeMaximize;
    button.buttonPosition = EauTitleBarButtonPositionRightRight;
    [button setTag:NSWindowZoomButton];
    return button;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setButtonType:NSMomentaryChangeButton];
        [self setBordered:YES];
        [self setRefusesFirstResponder:YES];
        [self setImagePosition:NSNoImage];
        _isWindowActive = YES;
    }
    return self;
}

- (EauTitleBarButtonType)buttonType
{
    return [(EauTitleBarButtonCell *)[self cell] buttonType];
}

- (void)setButtonType:(EauTitleBarButtonType)type
{
    [(EauTitleBarButtonCell *)[self cell] setButtonType:type];
}

- (EauTitleBarButtonPosition)buttonPosition
{
    return [(EauTitleBarButtonCell *)[self cell] buttonPosition];
}

- (void)setButtonPosition:(EauTitleBarButtonPosition)position
{
    [(EauTitleBarButtonCell *)[self cell] setButtonPosition:position];
}

- (BOOL)isWindowActive
{
    return [(EauTitleBarButtonCell *)[self cell] isActive];
}

- (void)setWindowActive:(BOOL)active
{
    _isWindowActive = active;
    [(EauTitleBarButtonCell *)[self cell] setIsActive:active];
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)mouseEntered:(NSEvent *)event
{
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    [self setNeedsDisplay:YES];
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];

    // Remove existing tracking areas
    for (NSTrackingArea *area in [self trackingAreas]) {
        [self removeTrackingArea:area];
    }

    // Add new tracking area for hover
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
        initWithRect:[self bounds]
             options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp)
               owner:self
            userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end
