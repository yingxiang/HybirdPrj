//
//  LocalNotificationEngine.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/24.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "LocalNotificationEngine.h"
#import "NSDate+TPCategory.h"

@implementation LocalNotificationEngine

DECLARE_SINGLETON(LocalNotificationEngine)

- (void)registerLocalNotification:(NSDictionary*)info{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [obj assignment:obj :info];
        if ([key isEqualToString:@"fireDate"]) {
            notification.fireDate = [NSDate dateFromString:obj withFormat:@"yyyy-MM-dd HH:mm:ss"];
        }else if ([key isEqualToString:@"alertBody"]){
            notification.alertBody = obj;
        }else if ([key isEqualToString:@"alertAction"]){
            notification.alertAction = obj;
        }else if ([key isEqualToString:@"alertLaunchImage"]){
            notification.alertLaunchImage = obj;
        }else if ([key isEqualToString:@"alertTitle"]){
            notification.alertTitle = obj;
        }else if ([key isEqualToString:@"applicationIconBadgeNumber"]){
            notification.applicationIconBadgeNumber = [obj obj_integer:nil];
        }else if ([key isEqualToString:@"soundName"]){
            notification.soundName = obj;//UILocalNotificationDefaultSoundName
        }else if ([key isEqualToString:@"userInfo"]){
            notification.userInfo = obj;
        }
    }];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification{
    NSMutableDictionary *function = [[[NSModelFuctionCenter shareInstance] objectForKey:@"didReceiveLocalNotification:"] obj_copy];
    if (function) {
        [function setObject:notification forKey:@"notification"];
        runFunction(function, [UIContainerWindow containerWindow]);
    }
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

@end
