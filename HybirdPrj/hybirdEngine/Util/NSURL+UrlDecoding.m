//
//  NSURL+UrlDecoding.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/27.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSURL+UrlDecoding.h"
#import "NSString+TPCategory.h"

@implementation NSURL (UrlDecoding)

+ (NSURL*)ENCODEURLWithString:(NSString*)aString{
    NSString *string = [aString URLString];
    return [NSURL ENCODEURLWithString:string];
}

@end
