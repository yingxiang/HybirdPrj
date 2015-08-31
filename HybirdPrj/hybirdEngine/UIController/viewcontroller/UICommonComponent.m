//
//  UICommonComponent.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UICommonComponent.h"

static const void *jsonDataKey = &jsonDataKey;
static const void *containerKey = &containerKey;
static const void *delegateConatinerKey = &delegateConatinerKey;
static const void *navBarHiddenKey = &navBarHiddenKey;
static const void *isFirstLoadKey = &isFirstLoadKey;

@implementation UIViewController(UICommonComponent)

#pragma mark - VCM

- (void)presentHBViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    [UIViewControllerHelper shareInstance].isPresenting = YES;
    [self presentHBViewController:viewControllerToPresent animated:flag completion:^{
        [UIViewControllerHelper shareInstance].isPresenting = NO;
        if (completion) {
            completion();
        }
    }];
    [[UIViewControllerHelper shareInstance] addViewController:viewControllerToPresent];
}

- (void)dismissHBViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion{

    [UIViewControllerHelper shareInstance].isPresenting = YES;

    if (self.presentedViewController) {
        if (self.presentedViewController.navigationController) {
            [[UIViewControllerHelper shareInstance] deleteToViewControlView:self.presentedViewController.navigationController];
        }else{
            if (self.presentedViewController.parentViewController) {
                [[UIViewControllerHelper shareInstance] deleteToViewControlView:self.presentedViewController.parentViewController];
            }else{
                [[UIViewControllerHelper shareInstance] deleteToViewControlView:self.presentedViewController];
            }
        }
    }else{
        if (self.navigationController) {
            [[UIViewControllerHelper shareInstance] deleteToViewControlView:self.navigationController];
        }else{
            if (self.parentViewController) {
                [[UIViewControllerHelper shareInstance] deleteToViewControlView:self.parentViewController];
            }else{
                [[UIViewControllerHelper shareInstance] deleteToViewControlView:self];
            }
        }
    }

    [self dismissHBViewControllerAnimated:flag completion:^{
        [UIViewControllerHelper shareInstance].isPresenting = NO;
        UIViewController *vc =  [[[UIViewControllerHelper shareInstance] viewControllers] lastObject];
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController*)vc;
            
            if (!nav.navigationBarHidden) {
                CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
                if (statusHeight == 0) {
                    //重新布局navbar(这是ios8以上视频全屏播放回退到竖屏导航界面的bug)
                    nav.navigationBarHidden = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [nav setNavigationBarHidden:NO animated:YES];
                    });
                }
            }
        }
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - 拓展自定义属性

- (NSMutableDictionary *)jsonData {
    return objc_getAssociatedObject(self, jsonDataKey);
}

- (void)setJsonData:(NSMutableDictionary *)jsonData{
    objc_setAssociatedObject(self, jsonDataKey, jsonData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIContainerView *)container {
    return objc_getAssociatedObject(self, containerKey);
}

- (void)setContainer:(UIContainerView *)container{
    objc_setAssociatedObject(self, containerKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIContainerView *)delegateConatiner {
    return objc_getAssociatedObject(self, delegateConatinerKey);
}

- (void)setDelegateConatiner:(UIContainerView *)delegateConatiner{
    objc_setAssociatedObject(self, delegateConatinerKey, delegateConatiner, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)navBarHidden {
    return [objc_getAssociatedObject(self, navBarHiddenKey) boolValue];
}

- (void)setNavBarHidden:(BOOL)navBarHidden{
    objc_setAssociatedObject(self, navBarHiddenKey, [NSNumber numberWithBool:navBarHidden], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isFirstLoad {
    return [objc_getAssociatedObject(self, isFirstLoadKey) boolValue];
}

- (void)setIsFirstLoad:(BOOL)isFirstLoad{
    objc_setAssociatedObject(self, isFirstLoadKey, [NSNumber numberWithBool:isFirstLoad], OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 初始化

- (instancetype)initWithJson:(NSDictionary*)json
{
    self = [self init];
    if (self) {
        [self createController:json];
    }
    return self;
}

- (void)createController:(NSDictionary*)json{
    if (json[@"container"]) {
        self.container = newContainer(json[@"container"]);
        self.container.view.viewController = self;
        self.isFirstLoad = YES;
    }else {
        self.container = newContainer(@{@"UIContainerType":@"UIContainerView",@"identify":@"navContainer"});
    }
    self.jsonData = [NSMutableDictionary dictionaryWithDictionary:json];

    [self setUI:self.jsonData];
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [data obj_copy];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"title"]) {
            self.title = obj;
        }else if ([key isEqualToString:@"tabBarItem"]) {
            UIContainerItem *tabBarItem = (UIContainerItem*)self.tabBarItem.container;
            if (!tabBarItem) {
                tabBarItem = newContainer(obj);
                tabBarItem.item = self.tabBarItem;
                tabBarItem.superContainer = self.container;
            }
            [tabBarItem setUI:obj];
            if (obj[@"subViews"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), main_queue, ^{
                    [tabBarItem setUI:@{@"subViews":obj[@"subViews"]}];
                });
            }
        }else if ([key isEqualToString:@"hidesBottomBarWhenPushed"]){
            self.hidesBottomBarWhenPushed = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if([key isEqualToString:@"navigationItem"]){
            if (obj[@"leftBarButtonItem"]) {
                UIContainerButtonItem *item = [self.container.subViews objectForKey:@"leftBarButtonItem"];
                if (!item) {
                    item = newContainer(obj[@"leftBarButtonItem"]);
                    if (self.navigationItem.leftBarButtonItem && [obj[@"rightBarButtonItem"][@"useSysterm"] obj_bool:^(BOOL success) {
                        if (!success) {
                            showBoolException(key, obj);
                        }
                    }]) {
                        item.item = self.navigationItem.leftBarButtonItem;
                    }
                    item.superContainer = self.container;
                }
                [item setUI:item.jsonData];
                self.navigationItem.leftBarButtonItem = (UIBarButtonItem*)item.item;
            }
            if (obj[@"rightBarButtonItem"]) {
                UIContainerButtonItem *item = [self.container.subViews objectForKey:@"rightBarButtonItem"];
                if (!item) {
                    item = newContainer(obj[@"rightBarButtonItem"]);
                    if (self.navigationItem.rightBarButtonItem && [obj[@"rightBarButtonItem"][@"useSysterm"] obj_bool:^(BOOL success) {
                        if (!success) {
                            showBoolException(key, obj);
                        }
                    }]) {
                        item.item = (id)self.navigationItem.rightBarButtonItem;
                    }
                    item.superContainer = self.container;
                }
                [item setUI:item.jsonData];
                self.navigationItem.rightBarButtonItem = (UIBarButtonItem*)item.item;
            }
            if (obj[@"rightBarButtonItems"]) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *dic in obj[@"rightBarButtonItems"]) {
                    UIContainerItem *container = newContainer(dic);
                    [container setUI:dic];
                    container.superContainer = self.container;
                    [array addObject:container.item];
                }
                self.navigationItem.rightBarButtonItems = array;
            }
            if (obj[@"leftBarButtonItems"]) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *dic in obj[@"leftBarButtonItems"]) {
                    UIContainerItem *container = newContainer(dic);
                    [container setUI:dic];
                    container.superContainer = self.container;
                    [array addObject:container.item];
                }
                self.navigationItem.leftBarButtonItems = array;
            }
            if (obj[@"titleView"]) {
                UIContainerView *container = self.navigationItem.titleView.container;
                if (!container) {
                    container = newContainer(obj[@"titleView"]);
                    container.superContainer = self.container;
                }
                [container setUI:obj[@"titleView"]];
                self.navigationItem.titleView = container.view;
            }
            
        }else if ([key isEqualToString:@"navigationController"]){
            if (obj[@"hidden"]) {
                self.navBarHidden = [obj[@"hidden"] obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }
            if (obj[@"translucent"]){
                self.navigationController.navigationBar.translucent = [obj[@"translucent"] obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }
        }else if ([key isEqualToString:@"modalTransitionStyle"]){
            self.modalTransitionStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"delegateConatiner"]){
            self.delegateConatiner = obj;
        }
    }];
    return data;
}




#pragma mark - 系统方法替换（特别注意是viewcontroller才需要执行以下方法）
- (void)commpontviewWillAppear:(BOOL)animated{
    [self commpontviewWillAppear:animated];
    
    NSString *viewController = NSStringFromClass([self class]);
    if ([viewController isEqualToString:@"UIViewController"]) {
        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:self.navBarHidden animated:YES];
        }
    }
}

- (void)commpontviewWillDisappear:(BOOL)animated{
    [self commpontviewWillDisappear:animated];
    NSString *viewController = NSStringFromClass([self class]);
    if ([viewController isEqualToString:@"UIViewController"]) {
        [self.container viewWillDisappear:animated];
    }
}

- (void)commpontviewDidAppear:(BOOL)animated{
    [self commpontviewDidAppear:animated];
    NSString *viewController = NSStringFromClass([self class]);
    if ([viewController isEqualToString:@"UIViewController"]) {
        if (self.isFirstLoad) {
            self.isFirstLoad = NO;
        }else{
            [self.container viewDidAppear:animated];
        }
    }
}

- (void)commpontviewDidDisappear:(BOOL)animated{
    [self commpontviewDidDisappear:animated];
    NSString *viewController = NSStringFromClass([self class]);
    if ([viewController isEqualToString:@"UIViewController"]) {
        [self.container viewDidDisappear:animated];
    }
}

- (void)commpontviewDidLoad {
    [self commpontviewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *viewController = NSStringFromClass([self class]);
    if ([viewController isEqualToString:@"UIViewController"]) {
        [self analyzeJson];
        NSDictionary *function = [[self.container.functionList objectForKey:@"viewDidLoad"] obj_copy];
        if (function) {
            runFunction(function, self.container);
        }
    }else {
        self.container.view = self.view;
        self.container.view.viewController = self;
    }
}

- (void)analyzeJson
{
    if (self.jsonData[@"container"]) {
        [self.jsonData[@"container"] setValue:NSStringFromCGRect(self.view.frame) forKey:@"frame"];
        self.view = self.container.view;
        @try {
            [self.container setUI:self.jsonData[@"container"]];
        }
        @catch (NSException *exception) {
            NSLog(@"exception :%@",exception);
        }
        @finally {
            
        }
    }else {
        self.container.view = self.view;
        self.container.view.viewController = self;
    }
}

//状态栏
- (UIStatusBarStyle)commpontpreferredStatusBarStyle{
    if (self.jsonData[@"UIStatusBarStyle"]) {
        
        NSString *obj = self.jsonData[@"UIStatusBarStyle"];
        return [obj obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"UIStatusBarStyle", obj);
            }
        }];
    }
    return UIStatusBarStyleDefault;
}

#pragma mark - 横竖屏

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    if (self.jsonData[@"supportedInterfaceOrientations"]) {
        NSInteger integer = [self.jsonData[@"supportedInterfaceOrientations"] obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"supportedInterfaceOrientations", self.jsonData[@"supportedInterfaceOrientations"]);
            }
        }];
        switch (integer) {
            case 0:
                return UIInterfaceOrientationMaskPortrait;
            case 1:
                return UIInterfaceOrientationMaskLandscapeLeft;
            case 2:
                return UIInterfaceOrientationMaskLandscapeRight;
            case 3:
                return UIInterfaceOrientationMaskPortraitUpsideDown;
            case 4:
                return UIInterfaceOrientationMaskLandscape;
            case 5:
                return UIInterfaceOrientationMaskAll;
            case 6:
                return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.jsonData[@"supportedInterfaceOrientations"]) {
        NSString *obj = self.jsonData[@"supportedInterfaceOrientations"];
        NSInteger integer = [obj obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"supportedInterfaceOrientations", obj);
            }
        }];
        switch (integer) {
            case 1:
            case 4:
                return UIInterfaceOrientationLandscapeLeft;
            case 2:
                return UIInterfaceOrientationLandscapeRight;
            default:
                return UIInterfaceOrientationPortrait;
        }
    }
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //全局tips也要跟着旋转
    UIContainerWindow *_statusWindowContainer = [[NSModelFuctionCenter shareInstance] statusWindowContainer];
    [UIView animateWithDuration:duration animations:^{
        [_statusWindowContainer toInterfaceOrientation:toInterfaceOrientation];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if (self.container) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.container layoutSubViews:[NSMutableDictionary dictionary]];
        }];
    }
}

@end
