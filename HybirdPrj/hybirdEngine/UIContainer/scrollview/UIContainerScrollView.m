//
//  UIContainerScrollView.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerScrollView.h"

@interface UIContainerScrollView()<UIScrollViewDelegate>

nonatomic_strong(UIScrollView, *scrollView);

@end

@implementation UIContainerScrollView

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UIScrollView)
    self.scrollView.delegate = self;
}

- (void)setView:(id )view{
    [super setView:view];
    _scrollView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj  :data];

        if ([key isEqualToString:@"contentSize"]) {
            self.scrollView.contentSize = CGSizeFromString(obj);
        }else if ([key isEqualToString:@"contentOffset"]){
            self.scrollView.contentOffset = CGPointFromString(obj);
        }else if ([key isEqualToString:@"bounces"]){
            self.scrollView.bounces = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"alwaysBounceVertical"]){
            self.scrollView.alwaysBounceVertical = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"alwaysBounceHorizontal"]){
            self.scrollView.alwaysBounceHorizontal = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"pagingEnabled"]){
            self.scrollView.pagingEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollEnabled"]){
            self.scrollView.scrollEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"showsHorizontalScrollIndicator"]){
            self.scrollView.showsHorizontalScrollIndicator = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"showsVerticalScrollIndicator"]){
            self.scrollView.showsVerticalScrollIndicator = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"minimumZoomScale"]){
            self.scrollView.minimumZoomScale = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"maximumZoomScale"]){
            self.scrollView.maximumZoomScale = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"zoomScale"]){
            self.scrollView.zoomScale = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"bouncesZoom"]){
            self.scrollView.bouncesZoom = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollsToTop"]){
            self.scrollView.scrollsToTop = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"keyboardDismissMode"]){
            self.scrollView.keyboardDismissMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"EdgeInsets"]||[key isEqualToString:@"scrollIndicatorInsets"]){
            //需要屏蔽viewController的自动适应，否则会出现错位
            self.view.viewController.automaticallyAdjustsScrollViewInsets = NO;
            CGFloat top = self.scrollView.contentInset.top;
            
            BOOL needSetContentOffset = YES;
            if (top == 0) {
                needSetContentOffset = NO;
            }
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CGFloat offset = 0;
                
                if (obj[@"top"]) {
                    CGFloat navBarheight = 0;
                    
                    if ([self.view.viewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *nav = (UINavigationController*)self.view.viewController;
                        navBarheight = nav.navigationBar.frame.size.height;
                        if (![UIApplication sharedApplication].statusBarHidden) {
                            navBarheight = navBarheight + 20;
                        }
                        //下面的方法在ios7上面取到的statusbar 的高度是480，不知道为什么
                        //                        navBarheight = navBarheight+[UIApplication sharedApplication].statusBarFrame.size.height;
                    }else{
                        if (self.view.viewController.navigationController.navigationBar) {
                            if (self.view.viewController.container == self) {
                                navBarheight = self.view.viewController.navigationController.navigationBar.frame.size.height;
                                navBarheight = navBarheight+[UIApplication sharedApplication].statusBarFrame.size.height;
                            }
                        }
                    }
                    
                    if (obj[@"top"]) {
                        top = [[self calculate:obj[@"top"]] obj_float:^(BOOL success) {
                            if (!success) {
                                showIntegerException(@"top.value", obj[@"top"]);
                            }
                        }];
                        top = top  + navBarheight;
                    }
                }
                //y
                CGFloat left = self.scrollView.contentInset.left;
                if (obj[@"left"]) {
                    if (obj[@"left"]) {
                        left = [[self calculate:obj[@"left"]] obj_float:^(BOOL success) {
                            if (!success) {
                                showIntegerException(@"left.value", obj[@"left"]);
                            }
                        }];
                    }
                }
                
                //bottom
                CGFloat bottom = self.scrollView.contentInset.bottom;
                if (self.view.viewController.container == self) {
                    UITabBar *tabBar = self.view.viewController.tabBarController.tabBar;
                    if (tabBar.translucent) {
                        bottom = bottom + tabBar.frame.size.height;
                    }
                }

                offset = 0;
                if (obj[@"bottom"]) {
                    if (obj[@"bottom"]) {
                        bottom = [[self calculate:obj[@"bottom"]] obj_float:^(BOOL success) {
                            if (!success) {
                                showIntegerException(@"bottom.value", obj[@"bottom"]);
                            }
                        }];
                    }
                }
                
                
                //right
                CGFloat right = self.scrollView.contentInset.right;
                offset = 0;
                if (obj[@"right"]) {
                    if (obj[@"right"]) {
                        right = [[self calculate:obj[@"right"]] obj_float:^(BOOL success) {
                            if (!success) {
                                showIntegerException(@"right.value", obj[@"right"]);
                            }
                        }];
                    }
                }
                
                if ([key isEqualToString:@"scrollIndicatorInsets"]) {
                    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(top, left, bottom, right)];
                }else{
                    [self.scrollView setContentInset:UIEdgeInsetsMake(top, left, bottom, right)];
//                    if (needSetContentOffset) {
                        [self.scrollView setContentOffset:CGPointMake(left, -top)];
//                    }
                }
            }else{
                if ([key isEqualToString:@"scrollIndicatorInsets"]) {
                    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsFromString(obj)];
                }else{
                    UIEdgeInsets insets = UIEdgeInsetsFromString(obj);
                    [self.scrollView setContentInset:insets];
//                    if (needSetContentOffset) {
                        [self.scrollView setContentOffset:CGPointMake(insets.left, -insets.top)];
//                    }
                }
            }
        }
    }];
    return data;
}

- (void)layoutSubViews:(NSMutableDictionary*)uiDic{
    if (self.jsonData[@"EdgeInsets"]) {
        [uiDic setObject:self.jsonData[@"EdgeInsets"] forKey:@"EdgeInsets"];
    }
    if (self.jsonData[@"scrollIndicatorInsets"]) {
        [uiDic setObject:self.jsonData[@"scrollIndicatorInsets"] forKey:@"scrollIndicatorInsets"];
    }
    [super layoutSubViews:uiDic];
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIContainerView *container = self.subViews[@"zoomingView"];
    if (!container) {
        if (self.jsonData[@"zoomingView"]) {
            container = newContainer(self.jsonData[@"zoomingView"]);
            container.superContainer = self;
        }
    }
    return container.view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSMutableDictionary *function = [self.functionList[@"scrollViewDidScroll:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2){
    NSMutableDictionary *function = [self.functionList[@"scrollViewDidZoom:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSMutableDictionary *function = [self.functionList[@"scrollViewWillBeginDragging:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0){
    NSMutableDictionary *function = [self.functionList[@"scrollViewWillEndDragging:withVelocity:targetContentOffset:"] obj_copy];
    if (function) {
        //参数
        [function setObject:NSStringFromCGPoint(velocity) forKey:@"parmer2"];
        [function setObject:(__bridge id)(targetContentOffset) forKey:@"parmer3"];
        runFunction(function, self);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSMutableDictionary *function = [self.functionList[@"scrollViewDidEndDragging:willDecelerate:"] obj_copy];
    if (function) {
        //参数
        [function setObject:[NSNumber numberWithBool:decelerate] forKey:@"parmer2"];
        runFunction(function, self);
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSMutableDictionary *function = [self.functionList[@"scrollViewWillBeginDecelerating:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSMutableDictionary *function = [self.functionList[@"scrollViewDidEndDecelerating:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSMutableDictionary *function = [self.functionList[@"scrollViewDidEndScrollingAnimation:"] obj_copy];
    if (function) {
        //参数
        runFunction(function, self);
    }
}

#pragma mark - 

@end
