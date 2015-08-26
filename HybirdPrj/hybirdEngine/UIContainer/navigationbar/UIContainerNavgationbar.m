//
//  UIContainerNavgationbar.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/30.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerNavgationbar.h"

@interface UIContainerNavgationbar()

nonatomic_strong(UINavigationBar, *navgationBar);

@end

@implementation UIContainerNavgationbar

- (void)createView:(NSDictionary *)dict{

}

- (void)setView:(id )view{
    [super setView:view];
    _navgationBar = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"barStyle"]) {
            self.navgationBar.barStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"translucent"]) {
            self.navgationBar.translucent = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"barTintColor"]) {
            self.navgationBar.barTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"shadowImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                 self.navgationBar.shadowImage = image;
            }];
        }
    }];
    return data;
}

@end
