//
//  NSModel.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/14.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"

@interface NSModel()

@end

@implementation NSModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _modelList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)setObject:(id)obj forKey:(NSString*)aKey{
    if (obj && aKey) {
        [_modelList setObject:obj forKey:aKey];
        return YES;
    }
    return NO;
}

- (id)objectForKey:(NSString*)aKey{
    if (aKey) {
        return _modelList[aKey];
    }
    return nil;
}

@end
