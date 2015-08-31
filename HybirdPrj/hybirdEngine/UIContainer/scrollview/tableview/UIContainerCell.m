//
//  UIContainerCell.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerCell.h"

@interface UIContainerCell()

@end

@implementation UIContainerCell

- (void)createView:(NSDictionary*)dict
{
    NSString* cellStyleStr = [dict objectForKey:@"cellStyle"];
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    if (cellStyleStr) {
        cellStyle = [cellStyleStr obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"cellStyle", cellStyleStr);
            }
        }];
    }
    self.cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:self.identify];
    //兼容ios7（ios7布局减小（高度/宽度）不能小于cell高度，否则crash）
    self.cell.contentView.frame = CGRectMake(0, 0, 1000, 1000);
}

- (void)setCell:(UITableViewCell *)cell{
    _cell = cell;
    cell.container = self;
}

- (UIView*)view{
    return _cell.contentView;
}

- (void)update:(NSDictionary*)data{
    
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"backgroundView"]) {
            UIContainerView *container = newContainer(obj);
            container.superContainer = self;
            [container setUI:obj];
            self.cell.backgroundView = container.view;
        }else if ([key isEqualToString:@"selectedBackgroundView"]){
            UIContainerView *container = newContainer(obj);
            container.superContainer = self;
            [container setUI:obj];
            self.cell.selectedBackgroundView = container.view;
        }else if ([key isEqualToString:@"selectionStyle"]){
            self.cell.selectionStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"accessoryType"]){
            self.cell.accessoryType = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"accessoryView"]){
            UIContainerView *container = newContainer(obj);
            container.superContainer = self;
            [container setUI:obj];
            self.cell.accessoryView = container.view;
        }else if ([key isEqualToString:@"editingAccessoryType"]){
            self.cell.editingAccessoryType = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"editingAccessoryView"]){
            UIContainerView *container = newContainer(obj);
            container.superContainer = self;
            [container setUI:obj];
            self.cell.editingAccessoryView = container.view;
        }else if([key isEqualToString:@"imageView"]){
            UIContainerView *container = self.cell.imageView.container;
            if (!container) {
                container = newContainer(obj);
                container.view = self.cell.imageView;
                container.superContainer = self;
            }
            [container setUI:obj];
        }else if([key isEqualToString:@"textLabel"]){
            UIContainerView *container = self.cell.textLabel.container;
            if (!container) {
                container = newContainer(obj);
                container.view = self.cell.textLabel;
                container.superContainer = self;
            }
            [container setUI:obj];
        }else if([key isEqualToString:@"detailTextLabel"]){
            UIContainerView *container = self.cell.detailTextLabel.container;
            if (!container) {
                container = newContainer(obj);
                container.view = self.cell.detailTextLabel;
                container.superContainer = self;
            }
            [container setUI:obj];
        }else if([key isEqualToString:@"contentView"]){
            UIContainerView *container = newContainer(obj);
            container.view = self.cell.contentView;
            container.superContainer = self;
            [container setUI:obj];
        }
    }];
    return data;
}

@end
