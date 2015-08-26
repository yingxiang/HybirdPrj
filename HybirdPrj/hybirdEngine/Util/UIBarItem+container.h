//
//  UIBarItem+container.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - container

@class UIContainerView;

@interface UIBarItem (container)

nonatomic_weak    (UIContainerView ,  *container);

nonatomic_strong  (UIContainerView ,  *strong_container);

nonatomic_weak    (UIViewController,  *viewController);

nonatomic_weak    (UIView ,           *view);

@end