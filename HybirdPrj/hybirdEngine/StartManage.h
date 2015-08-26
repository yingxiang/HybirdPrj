//
//  StartManage.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/27.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareEngine.h"

@interface StartManage : NSObject

+ (BOOL)startApplication:(Block_complete)complete;

+ (BOOL)restartApplication;

@end
