//
//  BaseActionSheet.h
//  beautify
//
//  Created by xiangying on 14-12-3.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlertController.h"

@interface BaseActionSheet : UIActionSheet

+ (void)actionSheetShowInView:(UIView*)view withTitle:(NSString *)title destructiveButtonTitle:(NSString *)message clickIndex:(void (^)(NSInteger))callBack cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;


@end
