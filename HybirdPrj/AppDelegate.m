//
//  AppDelegate.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "AppDelegate.h"
#import <MobClick.h>
#import "StartManage.h"
#import "ShareEngine.h"
#import "RemoteNotificationEngine.h"
#import "LocalNotificationEngine.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static void uncaughtExceptionHandler(NSException *exception) {
    NSString *msg = [NSString stringWithFormat:@"%@",exception.callStackSymbols];
    showException(msg);
}

#pragma mark - AppStart

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //启动app
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    return [StartManage startApplication:^(BOOL success, id data) {
        if (success && launchOptions != nil) {
            NSDictionary *dic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (dic) {
                [self application:application didReceiveRemoteNotification:dic];
            }
        }
    }];
}

#pragma mark - LifeCircle

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - RemoteNotification
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
//    //ios8
//    
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //ios3
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[RemoteNotificationEngine shareInstance] updateToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    showException(error.userInfo[NSLocalizedDescriptionKey]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[RemoteNotificationEngine shareInstance] didReceiveRemoteNotification:userInfo];
}

#pragma mark - LocalNotification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[LocalNotificationEngine shareInstance] didReceiveLocalNotification:notification];
}

#pragma mark - Handle openUrl
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[ShareEngine shareInstance] handle:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[ShareEngine shareInstance] handle:url];
}

@end
