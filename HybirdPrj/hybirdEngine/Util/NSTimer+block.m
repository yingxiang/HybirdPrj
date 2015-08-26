//
//  NSTimer+block.m
//  HybirdPrj
//
//  Created by xiang ying on 15/8/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSTimer+block.h"

static const void *blockKey = &blockKey;

@implementation NSTimer (block)
@dynamic block;

- (Block)block{
    return objc_getAssociatedObject(self, blockKey);
}

- (void)setBlock:(Block)block{
    objc_setAssociatedObject(self, blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(void))block repeats:(BOOL)yesOrNo{
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(init)]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti invocation:invocation repeats:yesOrNo];
    invocation.target = timer;
    [invocation setSelector:@selector(timerAction)];
    
    timer.block = block;
    return timer;
}

- (void)timerAction{
    if (self.block) {
        self.block();
    }
}

@end
