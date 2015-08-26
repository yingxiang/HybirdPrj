//
//  UIContainerImageView.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerImageView.h"
#import "NSString+TPCategory.h"

@interface UIContainerImageView()

nonatomic_strong(UIImageView, *imageView);

@end

@implementation UIContainerImageView

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UIImageView)
}

- (void)setView:(id )view{
    [super setView:view];
    _imageView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"image"]) {
            __block UIActivityIndicatorView *progress = (UIActivityIndicatorView*)[self.imageView viewWithTag:97];
            if (!progress) {
                progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [progress startAnimating];
                [self.imageView addSubview:progress];
                progress.center = self.imageView.center;
            }

            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.imageView.image = image;
                [progress stopAnimating];
                progress = nil;
            }];
        }else if ([key isEqualToString:@"highlightedImage"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.imageView.highlightedImage = image;
            }];
        }else if ([key isEqualToString:@"animationImages"]) {
            NSMutableArray *animationImages = [NSMutableArray array];
            for (NSString *tmp in obj) {                
                NSString *name = [self assignment:tmp :data];
                [UIImage imageByPath:name image:^(UIImage *image) {
                    [animationImages addObject:image];
                }];
            }
            self.imageView.animationImages = animationImages;
        }else if ([key isEqualToString:@"animationDuration"]) {
            self.imageView.animationDuration = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"animationRepeatCount"]) {
            self.imageView.animationRepeatCount = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }
    }];
    return data;
}

@end
