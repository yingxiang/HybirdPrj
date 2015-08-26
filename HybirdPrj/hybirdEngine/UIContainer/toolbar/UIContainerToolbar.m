//
//  UIContainerToolbar.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerToolbar.h"

@interface UIContainerToolbar()

nonatomic_strong(UIToolbar, *toolBar);

@end

@implementation UIContainerToolbar

- (void)createView:(NSDictionary *)dict{
    self.view = _obj_alloc(UIToolbar)
}

- (void)setView:(id )view{
    [super setView:view];
    _toolBar = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"barStyle"]) {
            self.toolBar.barStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }
            }];
        }else if ([key isEqualToString:@"translucent"]) {
            self.toolBar.translucent = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"barTintColor"]) {
            self.toolBar.barTintColor = [UIColor colorWithHexString:obj];
        }
    }];
    return data;
}
@end
