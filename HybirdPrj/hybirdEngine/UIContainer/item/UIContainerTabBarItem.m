//
//  UIContainerTabBarItem.m
//  HybirdPrj
//
//  Created by xiang ying on 15/8/16.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTabBarItem.h"

@interface UIContainerTabBarItem ()

nonatomic_weak(UITabBarItem, *tabBarItem)

@end

@implementation UIContainerTabBarItem

- (void)createView:(NSDictionary *)dict{
    NSString *title = dict[@"title"];
    __block UIImage *normalimage = nil;
    __block UIImage *selectImage = nil;
    [UIImage imageByPath:dict[@"image"] image:^(UIImage *image) {
        normalimage = image;
    }];
    
    [UIImage imageByPath:dict[@"selectImage"] image:^(UIImage *image) {
        selectImage = image;
    }];
    self.item = [[UITabBarItem alloc] initWithTitle:title image:normalimage selectedImage:selectImage];
    normalimage = nil;
    selectImage = nil;
}

- (void)setItem:(id )item{
    [super setItem:item];
    _tabBarItem = item;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"title"]) {
            [self.tabBarItem setTitle:obj];
        }else if ([key isEqualToString:@"image"]){
            [UIImage imageByPath:obj image:^(UIImage *image) {
                [self.tabBarItem setImage:image];
            }];
        }else if ([key isEqualToString:@"selectedImage"]){
            [UIImage imageByPath:obj image:^(UIImage *image) {
                [self.tabBarItem setSelectedImage:image];
            }];
        }else if ([key isEqualToString:@"badgeValue"]){
            self.tabBarItem.badgeValue = obj;
        }else if([key isEqualToString:@"textAttributes"]){
            [self.tabBarItem setTitleTextAttributes:obj[@"UIControlStateNormal"] forState:UIControlStateNormal];
            [self.tabBarItem setTitleTextAttributes:obj[@"UIControlStateSelected"] forState:UIControlStateSelected];
        }
    }];
    [self setSubViewsUI];
    return data;
}
@end
