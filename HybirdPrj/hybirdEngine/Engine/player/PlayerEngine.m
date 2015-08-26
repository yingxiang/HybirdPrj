//
//  PlayerEngine.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/21.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "PlayerEngine.h"
#import "NSString+TPCategory.h"
#import "FTPEngine.h"

@interface PlayerEngine ()<AVAudioPlayerDelegate>

nonatomic_strong (AVAudioPlayer , *player)
nonatomic_assign (NSTimeInterval, startTime)
nonatomic_assign (NSTimeInterval, endTime)
nonatomic_assign (NSInteger     , repeatsCount)
nonatomic_assign (NSInteger     , tmprepeats)
nonatomic_strong (NSString      , *playUrl)
nonatomic_strong (NSTimer       , *timer)

@end

@implementation PlayerEngine

DECLARE_SINGLETON(PlayerEngine)

- (instancetype)init{
    self = [super init];
    if (self) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:AUDIO_PATH]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:AUDIO_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:BOOK_PATH]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:BOOK_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

- (void)reset{
    if (self.player) {
        [self.player stop];
        self.startTime          = 0;
        self.endTime            = 0;
        self.progressBlock      = nil;
        self.repeatsCount       = 1;
        self.tmprepeats         = 1;
        self.playUrl            = nil;
        self.delegateContainer  = nil;
        self.player = nil;
    }
}

- (void)setProgressBlock:(Block_progress)progressBlock{
    _progressBlock = progressBlock;
    if (progressBlock) {
        if (!self.timer) {
            __weak typeof(self) weakSelf = self;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
                if (weakSelf.player.isPlaying) {
                    if (weakSelf.player.currentTime >= weakSelf.endTime && weakSelf.tmprepeats < weakSelf.repeatsCount) {
                        [weakSelf.player playAtTime:weakSelf.startTime];
                        weakSelf.tmprepeats ++;
                    }
                    if (weakSelf.progressBlock) {
                        weakSelf.progressBlock(PROGRESS_TYPE_PLAYAUDIO,weakSelf.player.currentTime,weakSelf.player.duration);
                    }
                }
            } repeats:YES];
        }
    }else{
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

- (BOOL)audioPlay:(NSString*)filePath{
    if (!self.player) {
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
        if (error) {
            return NO;
        }
        self.player.delegate = self;
        [self.player prepareToPlay];
        if (self.endTime == 0) {
            self.endTime = self.player.duration;
        }
        [self.player play];
    }
    return YES;
}

- (BOOL)playAudio:(NSString*)url startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime repeats:(NSInteger)count{
    
    if ([self.playUrl isEqualToString:url]) {
        return NO;
    }
    [self reset];
    self.playUrl = url;
    
    self.startTime      = startTime;    //默认0
    self.endTime        = endTime;      //默认0
    self.repeatsCount   = count;        //默认1
    
    if (count < 0) {
        self.repeatsCount = MAXFLOAT;
    }
    
    NSString *fileName  = [url stringFromMD5];
    NSString *filePath  = [AUDIO_PATH stringByAppendingPathComponent:fileName];
    //根据url地址寻找本地资源
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self audioPlay:filePath];
        [self.player playAtTime:startTime];
    }else {
        //边下边播
        NSString *cachefile = [NSTemporaryDirectory() stringByAppendingString:[[NSFileManager defaultManager] displayNameAtPath:url]];
        
        [FTPEngine downloadFileURL:url progress:^(PROGRESS_TYPE progresstype, long long currentprogress, long long totalprogress) {
            if (self.progressBlock) {
                //下载更新
                self.progressBlock(progresstype,currentprogress,totalprogress);
            }
            NSData *data = [NSData dataWithContentsOfFile:cachefile];
            if (data.length > 1024*20) {
                if (!self.player && self.delegateContainer) {
                    [self audioPlay:cachefile];
                    [self.player playAtTime:startTime];
                }
            }
        } complete:^(BOOL success, NSString *cachefilePath) {
            if (success) {
                [[NSFileManager defaultManager] moveItemAtPath:cachefilePath toPath:filePath error:nil];
                if (!self.player && self.delegateContainer) {
                    [self audioPlay:filePath];
                    [self.player playAtTime:startTime];
                }
            }
        }];
    }
    return NO;
}

- (void)play{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}

- (void)stop{
    [self.player stop];
}

#pragma mark -

//complete
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.completeBlock) {
        self.completeBlock(flag, nil);
    }
    [self reset];
}

//error
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self reset];
}

//interrupt
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags{
    
}

@end
