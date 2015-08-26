//
//  UIContainerLabel.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerLabel.h"
#import "AlignmentLabel.h"

@interface UIContainerLabel()

nonatomic_strong(UILabel, *label);

@end

@implementation UIContainerLabel

- (void)createView:(NSDictionary*)dict
{
    if (dict[@"verticalAlignment"]) {
        self.view = _obj_alloc(AlignmentLabel)
    }else{
        self.view = _obj_alloc(UILabel)
    }
}

- (void)setView:(id )view{
    [super setView:view];
    _label = view;
    [_label sizeToFit];
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj  :data];
        if ([key isEqualToString:@"text"]) {
            self.label.text = [self stringFormat:obj];
        }else if ([key isEqualToString:@"textColor"]) {
            self.label.textColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"textAlignment"]) {
            self.label.textAlignment = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"font"]) {
            self.label.font = [UIFont systemFontOfSize:[obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }]];
        }else if ([key isEqualToString:@"numberOfLines"]) {
            self.label.numberOfLines = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"enabled"]) {
            self.label.enabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"verticalAlignment"]) {
            ((AlignmentLabel*)self.label).verticalAlignment = (VerticalAlignment)[obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }
    }];
    return data;
}

@end
