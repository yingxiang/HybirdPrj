//
//  UIContainerButtonItem.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerButtonItem.h"

@interface UIContainerButtonItem()

nonatomic_weak(UIBarButtonItem, *buttonItem);

@end

@implementation UIContainerButtonItem

- (void)createView:(NSDictionary*)dict
{
    if (dict[@"image"]) {
        [UIImage imageByPath:dict[@"image"] image:^(UIImage *image) {
            self.item = (id)[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(eventTouchUpInside)];
        }];
    }else if (dict[@"title"]){
        self.item = [[UIBarButtonItem alloc] initWithTitle:dict[@"title"] style:UIBarButtonItemStylePlain target:self action:@selector(eventTouchUpInside)];
    }else if(dict[@"customView"]){
        UIContainerView *customView = [UIContainerHelper createViewContainerWithDic:dict[@"customView"]];
        customView.superContainer = self;
        self.item = [[UIBarButtonItem alloc] initWithCustomView:customView.view];
        [customView setUI:dict[@"customView"]];
    }
}

- (void)setItem:(id)item{
    [super setItem:item];
    _buttonItem = item;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [data obj_copy];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"tintColor"]) {
            self.buttonItem.tintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"UIControlStateNormal"]){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (obj[@"font"]) {
                NSString *font = [self assignment:obj[@"font"] :data];
                
                [dic setObject:[UIFont systemFontOfSize:[[self calculate:font]obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }]] forKey:NSFontAttributeName];
            }
            if (obj[@"titleColor"]) {
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];

                [dic setObject:[UIColor colorWithHexString:titleColor] forKey:NSForegroundColorAttributeName];
            }
            [self.buttonItem setTitleTextAttributes:dic forState:UIControlStateNormal];
        }else if ([key isEqualToString:@"UIControlStateDisabled"]){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (obj[@"font"]) {
                NSString *font = [self assignment:obj[@"font"] :data];
                
                [dic setObject:[UIFont systemFontOfSize:[[self calculate:font] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }]] forKey:NSFontAttributeName];
            }
            if (obj[@"titleColor"]) {
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];
                
                [dic setObject:[UIColor colorWithHexString:titleColor] forKey:NSForegroundColorAttributeName];
            }
            [self.buttonItem setTitleTextAttributes:dic forState:UIControlStateDisabled];
        }else if ([key isEqualToString:@"UIControlStateHighlighted"]){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (obj[@"font"]) {
                NSString *font = [self assignment:obj[@"font"] :data];
                
                [dic setObject:[UIFont systemFontOfSize:[[self calculate:font ] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }]] forKey:NSFontAttributeName];
            }
            if (obj[@"titleColor"]) {
                NSString *titleColor = [self assignment:obj[@"titleColor"] :data];
                
                [dic setObject:[UIColor colorWithHexString:titleColor] forKey:NSForegroundColorAttributeName];
            }
            [self.buttonItem setTitleTextAttributes:dic forState:UIControlStateHighlighted];
        }
    }];
    return data;
}

@end
