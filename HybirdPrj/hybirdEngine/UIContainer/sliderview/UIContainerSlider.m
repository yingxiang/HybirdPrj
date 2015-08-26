//
//  UIContainerSlider.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/25.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerSlider.h"

@interface UIContainerSlider()

nonatomic_strong(UISlider, *sliderView);

@end

@implementation UIContainerSlider

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UISlider)
    [self.sliderView addTarget:self action:@selector(eventValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setView:(id )view{
    [super setView:view];
    _sliderView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"value"]) {
            self.sliderView.value = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"minimumValue"]) {
            self.sliderView.minimumValue = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"maximumValue"]) {
            self.sliderView.maximumValue = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"minimumValueImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.sliderView.minimumValueImage = image;
            }];
        }else if ([key isEqualToString:@"maximumValueImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.sliderView.maximumValueImage = image;
            }];
        }else if ([key isEqualToString:@"continuous"]) {
            self.sliderView.continuous = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"minimumTrackTintColor"]) {
            self.sliderView.minimumTrackTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"maximumTrackTintColor"]) {
            self.sliderView.maximumTrackTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"thumbTintColor"]) {
            self.sliderView.thumbTintColor = [UIColor colorWithHexString:obj];
        }
    }];
    return data;
}

@end
