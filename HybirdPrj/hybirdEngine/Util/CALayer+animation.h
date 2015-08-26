//
//  CALayer+animation.h
//  HybirdPrj
//
//  Created by xiang ying on 15/8/9.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (animation)

nonatomic_copy(completionBlock, completeHandle)

/*
 *  动画类型
 */
typedef enum{
    
    //水波
    animTypeRippleEffect  = 0,
    
    //吸走
    animTypeSuckEffect    = 1,
    
    //翻开书本
    animTypePageCurl      = 2,
    
    //正反翻转
    animTypeOglFlip       = 3,
    
    //正方体
    animTypeCube          = 4,
    
    //推开
    animTypeReveal        = 5,
    
    //合上书本
    animTypePageUnCurl    = 6,
    
    //push
    animTypePush          = 7,

    //呼吸
    animTypeBreathe       = 8,
    //旋转
    animTypeRotate        = 9,
    //抖动
    animTypeShake         = 10,
    //放大缩放
    animTypeScale         = 11,

    
    //随机
    animTypeRamdom        = 12,
    
}animType;




/*
 *  动画方向
 */
typedef enum{
    
    //从上
    animSubtypesFromTop       = 0,
    
    //从左
    animSubtypesFromLeft      = 1,
    
    //从下
    animSubtypesFromBotoom    = 2,
    
    //从右
    animSubtypesFromRight     = 3,
    
    //随机
    animSubtypesFromRamdom    = 4,
    
}animSubType;


/*
 *  动画曲线
 */
typedef enum {
    
    //默认
    animCurveDefault,
    
    //缓进
    animCurveEaseIn,
    
    //缓出
    animCurveEaseOut,
    
    //缓进缓出
    animCurveEaseInEaseOut,
    
    //线性
    animCurveLinear,
    
    //随机
    animCurveRamdom,
    
}animCurve;




/**
 *  转场动画
 *
 *  @param animType 转场动画类型
 *  @param subtype  转动动画方向
 *  @param curve    转动动画曲线
 *  @param duration 转动动画时长
 *
 *  @return 转场动画实例
 */
- (void)animationWithType:(animType)animType subType:(animSubType)subType curve:(animCurve)curve duration:(CGFloat)duration repeatsCount:(NSInteger)repeats completion:(completionBlock)complete;


typedef NS_ENUM(NSUInteger, WAxis)
{
    WAxisX = 0,
    WAxisY,
    WAxisZ
};

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#define kBadgeBreatheAniKey     @"breathe"
#define kBadgeRotateAniKey      @"rotate"
#define kBadgeShakeAniKey       @"shake"
#define kBadgeScaleAniKey       @"scale"

- (void)shake_AnimationRepeatTimes:(NSInteger)repeatTimes durTimes:(float)time completion:(completionBlock)complete;

- (void)scaleFrom:(CGFloat)fromScale toScale:(CGFloat)toScale durTimes:(float)time rep:(NSInteger)repeatTimes completion:(completionBlock)complete;

- (void)rotation:(float)dur degree:(float)degree direction:(WAxis)axis repeatCount:(NSInteger)repeatCount completion:(completionBlock)complete;

- (void)opacityTimes_Animation:(NSInteger)repeatTimes durTimes:(float)time completion:(completionBlock)complete;

@end
