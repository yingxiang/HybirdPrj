//
//  UserAgent.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/20.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAgent : NSObject

DECLARE_AS_SINGLETON(UserAgent)

- (void)fetchUserAgent;

- (void)registerToken:(NSString*)token;

@end
