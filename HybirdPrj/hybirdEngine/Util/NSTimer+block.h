//
//  NSTimer+block.h
//  HybirdPrj
//
//  Created by xiang ying on 15/8/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (block)

nonatomic_copy(Block_void, block)

+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))block repeats:(BOOL)yesOrNo;

@end
