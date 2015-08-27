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
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:readFile(_HYBIRD_PATH_DATA, @"NSLocalizedString")];
        [self setObject:dic forKey:@"NSLocalizedString"];
        self.localStringList = dic;
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:readFile(_HYBIRD_PATH_DATA, @"NSModelDataCenter")];
        [self setObject:data forKey:@"NSModelDataCenter"];
        self.dataList = data;
    }
    return self;
}

- (void)synchronizeData{
    [self.dataList writeToFile:[_HYBIRD_PATH_DATA stringByAppendingPathComponent:@"NSModelDataCenter"] atomically:YES];
}


- (NSString*)baseUrl{
    if (!_baseUrl) {
        BOOL isDebug = [self.dataList[@"environmentDebug"] obj_bool:nil];
        if (isDebug) {
            _baseUrl = self.dataList[@"url_debug"];
        }
        _baseUrl = self.dataList[@"url_release"];
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
