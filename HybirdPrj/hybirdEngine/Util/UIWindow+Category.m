//
//  UIWindow+Category.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIWindow+Category.h"

@implementation UIWindow (Category)

- (void)setVSRootViewController:(UIViewController *)rootViewController{
    [self setVSRootViewController:rootViewController];
    if ([[UIApplication sharedApplication].delegate window] == self) {
        [[UIViewControllerHelper shareInstance] removeAllViewController];
        if ([rootViewController isKindOfClass:[UITabBarController class]]) {
            UIViewController *vc = [(UITabBarController*)rootViewController selectedViewController];
            [[UIViewControllerHelper shareInstance] addViewController:vc];
        }else{
            [[UIViewControllerHelper shareInstance] addViewController:rootViewController];
        }
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        _hybird_post_notification_(_NSNotification_MotionShake, nil)
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

@end
