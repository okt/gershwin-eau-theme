//
// EauTitleBarButton.h
// Eau Theme - Rectangular edge button for titlebar
//

#import <AppKit/NSButton.h>
#import "EauTitleBarButtonCell.h"

@interface EauTitleBarButton : NSButton

@property (nonatomic, assign) EauTitleBarButtonType buttonType;
@property (nonatomic, assign) EauTitleBarButtonPosition buttonPosition;
@property (nonatomic, assign) BOOL isWindowActive;

+ (instancetype)closeButton;
+ (instancetype)minimizeButton;
+ (instancetype)maximizeButton;

- (void)setWindowActive:(BOOL)active;

@end
