//
//  UIContainerWindow.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerView.h"

@interface UIContainerWindow : UIContainerView

+ (UIContainerView*)containerWindow;

- (void)toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
