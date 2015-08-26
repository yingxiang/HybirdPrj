//
//  RecorderEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecorderEngine : NSObject

nonatomic_copy   (Block_progress , progressBlock)
nonatomic_copy   (Block_complete , completeBlock)

DECLARE_AS_SINGLETON(RecorderEngine)

- (BOOL)startRecord:(NSString*)recordName;

- (void)stopRecord;

- (BOOL)isRecording;

@end
