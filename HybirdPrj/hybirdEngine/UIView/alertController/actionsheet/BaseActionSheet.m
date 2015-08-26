//
//  BaseActionSheet.m
//  beautify
//
//  Created by xiangying on 14-12-3.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import "BaseActionSheet.h"


@interface BaseActionSheet()<UIActionSheetDelegate>

nonatomic_copy(clickHandle, clickBlock)

@end

@implementation BaseActionSheet

+ (void)actionSheetShowInView:(UIView*)view withTitle:(NSString *)title destructiveButtonTitle:(NSString *)message clickIndex:(void (^)(NSInteger))callBack cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles{
   
    while ([UIViewControllerHelper shareInstance].isPresenting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    UIViewController  *vc = [[UIViewControllerHelper shareInstance] getCurrentViewController];

    if ([[[UIDevice currentDevice] systemVersion] obj_float:nil]>=8.0 && vc) {
        BaseAlertController *alert = [BaseAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (_isIpad) {
            if ([view isKindOfClass:[UIView class]]) {
                UIPopoverPresentationController *popoverPresentationController = alert.popoverPresentationController;
                popoverPresentationController.sourceView = view;
                popoverPresentationController.sourceRect = CGRectMake((CGRectGetWidth(view.bounds)-2)*0.5f, (CGRectGetHeight(view.bounds)-2), 2, 2);// 显示在中心位置
                
            }else if ([view isKindOfClass:[UIBarButtonItem class]]){
                UIPopoverPresentationController *popoverPresentationController = alert.popoverPresentationController;
                popoverPresentationController.barButtonItem = (UIBarButtonItem*)view;
            }

        }
        alert.clickBlock = callBack;
        
        if (cancelButtonTitle) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if (alert.clickBlock) {
                    alert.clickBlock(0);
                }
            }];
            [alert addAction:action];
        }
        if (otherButtonTitles) {
            for (int a = 0; a < otherButtonTitles.count;a++) {
                NSString *otherButtonTitle = otherButtonTitles[a];
                UIAlertAction *action = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if (alert.clickBlock) {
                        alert.clickBlock(a+1);
                    }
                }];
                [alert addAction:action];
            }
        }
        [vc presentViewController:alert animated:YES completion:nil];
    }else{
        
        NSString *other1 = nil;
        NSString *other2 = nil;
        NSString *other3 = nil;
        NSString *other4 = nil;
        NSString *other5 = nil;
        NSString *other6 = nil;
        NSString *other7 = nil;
        NSString *other8 = nil;
        
        switch (otherButtonTitles.count) {
            case 8:
                other8 = otherButtonTitles[7];
            case 7:
                other7 = otherButtonTitles[6];
            case 6:
                other6 = otherButtonTitles[5];
            case 5:
                other5 = otherButtonTitles[4];
            case 4:
                other4 = otherButtonTitles[3];
            case 3:
                other3 = otherButtonTitles[2];
            case 2:
                other2 = otherButtonTitles[1];
            case 1:
                other1 = otherButtonTitles[0];
            default:
                break;
        }
        
        BaseActionSheet *actionSheet = [[BaseActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:message otherButtonTitles:other1,other2,other3,other4,other5,other6,other7,other8,nil];
//        for (NSString *otherButtonTitle in otherButtonTitles) {
//            [actionSheet addButtonWithTitle:otherButtonTitle];
//        }
        
        if (callBack) {
            actionSheet.delegate = actionSheet;
            actionSheet.clickBlock = callBack;
        }
        if (vc) {
            [actionSheet showInView:vc.view];
        }else{
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [actionSheet showInView:window];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clickBlock) {
        self.clickBlock(buttonIndex+1);
    }
}

- (void)dealloc{
    self.clickBlock = nil;
}
@end
