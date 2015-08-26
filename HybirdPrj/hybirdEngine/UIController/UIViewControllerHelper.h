//
//  UIViewControllerHelper.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICommonComponent.h"
#import "UINavigationComponent.h"
#import "UITabbarCommponent.h"

typedef enum {
    UIViewControllerPushModel = 0,
    UIViewControllerPresenteModel = 1
}UIViewControllerAnimationModel;


@interface UIViewControllerHelper : NSObject

nonatomic_strong(NSMutableArray, *viewControllers);

nonatomic_assign(BOOL,            isPresenting);

DECLARE_AS_SINGLETON(UIViewControllerHelper);

- (void)addViewController:(UIViewController*)viewCtrol;

- (void)removeAllViewController;

- (void)deleteToViewControlView:(UIViewController*)viewCtrol;


#pragma mark - user methodes

- (void)goBackanimated:(BOOL)animated;

- (BOOL)isFromViewController:(NSString*)className;

- (void)goBackTo:(NSString*)className animated:(BOOL)animated;

- (UIViewController*)goTo:(NSString *)className  model:(UIViewControllerAnimationModel)model data:(NSDictionary*)dic animated:(BOOL)animated;

- (UIViewController*)getCurrentViewController;

- (UIViewController*)getViewControllerbyClassName:(NSString*)className;

#pragma mark - 

+ (id)creatViewController:(NSDictionary*)dic;

@end
