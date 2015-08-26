//
//  StartManage.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/27.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "StartManage.h"
#import "RemoteNotificationEngine.h"
#import "UserAgent.h"
#import "URLCache.h"

OBJC_EXPORT void replaceClass();

#define COPY_ANYTIME @"YES"

@implementation StartManage

+ (BOOL)startApplication:(Block_complete)complete{
    
    replaceClass();

    //启用设备横竖屏监听
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    
    //判断设备（iphone/ipad）
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_isIpad ?@"hybird_ipad.bundle" :@"hybird_iphone.bundle"];
    NSError *error = nil;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        
    }else {
        NSLog(@"原始路径不存在");
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_HYBIRD_PATH_LIBRARY]) {
#ifdef COPY_ANYTIME
        [[NSFileManager defaultManager] removeItemAtPath:_HYBIRD_PATH_LIBRARY error:nil];
        
        if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:_HYBIRD_PATH_LIBRARY error:&error]) {
            NSLog(@"error --- >%@",error);
            NSString *msg = [NSString stringWithFormat:@"%@",error];
            showException( msg);
            return NO;
        }
#endif
    }else{
        if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:_HYBIRD_PATH_LIBRARY error:&error]) {
            NSLog(@"error --- >%@",error);
            NSString *msg = [NSString stringWithFormat:@"%@",error];
            showException(msg);
            return NO;
        }
    }

    //获取useragent
    [[UserAgent shareInstance] fetchUserAgent];
    
    //启动视图控制
    [UIViewControllerHelper shareInstance];
    
    //创建window
    [UIContainerWindow containerWindow];
    
    //启动url缓存
    [[URLCache shareInstance] cache];
    
    BOOL launch = [StartManage restartApplication];
    if (launch) {
        [[ShareEngine shareInstance] registerApp];
        [[NSModelFuctionCenter shareInstance] checkUpdate];
        [[RemoteNotificationEngine shareInstance] registerRemoteNotification];
    }
    if (complete) {
        complete(launch,nil);
    }
    return launch;
}

+ (BOOL)restartApplication{
    //
    UIApplication *application = [UIApplication sharedApplication];
    
    NSDictionary *vcDic =  readFile(_HYBIRD_START_PATH, nil);
    UIViewController *vc = [UIViewControllerHelper creatViewController:vcDic];
    if (vc) {
        [[application.delegate window] setRootViewController:vc];
        return YES;
    }
    return NO;
}

@end
