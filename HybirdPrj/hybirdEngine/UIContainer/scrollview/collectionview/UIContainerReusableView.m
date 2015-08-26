//
//  UIContainerReusableView.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerReusableView.h"

@interface UIContainerReusableView()

nonatomic_strong(UICollectionReusableView, *reuseView);

@end

@implementation UIContainerReusableView

- (void)createView:(NSDictionary*)dict
{

}

- (void)setView:(id )view{
    [super setView:view];
    _reuseView = view;
}


- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    return data;
}

@end
