//
//  UIView+container.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - container
@class UIContainerView;
@interface UIView (container)

nonatomic_weak    (UIContainerView ,  *container);

nonatomic_strong  (UIContainerView ,  *strong_container);

nonatomic_weak    (UIViewController,  *viewController);

@end
