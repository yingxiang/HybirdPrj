//
//  hybirdEngine.h
//  HybirdPrj
//
//  Created by xiang ying on 15/9/7.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//


#import "fileEngine.h"

@class UIContainerView;

@interface hybirdEngine : NSObject

void obj_msgSend(id self, SEL op, ...);

void alertException(NSString *title, NSString *msg);

void runFunction(NSDictionary *dic , UIContainerView * container);

#pragma mark - string switch

void stringSwitch_set(NSString *string);

BOOL stringEqual(NSString *string);

BOOL stringDefault();

@end