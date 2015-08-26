//
//  LocalNotificationEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/24.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationEngine : NSObject

DECLARE_AS_SINGLETON(LocalNotificationEngine)

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

@end
