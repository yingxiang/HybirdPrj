//
//  UITabbarCommponent.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UITabbarCommponent.h"


@implementation UITabBarController(UITabbarCommponent)

- (instancetype)initWithJson:(NSDictionary *)json{
    self = [self init];
    if (self) {
        [self createController:json];
    }
    return self;
}

- (void)createController:(NSDictionary *)json{
    [super createController:json];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSString *tabString in json[@"viewControllers"]) {
        NSDictionary *tabDic = readFile(_HYBIRD_PATH_VIEWCONTROLLER, tabString);
        UIViewController *vc = [UIViewControllerHelper creatViewController:tabDic];
        if (vc) {
            [viewControllers addObject:vc];
        }
    }
    self.viewControllers = viewControllers;
    self.delegate = self;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"tabBar"]) {
            
            UIContainerTabBar *container = (UIContainerTabBar*)self.tabBar.container;
            if (!container) {
                container =  [UIContainerHelper createViewContainerWithDic:obj];
                container.tabBar = self.tabBar;
                container.superContainer = self.container;
                self.tabBar.container = container;
            }
            [container setUI:obj];
        }
    }];
    return data;
}

#pragma mark - 横竖屏

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0){
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    [UIViewControllerHelper shareInstance].viewControllers = [NSMutableArray arrayWithObject:viewController];
    NSMutableDictionary *function = [[viewController.container.functionList objectForKey:@"tabBarController:didSelectViewController:"] obj_copy];
    if (function) {
        runFunction(function, viewController.container);
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}



@end
