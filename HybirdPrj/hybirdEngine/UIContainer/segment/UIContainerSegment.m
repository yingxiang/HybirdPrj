//
//  UIContainerSegment.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/1.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerSegment.h"

@interface UIContainerSegment()

nonatomic_strong(UISegmentedControl, *segmentControl);

@end

@implementation UIContainerSegment

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UISegmentedControl)
    [self.segmentControl addTarget:self action:@selector(eventValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setView:(id )view{
    [super setView:view];
    _segmentControl = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"selectedSegmentIndex"]) {
            self.segmentControl.selectedSegmentIndex = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"tintColor"]) {
            self.segmentControl.tintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"UIControlState"]) {
        }else if ([key isEqualToString:@"titles"]) {
            for (int i = 0;i<[obj count]; i++) {
                NSString *title = obj[i];
                [self.segmentControl insertSegmentWithTitle:title atIndex:i animated:NO];
            }
        }else if ([key isEqualToString:@"images"]) {
            for (int i = 0;i<[obj count]; i++) {
                NSString *imageName = obj[i];
                imageName = [self assignment:imageName :data];
                [UIImage imageByPath:imageName image:^(UIImage *image) {
                    [self.segmentControl insertSegmentWithImage:image atIndex:i animated:NO];
                }];
            }
        }
    }];
    return data;
}

@end
