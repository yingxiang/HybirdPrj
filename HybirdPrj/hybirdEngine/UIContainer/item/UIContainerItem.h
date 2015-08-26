//
//  UIContainerItem.h
//  HybirdPrj
//
//  Created by xiang ying on 15/8/15.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerView.h"

@interface UIContainerItem : UIContainerView

nonatomic_strong(UIBarItem, *item)

- (void)setSubViewsUI;

@end
