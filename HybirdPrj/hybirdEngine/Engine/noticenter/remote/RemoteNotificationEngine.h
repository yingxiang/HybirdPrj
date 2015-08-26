//
//  RemoteNotificationEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"

@interface RemoteNotificationEngine : NSModel

DECLARE_AS_SINGLETON(RemoteNotificationEngine);

- (void)registerRemoteNotification;

- (void)updateToken:(NSString*)token;

- (void)didReceiveRemoteNotification:(NSDictionary*)userInfo;

@end
