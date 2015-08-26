//
//  CALayer+animation.h
//  HybirdPrj
//
//  Created by xiang ying on 15/8/9.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "CALayer+animation.h"

static const void *completionBlockKey = &completionBlockKey;

@implementation CALayer (animation)
@dynamic completeHandle;

- (completionBlock)completeHandle {
    return objc_getAssociatedObject(self, completionBlockKey);
}

- (void)setCompleteHandle:(completionBlock)completeHandle{
    objc_setAssociatedObject(self, completionBlockKey, completeHandle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

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
- (void)animationWithType:(animType)animType subType:(animSubType)subType curve:(animCurve)curve duration:(CGFloat)duration repeatsCount:(NSInteger)repeats completion:(completionBlock)complete{
    
    if (animType == animTypeBreathe) {
        [self opacityTimes_Animation:repeats durTimes:duration completion:complete];
    }else if (animType == animTypeRotate){
        [self rotation:0.1 degree:0.1 direction:WAxisX repeatCount:repeats completion:complete];
    }else if (animType == animTypeShake){
        [self shake_AnimationRepeatTimes:repeats durTimes:duration completion:complete];
    }else if (animType == animTypeScale){
        [self scaleFrom:0.4 toScale:1.0 durTimes:duration rep:repeats completion:complete];
    }else{
        NSString *key = @"transition";
        
        if([self animationForKey:key]!=nil){
            [self removeAnimationForKey:key];
        }
        CATransition *transition=[CATransition animation];
        
        //动画时长
        transition.duration=duration;
        
        //动画类型
        transition.type=[self animaTypeWithTransitionType:animType];
        
        //动画方向
        transition.subtype=[self animaSubtype:subType];
        
        transition.repeatCount = repeats;
        //缓动函数
        transition.timingFunction=[CAMediaTimingFunction functionWithName:[self curve:curve]];
        
        //完成动画删除
        transition.removedOnCompletion = YES;
        transition.delegate = self;
        self.completeHandle = complete;
        [self addAnimation:transition forKey:key];
    }
}


/**
 *  breathing with fixed repeated times
 *
 *  @param repeatTimes times
 *  @param time        duritaion, from clear to fully seen
 *
 *  @return animation obj
 */
- (void)opacityTimes_Animation:(NSInteger)repeatTimes durTimes:(float)time completion:(completionBlock)complete
{
    NSString *key = kBadgeBreatheAniKey;
    
    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.1];
    animation.repeatCount=repeatTimes;
    animation.duration=time;
    animation.removedOnCompletion = YES;
    animation.fillMode=kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses=YES;
    
    animation.delegate = self;
    self.completeHandle = complete;
    [self addAnimation:animation forKey:key];
}

/**
 *  //rotate
 *
 *  @param dur         duration
 *  @param degree      rotate degree in radian(弧度)
 *  @param axis        axis
 *  @param repeatCount repeat count
 *
 *  @return animation obj
 */
- (void)rotation:(float)dur degree:(float)degree direction:(WAxis)axis repeatCount:(NSInteger)repeatCount completion:(completionBlock)complete
{
    NSString *key = kBadgeRotateAniKey;
    
    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }
    
    CABasicAnimation* animation;
    NSArray *axisArr = @[@"transform.rotation.x", @"transform.rotation.y", @"transform.rotation.z"];
    animation = [CABasicAnimation animationWithKeyPath:axisArr[axis]];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue= [NSNumber numberWithFloat:degree];
    animation.duration= dur;
    animation.autoreverses= NO;
    animation.cumulative= YES;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.repeatCount= repeatCount;
    animation.delegate= self;
    
    self.completeHandle = complete;
    [self addAnimation:animation forKey:key];
}

/**
 *  scale animation
 *
 *  @param fromScale   the original scale value, 1.0 by default
 *  @param toScale     target scale
 *  @param time        duration
 *  @param repeatTimes repeat counts
 *
 *  @return animaiton obj
 */
- (void)scaleFrom:(CGFloat)fromScale toScale:(CGFloat)toScale durTimes:(float)time rep:(NSInteger)repeatTimes completion:(completionBlock)complete
{
    NSString *key = kBadgeScaleAniKey;
    
    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(fromScale);
    animation.toValue = @(toScale);
    animation.duration = time;
    animation.autoreverses = YES;
    animation.repeatCount = repeatTimes;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    
    animation.delegate = self;
    self.completeHandle = complete;
    [self addAnimation:animation forKey:key];
}

/**
 *  shake
 *
 *  @param repeatTimes time
 *  @param time        duration
 *  @param obj         always be CALayer
 *  @return aniamtion obj
 */
- (void)shake_AnimationRepeatTimes:(NSInteger)repeatTimes durTimes:(float)time completion:(completionBlock)complete
{
    NSString *key = kBadgeShakeAniKey;
    
    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }
    CGPoint originPos = [self position];
    CGSize originSize = [self bounds].size;

    CGFloat hOffset = originSize.width / 4;
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"position";
    anim.values=@[
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x-hOffset, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x+hOffset, originPos.y)],
                  [NSValue valueWithCGPoint:CGPointMake(originPos.x, originPos.y)]
                  ];
    anim.repeatCount=repeatTimes;
    anim.duration=time;
    anim.fillMode = kCAFillModeForwards;
    anim.delegate = self;
    self.completeHandle = complete;
    [self addAnimation:anim forKey:key];
}

/**
 *  动画执行完成的回调
 *
 *  @param anim
 *  @param flag
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.completeHandle) {
        self.completeHandle();
    }
}


/*
 *  返回动画曲线
 */
- (NSString *)curve:(animCurve)curve{
    
    //曲线数组
    NSArray *funcNames=@[kCAMediaTimingFunctionDefault,kCAMediaTimingFunctionEaseIn,kCAMediaTimingFunctionEaseInEaseOut,kCAMediaTimingFunctionEaseOut,kCAMediaTimingFunctionLinear];
    
    return [self objFromArray:funcNames index:curve isRamdom:(animCurveRamdom == curve)];
}



/*
 *  返回动画方向
 */
- (NSString *)animaSubtype:(animSubType)subType{
    
    //设置转场动画的方向
    NSArray *subtypes=@[kCATransitionFromTop,kCATransitionFromLeft,kCATransitionFromBottom,kCATransitionFromRight];
    
    return [self objFromArray:subtypes index:subType isRamdom:(animSubtypesFromRamdom == subType)];
}




/*
 *  返回动画类型
 */
-(NSString *)animaTypeWithTransitionType:(animType)type{
    
    //设置转场动画的类型
    NSArray *animArray=@[@"rippleEffect",@"suckEffect",@"pageCurl",@"oglFlip",@"cube",@"reveal",@"pageUnCurl",@"push"];
    
    return [self objFromArray:animArray index:type isRamdom:(animTypeRamdom == type)];
}



/*
 *  统一从数据返回对象
 */
-(id)objFromArray:(NSArray *)array index:(NSUInteger)index isRamdom:(BOOL)isRamdom{
    
    NSUInteger count = array.count;
    
    NSUInteger i = isRamdom?arc4random_uniform((u_int32_t)count) : index;
    
    return array[i];
}


@end
