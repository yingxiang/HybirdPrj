//
//  UIContainerProgress.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/25.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerProgress.h"

@interface UIContainerProgress()

nonatomic_strong(UIProgressView, *progressView);

@end

@implementation UIContainerProgress

- (void)createView:(NSDictionary*)dict
{
    UIProgressViewStyle style = [dict[@"progressViewStyle"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"progressViewStyle", dict[@"progressViewStyle"]);
        }
    }];
    self.view = [[UIProgressView alloc] initWithProgressViewStyle:style];
}

- (void)setView:(id )view{
    [super setView:view];
    _progressView = view;
}

//布局视图
- (NSDictionary*)setUI:(NSDictionary*)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"progress"]) {
            self.progressView.progress = [[self calculate:obj] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"progressTintColor"]) {
            self.progressView.progressTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"trackTintColor"]) {
            self.progressView.trackTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"progressImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.progressView.progressImage = image;
            }];
        }else if ([key isEqualToString:@"trackImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.progressView.trackImage = image;
            }];
        }
    }];
    return data;
}

@end
