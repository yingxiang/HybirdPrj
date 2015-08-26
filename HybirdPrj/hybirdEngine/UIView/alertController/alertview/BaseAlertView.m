//
//  BaseAlertView.m
//  beautify
//
//  Created by xiangying on 14-12-3.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import "BaseAlertView.h"

@interface BaseAlertView()

nonatomic_copy(clickHandle, clickBlock)

@end

@implementation BaseAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickIndex:(void (^)(NSInteger index))callBack cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles{
    
    UIViewController  *vc = [[UIViewControllerHelper shareInstance] getCurrentViewController];
    
    if ([[[UIDevice currentDevice] systemVersion] obj_float:nil]>=8.0 && vc) {
        BaseAlertController *alert = [BaseAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (callBack) {
            alert.clickBlock = callBack;
        }
        
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
        [vc presentViewController:alert animated:YES completion:^{
            
        }];
    }else{
        BaseAlertView *alert = [[BaseAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        
        if (otherButtonTitles) {
            for (NSString *otherButtonTitle in otherButtonTitles) {
                [alert addButtonWithTitle:otherButtonTitle];
            }
        }
        
        if (callBack) {
            alert.delegate = alert;
            alert.clickBlock = callBack;
        }
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clickBlock) {
        self.clickBlock(buttonIndex);
    }
}

- (void)dealloc{
    self.clickBlock = nil;
}
@end
