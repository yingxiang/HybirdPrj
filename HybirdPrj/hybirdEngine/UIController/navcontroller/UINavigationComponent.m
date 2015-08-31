//
//  UINavigationComponent.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UINavigationComponent.h"

static const void *pushCompleteKey = &pushCompleteKey;

@implementation UINavigationController(UINavigationComponent)

- (completionBlock)pushComplete {
    return objc_getAssociatedObject(self, pushCompleteKey);
}

- (void)setPushComplete:(completionBlock)pushComplete{
    objc_setAssociatedObject(self, pushCompleteKey, pushComplete, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (instancetype)initWithJson:(NSDictionary *)json{
    self = [self init];
    if (self) {
        [self createController:json];
    }
    return self;
}

- (void)createController:(NSDictionary *)json{
    [super createController:json];
    self.delegate = self;
    if (json[@"rootViewController"]) {
        UIViewController *common = newController(json[@"rootViewController"]);
        if (common) {
            self.viewControllers = @[common];
        }
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self popGesture:YES];
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [obj assignment:obj :data];
        if ([key isEqualToString:@"navigationBar"]) {
            UIContainerView *navbar = self.navigationBar.container;
            if (!navbar) {
                navbar = newContainer(obj);
                navbar.view = self.navigationBar;
                navbar.superContainer = self.container;
                self.navigationBar.container = navbar;
            }
            [navbar setUI:obj];
        }else if ([key isEqualToString:@"toolbarHidden"]){
            self.toolbarHidden = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"toolbar"]){
            UIContainerView *toolbar = self.toolbar.strong_container;
            if (!toolbar) {
                toolbar = newContainer(obj);
                toolbar.view = self.toolbar;
                self.toolbar.strong_container = toolbar;
            }
            [toolbar setUI:obj];
        }
    }];
    return data;
}

- (void)popGesture:(BOOL)gesture{
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        if (gesture) {
            self.interactivePopGestureRecognizer.enabled  = YES;
            self.interactivePopGestureRecognizer.delegate = self;
        }else{
            self.interactivePopGestureRecognizer.enabled  = NO;
            self.interactivePopGestureRecognizer.delegate = nil;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count == 1) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0)
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(completionBlock)completion{
    self.pushComplete = completion;
    [self pushViewController:viewController animated:animated];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated completion:(completionBlock)completion{
    self.pushComplete = completion;
    return [self popViewControllerAnimated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated completion:(completionBlock)completion{
    self.pushComplete = completion;
    return [self popToRootViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(completionBlock)completion{
    self.pushComplete = completion;
    return [self popToViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.pushComplete) {
        self.pushComplete();
        self.pushComplete = nil;
    }
    [UIViewControllerHelper shareInstance].isPresenting = NO;
}
@end
