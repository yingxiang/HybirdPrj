//
//  NSModelTimer.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/23.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModelTimer.h"

@implementation NSModelTimer

- (void)creatTimer:(NSDictionary*)dic inConatiner:(UIContainerView*)container{
    NSTimeInterval interval = [[container calculate:dic[@"timeInterval"]] obj_float:^(BOOL success) {
        if (!success) {
            NSString *msg = [NSString stringWithFormat:@"timeInterval [%@ integerValue]\nidentify:%@",dic[@"timeInterval"],container.identify];
            showException(msg);
        }
    }];
    if (interval == 0) {
        interval = 1;
    }
    
    BOOL repeats = [dic[@"repeats"] obj_bool:^(BOOL success) {
        if (!success) {
            NSString *msg = [NSString stringWithFormat:@"repeats [%@ integerValue]\n%@",dic[@"repeats"],container.identify];
            showException(msg);
        }
    }];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(timerAction:) userInfo:container repeats:repeats];
    timer.identify = dic[@"identify"];
    [self.modelList setObject:timer forKey:timer.identify];
    
}

- (void)startTimerForkey:(NSString*)key{
    NSTimer *timer = self.modelList[key];
    if (!timer) {
        showException(key);
    }else{
        [timer fire];
    }
}

- (void)endTimerforKey:(NSString*)key{
    NSTimer *timer = self.modelList[key];
    if (!timer) {
        showException(key);
    }else{
        [timer invalidate];
    }
}


- (void)timerAction:(NSTimer*)timer{
    UIContainerView *conatiner = timer.userInfo;
    if (conatiner) {
        NSMutableDictionary *function = [[conatiner.functionList objectForKey:[NSString stringWithFormat:@"timer_%@",timer.identify]] obj_copy];
        if (function) {
            runFunction(function,conatiner);
        }
    }else{
        
    }
}

@end
