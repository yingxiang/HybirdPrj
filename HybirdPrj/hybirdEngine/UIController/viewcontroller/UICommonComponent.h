//
//  UICommonComponent.h
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIContainerView;

@interface UIViewController(UICommonComponent)

//所有的子视图注册
nonatomic_strong  (NSMutableDictionary,   *jsonData);

nonatomic_strong  (UIContainerView,       *container);

nonatomic_weak    (UIContainerView,       *delegateConatiner);

nonatomic_assign  (BOOL,                  navBarHidden);

nonatomic_assign  (BOOL,                  isFirstLoad);

- (instancetype)initWithJson:(NSDictionary*)json;

- (void)createController:(NSDictionary*)json;

- (NSDictionary*)setUI:(NSDictionary*)data;

@end
