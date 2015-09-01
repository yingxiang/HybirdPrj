//
//  UIImage+path.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/27.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIImage+path.h"
#import "NSString+TPCategory.h"
#import "SDWebImageManager.h"

@implementation UIImage (path)

+ (void)imageByPath:(id)path image:(imageCompletedBlock)block{
    UIImage *image = nil;
    if ([path isKindOfClass:[NSString class]]) {
        if ([path isURLString]) {
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:path] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (error) {
                    showException(path);
                }
                block(image);
            }];
        }else{
            image = [UIImage imageWithContentsOfFile:[_HYBIRD_PATH_IMAGE stringByAppendingPathComponent:path]];

            if (image) {
                block(image);
            }else {
                if ([UIScreen mainScreen].scale == 1) {
                    NSArray *array = [path componentsSeparatedByString:@"."];
                    if (array.count == 1) {
                        path = [NSString stringWithFormat:@"%@@2x",array[0]];
                    }else {
                        path = [NSString stringWithFormat:@"%@@2x.%@",array[[array count]-2],[array lastObject]];
                    }
                    image = [UIImage imageWithContentsOfFile:[_HYBIRD_PATH_IMAGE stringByAppendingPathComponent:path]];
                    if (image) {
                        block(image);
                    }else{
                        showException(path);
                        block(nil);
                    }
                }else {
                    showException(path);
                    block(nil);
                }
            }
        }
    }else if([path isKindOfClass:[UIImage class]]){
        image = path;
        block(image);
    }
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGFloat)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
