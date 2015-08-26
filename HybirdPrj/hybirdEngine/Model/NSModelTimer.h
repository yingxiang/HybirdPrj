//
//  NSModelTimer.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/23.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"

@interface NSModelTimer : NSModel

- (void)creatTimer:(NSDictionary*)dic inConatiner:(UIContainerView*)container;

- (void)startTimerForkey:(NSString*)key;

- (void)endTimerforKey:(NSString*)key;

@end
