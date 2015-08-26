//
//  NSModelDataCenter.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/23.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModelDataCenter.h"

@implementation NSModelDataCenter

DECLARE_SINGLETON(NSModelDataCenter);

- (instancetype)init{
    self = [super init];
    if (self) {
        NSDictionary *dic = readFile(_HYBIRD_PATH_DATA, @"NSLocalizedString");
        [self setObject:dic forKey:@"NSLocalizedString"];
        
        NSDictionary *data = readFile(_HYBIRD_PATH_DATA, @"NSModelDataCenter");
        [self setObject:data forKey:@"NSModelDataCenter"];
    }
    return self;
}

- (NSString*)localStringForkey:(NSString*)aKey{
    NSDictionary *dic = [self objectForKey:@"NSLocalizedString"];
    return dic[aKey];
}

- (id)dataForKey:(NSString*)aKey{
    NSDictionary *dic = [self objectForKey:@"NSModelDataCenter"];
    return dic[aKey];
}

- (void)synchronizeObject:(id)object forKey:(NSString*)aKey{
    if (object && aKey) {
        NSDictionary *dic = [self objectForKey:@"NSModelDataCenter"];
        [dic setValue:object forKey:aKey];
        [dic writeToFile:[_HYBIRD_PATH_DATA stringByAppendingPathComponent:@"NSModelDataCenter"] atomically:YES];
    }
}

- (NSString*)baseUrl{
    if (!_baseUrl) {
        BOOL isDebug = [[self dataForKey:@"environmentDebug"] obj_bool:nil];
        if (isDebug) {
            _baseUrl = [self dataForKey:@"url_debug"];
        }
        _baseUrl = [self dataForKey:@"url_release"];
    }
    return _baseUrl;
}


#pragma mark - systerm instance
- (NSFileManager*)defaultManager{
    return [NSFileManager defaultManager];
}

- (UIApplication*)sharedApplication{
    return [UIApplication sharedApplication];
}

- (NSNotificationCenter*)defaultCenter{
    return [NSNotificationCenter defaultCenter];
}

- (UIDevice*)currentDevice{
    return [UIDevice currentDevice];
}

- (NSUserDefaults*)standardUserDefaults{
    return [NSUserDefaults standardUserDefaults];
}

@end
