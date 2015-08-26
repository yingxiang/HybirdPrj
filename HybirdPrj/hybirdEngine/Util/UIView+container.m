//
//  UIView+container.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIView+container.h"

static const void *containerKey = &containerKey;
static const void *strong_containerKey = &strong_containerKey;
static const void *viewControllerKey = &viewControllerKey;

@implementation UIView (container)
@dynamic viewController;

- (UIContainerView *)container {
    return objc_getAssociatedObject(self, containerKey);
}

- (void)setContainer:(UIContainerView *)container{
    objc_setAssociatedObject(self, containerKey, container, OBJC_ASSOCIATION_ASSIGN);
}

- (UIContainerView *)strong_container {
    return objc_getAssociatedObject(self, strong_containerKey);
}

- (void)setStrong_container:(UIContainerView *)strong_container{
    objc_setAssociatedObject(self, strong_containerKey, strong_container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)viewController {
    return objc_getAssociatedObject(self, viewControllerKey);
}

- (void)setViewController:(UIViewController *)viewController{
    objc_setAssociatedObject(self, viewControllerKey, viewController, OBJC_ASSOCIATION_ASSIGN);
}

- (id)getProperty:(NSString*)property{
    id value = nil;
    if ([property isEqualToString:@"frame"]) {
        value = NSStringFromCGRect(self.frame);
    }else if ([property isEqualToString:@"size"]){
        value = NSStringFromCGSize(self.frame.size);
    }else if ([property isEqualToString:@"origin"]){
        value = NSStringFromCGPoint(self.frame.origin);
    }else if ([property isEqualToString:@"width"]){
        CGFloat width = self.frame.size.width;
        value = [NSNumber numberWithFloat:width];
    }else if ([property isEqualToString:@"height"]){
        value = [NSNumber numberWithFloat:self.frame.size.height];
    }else if ([property isEqualToString:@"x"]){
        value = [NSNumber numberWithFloat:self.frame.origin.x];
    }else if ([property isEqualToString:@"y"]){
        value = [NSNumber numberWithFloat:self.frame.origin.y];
    }else if ([property isEqualToString:@"center"]){
        value = NSStringFromCGPoint(self.center);
    }else if ([property isEqualToString:@"centerX"]){
        value = [NSNumber numberWithFloat:self.center.x];
    }else if ([property isEqualToString:@"centerY"]){
        value = [NSNumber numberWithFloat:self.center.y];
    }else{
        return [super getProperty:property];
    }
    return value;
}

@end
