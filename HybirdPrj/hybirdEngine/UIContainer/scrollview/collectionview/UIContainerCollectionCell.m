//
//  UIContainerCollectionCell.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerCollectionCell.h"

@interface UIContainerCollectionCell()

@end

@implementation UIContainerCollectionCell

- (void)createView:(NSDictionary*)dict
{
    self.cell = _obj_alloc(UICollectionViewCell)
}

- (void)setCell:(UICollectionViewCell *)cell{
    _cell = cell;
    cell.container = self;
}

- (UIView*)view{
    return _cell.contentView;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj  :data];
        
        if ([key isEqualToString:@"backgroundView"]) {
            UIContainerView *backgroundView = newContainer(obj);
            backgroundView.superContainer = self;
            self.cell.backgroundView = backgroundView.view;
            [backgroundView setUI:obj];
        }else if([key isEqualToString:@"selectedBackgroundView"]){
            UIContainerView *selectedBackgroundView = newContainer(obj);
            selectedBackgroundView.superContainer = self;
            self.cell.selectedBackgroundView = selectedBackgroundView.view;
        }
    }];
    return data;
}

@end
