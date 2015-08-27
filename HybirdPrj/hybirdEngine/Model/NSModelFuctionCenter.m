//
//  NSModelFuctionCenter.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/31.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModelFuctionCenter.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "AppDelegate.h"
#import <MobClick.h>

@interface NSModelFuctionCenter()

@end

@implementation NSModelFuctionCenter

DECLARE_SINGLETON(NSModelFuctionCenter);

- (instancetype)init{
    self = [super init];
    if (self) {
        self.statusWindowContainer;
        NSDictionary *dic = readFile(_HYBIRD_PATH_DATA, @"NSModelFuctionCenter");
        if (dic) {
            [self.modelList addEntries:dic];
        }
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSString *tips = nil;
            if ([self currentTelephonyNet] == TELEPHONY_NET_2G) {
                tips = [NSModelDataCenter shareInstance].localStringList[@"STRING_2G"];
            }else if ([self currentTelephonyNet] == TELEPHONY_NET_3G){
                tips = [NSModelDataCenter shareInstance].localStringList[@"STRING_3G"];
            }else if ([self currentTelephonyNet] == TELEPHONY_NET_4G){
                tips = [NSModelDataCenter shareInstance].localStringList[@"STRING_4G"];
            }else if ([self currentTelephonyNet] == TELEPHONY_NET_WIFI){
                tips = [NSModelDataCenter shareInstance].localStringList[@"STRING_WIFI"];
            }else if ([self currentTelephonyNet] == TELEPHONY_NET_NONE){
                tips = [NSModelDataCenter shareInstance].localStringList[@"STRING_NONET"];
            }
            _hybird_tips_(tips)
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (UIContainerWindow*)statusWindowContainer{
    
    UIInterfaceOrientation interfaceOrientation = [[UIViewControllerHelper shareInstance] getCurrentViewController].interfaceOrientation;

    if (!_statusWindowContainer) {
        _statusWindowContainer = [UIContainerHelper createViewContainerWithDic:@{@"identify":@"~/statusWindow"}];
        [_statusWindowContainer setUI:_statusWindowContainer.jsonData];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            _statusWindowContainer.view.center = CGPointMake(_statusWindowContainer.view.center.y, _statusWindowContainer.view.center.x);
        }
    }
    [_statusWindowContainer toInterfaceOrientation:interfaceOrientation];

    return _statusWindowContainer;
}

- (TELEPHONY_NET_STATUS)currentTelephonyNet{
    switch ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return TELEPHONY_NET_WIFI;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            CTTelephonyNetworkInfo *networkStatus = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = networkStatus.currentRadioAccessTechnology;
            if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]||
                [currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]||
                [currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
                return TELEPHONY_NET_2G;
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
                return TELEPHONY_NET_4G;
            }else {
                return TELEPHONY_NET_3G;
            }
        }
        case AFNetworkReachabilityStatusNotReachable:{
            return TELEPHONY_NET_NONE;
        }
        case AFNetworkReachabilityStatusUnknown:
            return TELEPHONY_NET_UNKNOW;
        default:
            break;
    }

    return TELEPHONY_NET_UNKNOW;
}

- (void)showTips:(NSString*)tips{
    if (tips) {
        [self runbackground:tips selector:^(BOOL success, id data) {
            while (!self.statusWindowContainer.view.isHidden) {

            }
            NSMutableDictionary *function = [self.statusWindowContainer.functionList[@"show"] obj_copy];
            if (function) {
                [function setObject:tips forKey:@"parmer1"];
                [self runmain:function selector:^(BOOL success, id data) {
                    runFunction(data, self.statusWindowContainer);
                }];
            }
        }];
    }
}

- (NSUInteger)cacheSize{
    return [[NSURLCache sharedURLCache] currentDiskUsage];
}

- (void)deleteCache{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)checkUpdate{
    //友盟
    NSString * UMENG_APPKEY  = _infoDictionary[@"UMENG_APPKEY"];
    if (UMENG_APPKEY) {
        [MobClick setAppVersion:[NSModelDataCenter shareInstance].dataList[appVersionKey]];
        
        [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
        [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
    }else{
        showException(@"没有配置友盟appkey");
    }
}

- (void)appUpdate:(NSDictionary *)appInfo{
    if ([appInfo[@"update"] obj_bool:nil]) {
        NSString *updateString = appInfo[@"update_log"];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[updateString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            //内部本地更新
            NSString *url = [dic[@"url"] stringByAppendingString:_isIpad ? @"ipad.zip":@"iphone.zip"];
            NSString *msg = dic[@"msg"];
            [BaseAlertView alertWithTitle:@"新版本更新" message:msg clickIndex:^(NSInteger index) {
                if (index == 1) {
                    //启动下载更新
                    NSMutableDictionary *dic = [readFile(_HYBIRD_PATH_VIEW, @"updateView") obj_copy];
                    if (dic) {
                        UIContainerView *container = [UIContainerHelper createViewContainerWithDic:dic];
                        if (container) {
                            [[container.functionList objectForKey:@"setUI:"] setValue:url forKey:@"url"];
                            [[UIContainerWindow containerWindow] addSubContainer:container data:dic];
                        }
                    }
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@[@"立即更新"]];
        }else{
            //大版本更新 直接去appstore下载
            [BaseAlertView alertWithTitle:@"新版本更新" message:updateString clickIndex:^(NSInteger index) {
                if (index == 1) {
                    NSString *url = appInfo[@"path"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@[@"前往下载"]];
        }
    }
}

@end
