//
//  RemoteNotificationEngine.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "RemoteNotificationEngine.h"
#import "UserAgent.h"

@interface RemoteNotificationEngine()

nonatomic_weak(UIApplication, *application);

@end

@implementation RemoteNotificationEngine

DECLARE_SINGLETON(RemoteNotificationEngine)

- (instancetype)init{
    self = [super init];
    if (self) {
        self.application = [UIApplication sharedApplication];
    }
    return self;
}

//注册远程通知
- (void)registerRemoteNotification
{
    if ([self.application respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        
        [self.application registerUserNotificationSettings:[UIUserNotificationSettings
                                                       settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                       categories:nil]];
        
        
        [self.application registerForRemoteNotifications];
    }
    else
    {
        [self.application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                               UIRemoteNotificationTypeSound |
                                                                               UIRemoteNotificationTypeAlert)];
    }
}

- (void)updateToken:(NSString*)token{
    if (token == nil) {
        token = [[NSModelDataCenter shareInstance] dataForKey:@"token"];
    }else{
        [[NSModelDataCenter shareInstance] synchronizeObject:token forKey:@"token"];
    }
    if (token) {
        [[UserAgent shareInstance] registerToken:token];
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary*)userInfo{
    NSMutableDictionary *function = [[[NSModelFuctionCenter shareInstance] objectForKey:@"didReceiveRemoteNotification:"] obj_copy];
    if (function) {
        [function setObject:userInfo forKey:@"userInfo"];
        runFunction(function, [UIContainerWindow containerWindow]);
    }
    //UIApplicationState state = self.application.applicationState;
}

@end
