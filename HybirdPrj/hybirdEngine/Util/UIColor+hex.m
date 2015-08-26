//
//  UIColor+hex.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIColor+hex.h"

@implementation UIColor (hex)

//0x88888865  //后两位表示alpha值
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    if (![stringToConvert isKindOfClass:[NSString class]]) {
        showException(stringToConvert);
        return [UIColor clearColor];
    }
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) return [UIColor clearColor];
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8) return [UIColor clearColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    unsigned int  a = 255;
    if ([cString length] == 8) {
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
    }
    
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

@end
