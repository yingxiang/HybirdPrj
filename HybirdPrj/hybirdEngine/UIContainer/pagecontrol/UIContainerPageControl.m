//
//  UIContainerPageControl.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/21.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerPageControl.h"

@interface UIContainerPageControl()

nonatomic_strong(UIPageControl, *pageControl);

@end

@implementation UIContainerPageControl

- (void)createView:(NSDictionary *)dict{
    self.view = _obj_alloc(UIPageControl)
}

- (void)setView:(id )view{
    [super setView:view];
    _pageControl = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"numberOfPages"]) {
            self.pageControl.numberOfPages = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"currentPage"]){
            self.pageControl.currentPage = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"hidesForSinglePage"]){
            self.pageControl.hidesForSinglePage = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"defersCurrentPageDisplay"]){
            self.pageControl.defersCurrentPageDisplay = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"pageIndicatorTintColor"]){
            self.pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"currentPageIndicatorTintColor"]){
            self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:obj];
        }
    }];
    return data;
}
@end
