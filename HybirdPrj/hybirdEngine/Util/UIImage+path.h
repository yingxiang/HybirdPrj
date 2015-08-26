//
//  UIImage+path.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/27.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^imageCompletedBlock)(UIImage *image);

@interface UIImage (path)

+ (void)imageByPath:(id)path image:(imageCompletedBlock)block;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGFloat)scaleSize;

@end
