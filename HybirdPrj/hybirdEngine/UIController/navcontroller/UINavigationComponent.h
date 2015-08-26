//
//  UINavigationComponent.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completionBlock)(void);

@interface UINavigationController(UINavigationComponent)<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

nonatomic_copy(completionBlock, pushComplete)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(completionBlock)completion;

- (UIViewController*)popViewControllerAnimated:(BOOL)animated completion:(completionBlock)completion;

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated completion:(completionBlock)completion;

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(completionBlock)completion;

@end
