//
//  UIContainerHelper.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIContainerView.h"
#import "UIContainerItem.h"
#import "UIContainerLabel.h"
#import "UIContainerTextField.h"
#import "UIContainerButton.h"
#import "UIContainerImageView.h"
#import "UIContainerScrollView.h"
#import "UIContainerTextView.h"
#import "UIContainerTableView.h"
#import "UIContainerCell.h"
#import "UIContainerSwitch.h"
#import "UIContainerSlider.h"
#import "UIContainerProgress.h"
#import "UIContainerSegment.h"
#import "UIContainerButtonItem.h"
#import "UIContainerTabBarItem.h"
#import "UIContainerCollectionCell.h"
#import "UIContainerCollectionView.h"
#import "UIContainerReusableView.h"
#import "UIContainerWindow.h"
#import "UIContainerTabBar.h"
#import "UIContaineriCarousel.h"
#import "UIContainerPageControl.h"
#import "UIContainerToolbar.h"
#import "UIContainerNavgationbar.h"
#import "UIConatinerActivityIndicatorView.h"

@interface UIContainerHelper : NSObject

DECLARE_AS_SINGLETON(UIContainerHelper);

+ (id)createViewContainerWithDic:(NSDictionary*)aDic;

@end
