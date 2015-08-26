//
//  UIConatinerActivityIndicatorView.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/11.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIConatinerActivityIndicatorView.h"

@interface UIConatinerActivityIndicatorView ()

nonatomic_weak(UIActivityIndicatorView, *indicatorView)

@end

@implementation UIConatinerActivityIndicatorView

- (void)createView:(NSDictionary *)dict{
    
    self.view = _obj_alloc(UIActivityIndicatorView)
}

- (void)setView:(id )view{
    [super setView:view];
    _indicatorView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"activityIndicatorViewStyle"]) {
            self.indicatorView.activityIndicatorViewStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"hidesWhenStopped"]){
            self.indicatorView.hidesWhenStopped = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"color"]){
            self.indicatorView.color = [UIColor colorWithHexString:obj];
        }
    }];
    return data;
}

@end
