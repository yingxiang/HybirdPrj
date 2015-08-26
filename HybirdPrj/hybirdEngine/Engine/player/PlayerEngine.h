//
//  PlayerEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/21.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerEngine : NSObject

nonatomic_weak   (UIContainerView, *delegateContainer)
nonatomic_copy   (Block_progress , progressBlock)
nonatomic_copy   (Block_complete , completeBlock)

DECLARE_AS_SINGLETON(PlayerEngine)

//返回yes直接播放的本地资源，no为下载播放
- (BOOL)playAudio:(NSString*)url startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime repeats:(NSInteger)count;

- (void)play;

- (void)pause;

- (void)stop;

- (void)reset;

@end
