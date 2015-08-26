//
//  UIContainerTabBar.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/11.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTabBar.h"

@implementation UIContainerTabBar

- (void)createView:(NSDictionary*)dict
{
}

- (void)setView:(id )view{
    [super setView:view];
    _tabBar = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"tintColor"]) {
            self.tabBar.tintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"barTintColor"]) {
            self.tabBar.barTintColor = [UIColor colorWithHexString:obj];
        }
        if ([key isEqualToString:@"selectedImageTintColor"]) {
            self.tabBar.selectedImageTintColor = [UIColor colorWithHexString:obj];
        }
        if ([key isEqualToString:@"backgroundImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.tabBar.backgroundImage = image;
            }];
        }
        if ([key isEqualToString:@"selectionIndicatorImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.tabBar.selectionIndicatorImage = image;
            }];
        }
        if ([key isEqualToString:@"shadowImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.tabBar.shadowImage = image;
            }];
        }else if ([key isEqualToString:@"itemWidth"]) {
            self.tabBar.itemWidth = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"itemSpacing"]) {
            self.tabBar.itemSpacing = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"barStyle"]) {
            self.tabBar.barStyle =[obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"translucent"]) {
            self.tabBar.translucent = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }
    }];
    return data;
}

@end
