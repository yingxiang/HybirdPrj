//
//  BaseAlertController.h
//  beautify
//
//  Created by xiangying on 15/4/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickHandle)(NSInteger buttonIndex);

@interface BaseAlertController : UIAlertController

nonatomic_copy(clickHandle, clickBlock)

@end
