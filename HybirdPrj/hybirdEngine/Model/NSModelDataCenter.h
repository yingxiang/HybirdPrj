//
//  NSModelDataCenter.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/23.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"

static NSString *const appVersionKey = @"appVersionKey";

@interface NSModelDataCenter : NSModel

nonatomic_weak  (NSMutableDictionary, *dataList)
nonatomic_weak  (NSMutableDictionary, *localStringList)
nonatomic_strong(NSString           , *baseUrl)

DECLARE_AS_SINGLETON(NSModelDataCenter);

- (void)synchronizeData;

#pragma mark - systerm instance
//仅在hybird遍历查找时使用
nonatomic_weak(NSFileManager        , *defaultManager)
nonatomic_weak(UIApplication        , *sharedApplication)
nonatomic_weak(NSNotificationCenter , *defaultCenter)
nonatomic_weak(UIDevice             , *currentDevice)
nonatomic_weak(NSUserDefaults       , *standardUserDefaults)

@end
