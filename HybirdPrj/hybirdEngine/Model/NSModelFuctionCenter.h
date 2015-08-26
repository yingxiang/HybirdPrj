//
//  NSModelFuctionCenter.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/31.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"

@class UIContainerWindow;

typedef enum {
    TELEPHONY_NET_UNKNOW,
    TELEPHONY_NET_2G,
    TELEPHONY_NET_3G,
    TELEPHONY_NET_4G,
    TELEPHONY_NET_WIFI,
    TELEPHONY_NET_NONE
}TELEPHONY_NET_STATUS;

@interface NSModelFuctionCenter : NSModel

nonatomic_strong(UIContainerWindow,   *statusWindowContainer)

DECLARE_AS_SINGLETON(NSModelFuctionCenter);

- (TELEPHONY_NET_STATUS)currentTelephonyNet;

- (void)showTips:(NSString*)tips;

- (NSUInteger)cacheSize;

- (void)deleteCache;

- (void)checkUpdate;

@end
