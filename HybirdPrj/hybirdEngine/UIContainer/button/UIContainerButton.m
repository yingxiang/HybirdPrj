//
//  UIContainerButton.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerButton.h"

@interface UIContainerButton()

nonatomic_strong(UIButton, *button);

@end

@implementation UIContainerButton

- (void)createView:(NSDictionary*)dict
{
    self.view = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([self.functionList objectForKey:@"UIControlEventTouchUpInside"]) {
        [self.button addTarget:self action:@selector(eventTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([self.functionList objectForKey:@"UIControlEventTouchDown"]) {
        [self.button addTarget:self action:@selector(eventTouchDown) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)setView:(id)view{
    [super setView:view];
    _button = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"font"]) {
            self.button.titleLabel.font = [UIFont systemFontOfSize:[[self calculate:obj] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }]];
        }else if ([key isEqualToString:@"UIControlStateNormal"]) {
            if (obj[@"title"]) {
                NSString *title = [self assignment:obj[@"title"] :data];
                [self.button setTitle:title forState:UIControlStateNormal];
            }
            if (obj[@"titleColor"]){
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];
                [self.button setTitleColor:[UIColor colorWithHexString:titleColor] forState:UIControlStateNormal];
            }
            if (obj[@"image"]){
                NSString *img = [self assignment:obj[@"image"] :data];
                [UIImage imageByPath:img image:^(UIImage *image) {
                    [self.button setImage:image forState:UIControlStateNormal];
                }];
            }
            if (obj[@"backgroundImage"]){
                NSString *backgroundImage = [self assignment:obj[@"backgroundImage"] :data];
                [UIImage imageByPath:backgroundImage image:^(UIImage *image) {
                    [self.button setBackgroundImage:image forState:UIControlStateNormal];
                }];
            }
        }else if ([key isEqualToString:@"UIControlStateHighlighted"]) {

            if (obj[@"title"]) {
                NSString *title = [self assignment:obj[@"title"] :data];
                [self.button setTitle:title forState:UIControlStateHighlighted];
            }
            if (obj[@"titleColor"]){
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];
                [self.button setTitleColor:[UIColor colorWithHexString:titleColor] forState:UIControlStateHighlighted];
            }
            if (obj[@"image"]){
                NSString *img = [self assignment:obj[@"image"] :data];
                [UIImage imageByPath:img image:^(UIImage *image) {
                    [self.button setImage:image forState:UIControlStateHighlighted];
                }];
            }
            if (obj[@"backgroundImage"]){
                NSString *backgroundImage = [self assignment:obj[@"backgroundImage"] :data];

                [UIImage imageByPath:backgroundImage image:^(UIImage *image) {
                    [self.button setBackgroundImage:image forState:UIControlStateHighlighted];
                }];
            }
        }else if ([key isEqualToString:@"UIControlStateSelected"]) {
            if (obj[@"title"]) {
                NSString *title = [self assignment:obj[@"title"] :data];
                [self.button setTitle:title forState:UIControlStateSelected];
            }
            if (obj[@"titleColor"]){
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];
                
                [self.button setTitleColor:[UIColor colorWithHexString: titleColor] forState:UIControlStateSelected];
            }
            if (obj[@"image"]){
                NSString *img = [self assignment:obj[@"image"] :data];
                
                [UIImage imageByPath:img image:^(UIImage *image) {
                    [self.button setImage:image forState:UIControlStateSelected];
                }];
            }
            if (obj[@"backgroundImage"]){
                NSString *backgroundImage = [self assignment:obj[@"backgroundImage"] :data];
                
                [UIImage imageByPath:backgroundImage image:^(UIImage *image) {
                    [self.button setBackgroundImage:image forState:UIControlStateSelected];
                }];
            }
        }else if ([key isEqualToString:@"enabled"]){
            self.button.enabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"ImageEdgeInsets"]){
            [self.button setImageEdgeInsets:UIEdgeInsetsFromString(obj)];
        }else if ([key isEqualToString:@"TitleEdgeInsets"]){
            [self.button setTitleEdgeInsets:UIEdgeInsetsFromString(obj)];
        }
    }];
    return data;
}

@end
