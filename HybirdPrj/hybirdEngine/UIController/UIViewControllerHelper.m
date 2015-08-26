//
//  UIViewControllerHelper.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIViewControllerHelper.h"
#import "UIWindow+Category.h"
#import "NSDictionary+addEntries.h"

@implementation UIViewControllerHelper

DECLARE_SINGLETON(UIViewControllerHelper);

- (instancetype)init{
    self = [super init];
    if (self) {
        _viewControllers = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 视图流转

- (BOOL)isFromViewController:(NSString*)className{
    
    for (int i = 0; i<_viewControllers.count; i++) {
        UIViewController *viewController = _viewControllers[i];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            for (UIViewController *v in ((UINavigationController*)viewController).viewControllers) {
                if ([NSStringFromClass([v class]) isEqualToString:className]) {
                    return YES;
                }
            }
        }else if ([NSStringFromClass([viewController class]) isEqualToString:className]) {
            return YES;
        }
    }
    return NO;
}

- (void)addViewController:(UIViewController*)viewCtrol{
    if (![_viewControllers containsObject:viewCtrol]) {
        [_viewControllers addObject:viewCtrol];
    }
}

- (void)removeAllViewController{
    [_viewControllers removeAllObjects];
}

- (void)goBackanimated:(BOOL)animated{
    
    while ([UIViewControllerHelper shareInstance].isPresenting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    if ([[_viewControllers lastObject] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *current = (UINavigationController*)[_viewControllers lastObject];
        if (current.viewControllers.count > 1) {
            [current popViewControllerAnimated:animated completion:^{
                [UIViewControllerHelper shareInstance].isPresenting = NO;
            }];
        }else{
            [current dismissViewControllerAnimated:animated completion:^{
                [UIViewControllerHelper shareInstance].isPresenting = NO;
            }];
        }
    }else{
        [[_viewControllers lastObject] dismissViewControllerAnimated:animated completion:^{
            [UIViewControllerHelper shareInstance].isPresenting = NO;
        }];
    }
}

- (void)goBackTo:(NSString*)className animated:(BOOL)animated{
    
    while ([UIViewControllerHelper shareInstance].isPresenting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    for (NSInteger i = _viewControllers.count-1;i>=0;i--) {
        UIViewController *viewController = _viewControllers[i];
        if ([_viewControllers[i] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController*)_viewControllers[i];
            for (UIViewController *v in nav.viewControllers) {
                if ([v.identify isEqualToString:className]){
                    [nav popToViewController:v animated:animated completion:^{
                        [UIViewControllerHelper shareInstance].isPresenting = NO;
                    }];
                    break;
                }
            }
        }else if ([viewController.identify isEqualToString:className]){
            [viewController dismissViewControllerAnimated:animated completion:^{
                [UIViewControllerHelper shareInstance].isPresenting = NO;
            }];
            break;
        }
    }
}

- (UIViewController*)goTo:(NSString *)className  model:(UIViewControllerAnimationModel)model data:(NSDictionary*)dic animated:(BOOL)animated
{
    while ([UIViewControllerHelper shareInstance].isPresenting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
    UIViewController *current = [_viewControllers lastObject];

    NSDictionary *vcDic = readFile(_HYBIRD_PATH_VIEWCONTROLLER, className);
    NSMutableDictionary *vcData = [NSMutableDictionary dictionaryWithDictionary:vcDic];
    if (dic) {
        [vcData addEntries:dic];
    }

    UIViewController *controller = [UIViewControllerHelper creatViewController:vcData];

    if (controller) {
        if ([current isKindOfClass:[UINavigationController class]]) {
            UINavigationController  *nav = (UINavigationController*)current;
            if (model == UIViewControllerPushModel) {
                if ([controller isKindOfClass:[UINavigationController class]]) {
                    NSString *msg = [NSString stringWithFormat:@":%@ :%d :%@ :%d",className,model,dic,animated];
                    showException(msg);
                }else{
                    [nav pushViewController:controller animated:animated completion:^{
                        [UIViewControllerHelper shareInstance].isPresenting = NO;
                    }];
                }
            }else{
                UIViewController *vc = [nav.viewControllers lastObject];
                [vc presentViewController:controller animated:animated completion:nil];
            }
        }else{
            [current presentViewController:controller animated:animated completion:nil];
        }
    }

    return controller;
}

- (void)deleteToViewControlView:(UIViewController*)viewCtrol{
    if ([_viewControllers containsObject:viewCtrol]) {
        [_viewControllers removeObject:viewCtrol];
    }
}

- (UIViewController*)getCurrentViewController{
    UIViewController *vc = [_viewControllers lastObject];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)vc;
        return nav.topViewController;
    }
    return vc;
}

- (UIViewController*)getViewControllerbyClassName:(NSString*)className{
    NSInteger i = _viewControllers.count-1;
    for (;i>=0;i--) {
        UIViewController *viewController = _viewControllers[i];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController*)viewController;
            for (UIViewController *v in nav.viewControllers) {
                if ([v isKindOfClass:NSClassFromString(className)]) {
                    return v;
                }
            }
        }else if([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

#pragma mark - 
+ (id)creatViewController:(NSDictionary*)dic{
    UIViewController *vc = nil;
    
    NSString *classname = dic[@"class"];
    if (classname) {
        Class aClass = NSClassFromString(classname);
        if (classname) {
            vc = [[aClass alloc] initWithJson:dic];
        }else{
            vc = _obj_alloc(UIViewController)
            //避免因为初始化而崩溃
            showException(dic.description);
        }
    }else{
        //避免因为初始化而崩溃
        showException(dic.description);

    }
    return vc;
}

@end

