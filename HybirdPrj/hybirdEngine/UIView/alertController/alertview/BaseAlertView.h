//
//  BaseAlertView.h
//  beautify
//
//  Created by xiangying on 14-12-3.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertController.h"

@interface BaseAlertView : UIAlertView

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickIndex:(void (^)(NSInteger index))callBack cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

@end
