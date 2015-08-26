//
//  UIContainerDatePicker.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/13.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerDatePicker.h"

@interface UIContainerDatePicker()

nonatomic_strong(UIDatePicker, *datePicker);

@end

@implementation UIContainerDatePicker

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UIDatePicker)
}

- (void)setView:(id )view{
    [super setView:view];
    _datePicker = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"datePickerMode"]) {
            self.datePicker.datePickerMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"locale"]){
            
        }else if ([key isEqualToString:@"calendar"]){
            
        }else if ([key isEqualToString:@"timeZone"]){
            
        }else if ([key isEqualToString:@"calendar"]){
            
        }else if ([key isEqualToString:@"date"]){
            
        }else if ([key isEqualToString:@"minimumDate"]){
            
        }else if ([key isEqualToString:@"maximumDate"]){
            
        }else if ([key isEqualToString:@"countDownDuration"]){
            
        }else if ([key isEqualToString:@"minuteInterval"]){
            
        }
    }];
    return data;
}

@end
