//
//  TJLaunchAnimateViewController.h
//  bubble
//
//  Created by apple on 2017/12/27.
//  Copyright © 2017 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DSLaunchAnimateType){
    DSLaunchAnimateTypeNone = 0,
    DSLaunchAnimateTypeFade,
    DSLaunchAnimateTypeFadeAndZoomIn,
    DSLaunchAnimateTypePointZoomIn1,
    DSLaunchAnimateTypePointZoomIn2,
    DSLaunchAnimateTypePointZoomOut1,
    DSLaunchAnimateTypePointZoomOut2
};

typedef void(^CompleteBlock)(void);

@interface TJLaunchAnimateViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) DSLaunchAnimateType animateType;
@property (nonatomic, assign) CGFloat animateDuration;
@property (nonatomic, assign) CGFloat waitDuration;
@property (nonatomic, copy) CompleteBlock complete;
@property (nonatomic, assign) BOOL showSkipButton;

- (instancetype)initWithContentView:(UIView *)contentView animateType:(DSLaunchAnimateType)animateType showSkipButton:(BOOL)showSkipButton;

- (void)show;
- (void)dismissAtOnce;

@end
