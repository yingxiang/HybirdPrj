//
//  UIBarItem+container.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIBarItem+container.h"

static const void *containerKey = &containerKey;
static const void *strong_containerKey = &strong_containerKey;
static const void *viewControllerKey = &viewControllerKey;

@implementation UIBarItem (container)
@dynamic view;

- (UIContainerView *)container {
    return objc_getAssociatedObject(self, containerKey);
}

- (void)setContainer:(UIContainerView *)container{
    objc_setAssociatedObject(self, containerKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIContainerView *)strong_container {
    return objc_getAssociatedObject(self, strong_containerKey);
}

- (void)setStrong_container:(UIContainerView *)strong_container{
    objc_setAssociatedObject(self, strong_containerKey, strong_container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.container = strong_container;
}

- (UIViewController *)viewController {
    return objc_getAssociatedObject(self, viewControllerKey);
}

- (void)setViewController:(UIViewController *)viewController{
    objc_setAssociatedObject(self, viewControllerKey, viewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView*)view{
    return [self valueForKeyPath:@"_view"];
}

@end
