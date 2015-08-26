//
//  UIContainerSwitch.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/24.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerSwitch.h"

@interface UIContainerSwitch()

nonatomic_strong(UISwitch, *switchView);

@end

@implementation UIContainerSwitch

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UISwitch)
    [self.switchView addTarget:self action:@selector(eventValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setView:(id )view{
    [super setView:view];
    _switchView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"onTintColor"]) {
            self.switchView.onTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"tintColor"]) {
            self.switchView.tintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"thumbTintColor"]) {
            self.switchView.thumbTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"onImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.switchView.onImage = image;
            }];
        }else if ([key isEqualToString:@"offImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.switchView.offImage = image;
            }];
        }else if ([key isEqualToString:@"on"]) {
            self.switchView.on = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }
    }];
    return data;
}

@end
