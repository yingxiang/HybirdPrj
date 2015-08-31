//
//  UIContainerItem.m
//  HybirdPrj
//
//  Created by xiang ying on 15/8/15.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerItem.h"

@interface UIContainerItem ()

@end

@implementation UIContainerItem

- (void)createView:(NSDictionary *)dict{
    self.item = _obj_alloc(UIBarItem);
}

- (void)setItem:(UIBarItem *)item{
    _item = item;
    item.container = self;
}

- (UIView*)view{
    UIView *_view = self.item.view;
    if (_view.viewController!=self.item.viewController) {
        _view.viewController = self.item.viewController;
    }
    return _view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [data obj_copy];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"subViews"]) {
            for (NSDictionary* dict in obj) {
                UIContainerView *container = self.subViews[dict[@"identify"]];
                if (!container) {
                    container = newContainer(dict);
                }
                [self addSubContainer:container data:dict];
            }
        }else if ([key isEqualToString:@"enabled"]) {
            self.item.enabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj)
                }
            }];
        }else if ([key isEqualToString:@"title"]){
            self.item.title = obj;
        }else if ([key isEqualToString:@"image"]){
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.item.image = image;
            }];
        }else if ([key isEqualToString:@"landscapeImagePhone"]){
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.item.landscapeImagePhone = image;
            }];
        }else if ([key isEqualToString:@"imageInsets"]){
            self.item.imageInsets = UIEdgeInsetsFromString(obj);
        }else if ([key isEqualToString:@"landscapeImagePhoneInsets"]){
            self.item.landscapeImagePhoneInsets = UIEdgeInsetsFromString(obj);
        }else if ([key isEqualToString:@"tag"]){
            self.item.tag = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj)
                }
            }];
        }
    }];
    return data;
}

- (void)setSubViewsUI{
    for (NSDictionary* dict in self.jsonData[@"subViews"]) {
        UIContainerView *container = self.subViews[dict[@"identify"]];
        if (!container) {
            container = newContainer(dict);
        }
        [self addSubContainer:container data:dict];
    }
}

- (void)setSuperContainer:(UIContainerView *)superContainer{
    [super setSuperContainer:superContainer];
    self.item.viewController = superContainer.view.viewController;
}

@end
