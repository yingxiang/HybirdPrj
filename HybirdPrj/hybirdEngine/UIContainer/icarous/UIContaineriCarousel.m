//
//  UIContaineriCarousel.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContaineriCarousel.h"
#import <iCarousel/iCarousel.h>

@interface UIContaineriCarousel()<iCarouselDataSource,iCarouselDelegate>

nonatomic_strong(iCarousel,           *icarousel);
nonatomic_strong(NSArray,             *dataSource);

@end

@implementation UIContaineriCarousel


- (void)createView:(NSDictionary *)dict{
    self.view = _obj_alloc(iCarousel)
    self.cells = [dict objectForKey:@"cells"];
    if (dict[@"dataSource"]) {
        self.dataSource = [dict objectForKey:@"dataSource"];
    }
    self.icarousel.delegate = self;
    self.icarousel.dataSource = self;
}

- (void)setView:(id )view{
    [super setView:view];
    _icarousel = view;
}

- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    [self reload];
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"type"]) {
            self.icarousel.type = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"perspective"]){
            self.icarousel.perspective = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"decelerationRate"]){
            self.icarousel.decelerationRate = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollSpeed"]){
            self.icarousel.scrollSpeed = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"bounceDistance"]){
            self.icarousel.bounceDistance = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollEnabled"]){
            self.icarousel.scrollEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"pagingEnabled"]){
            self.icarousel.pagingEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"vertical"]){
            self.icarousel.vertical = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"bounces"]){
            self.icarousel.bounces = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollOffset"]){
            self.icarousel.scrollOffset = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"contentOffset"]){
            self.icarousel.contentOffset = CGSizeFromString(obj);
        }else if ([key isEqualToString:@"viewpointOffset"]){
            self.icarousel.viewpointOffset = CGSizeFromString(obj);
        }else if ([key isEqualToString:@"currentItemIndex"]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.icarousel.currentItemIndex = [[self calculate:obj] obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
            });
        }else if ([key isEqualToString:@"autoscroll"]){
            self.icarousel.autoscroll = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"stopAtItemBoundary"]){
            self.icarousel.stopAtItemBoundary = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"scrollToItemBoundary"]){
            self.icarousel.scrollToItemBoundary = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"ignorePerpendicularSwipes"]){
            self.icarousel.ignorePerpendicularSwipes = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"centerItemWhenSelected"]){
            self.icarousel.centerItemWhenSelected = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }
    }];
    return data;
}

- (void)reload{
    [self.icarousel reloadData];
}

#pragma mark - iCarouselDataSource & iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return self.dataSource.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    if (!view.container) {
        NSDictionary *dic= self.cells[0];
        UIContainerView *containerCell = [UIContainerHelper createViewContainerWithDic:self.jsonData[@"cells"][0]];
        NSString *cellIdentify = [NSString stringWithFormat:@"%@_%ld",dic[@"identify"],(long)index];
        containerCell.identify = cellIdentify;
        containerCell.superContainer = self;
        [containerCell setUI:containerCell.jsonData];
        view = containerCell.view;
    }
    [view.container updateView:self.parseCell :self.dataSource[index]];
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    UIView *cell = [carousel itemViewAtIndex:index];
    UIContainerView *containerCell = cell.container;
    NSMutableDictionary *function = [[containerCell.functionList objectForKey:containerCell.identify] obj_copy];
    if (function) {
        NSDictionary *data = self.dataSource[index];
        if (data[@"changeFunction"]) {
            [function addEntries:data[@"changeFunction"]];
        }
        
        //参数
        __weak typeof(carousel)weakCarousel = carousel;
        [function setValue:weakCarousel forKey:@"parmer1"];
        [function setValue:[NSNumber numberWithInteger:index] forKey:@"parmer2"];
        
        runFunction(function, containerCell);
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    NSMutableDictionary *function = [[self.functionList objectForKey:@"carouselCurrentItemIndexDidChange:"] obj_copy];
    if (function) {
        //参数
        __weak typeof(carousel)weakCarousel = carousel;
        [function setObject:weakCarousel forKey:@"parmer1"];
        runFunction(function, self);
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    NSMutableDictionary *function = [[self.functionList objectForKey:@"carouselDidScroll:"] obj_copy];
    if (function) {
        //参数
        __weak typeof(carousel)weakCarousel = carousel;
        [function setObject:weakCarousel forKey:@"parmer1"];
        runFunction(function, self);
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    NSMutableDictionary *function = [[self.functionList objectForKey:@"carouselDidEndScrollingAnimation:"] obj_copy];
    if (function) {
        //参数
        __weak typeof(carousel)weakCarousel = carousel;
        [function setObject:weakCarousel forKey:@"parmer1"];
        runFunction(function, self);
    }
}

@end
