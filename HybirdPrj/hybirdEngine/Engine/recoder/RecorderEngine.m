//
//  RecorderEngine.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "RecorderEngine.h"
#import <AVFoundation/AVFoundation.h>

@interface RecorderEngine ()<AVAudioRecorderDelegate>

nonatomic_strong(AVAudioRecorder,   *recorder)
nonatomic_strong(NSURL,             *desPath)
nonatomic_strong(NSTimer,           *timer)

@end

@implementation RecorderEngine

DECLARE_SINGLETON(RecorderEngine)

- (instancetype)init{
    self = [super init];
    if (self) {
        file_createDirectory(RECORDER_PATH);
    }
    return self;
}

- (BOOL)startRecord:(NSString*)recordName{
    NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:recordName]];
    self.desPath = [NSURL fileURLWithPath:[RECORDER_PATH stringByAppendingPathComponent:recordName]];
    NSError *error = nil;
    
    //录音设置
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:tmpUrl settings:recordSetting error:&error];
    self.recorder.delegate = self;
    if (error) {
        return NO;
    }
    if([self.recorder prepareToRecord]){
        return [self.recorder record];
    }
    return NO;
}

- (void)setProgressBlock:(Block_progress)progressBlock{
    _progressBlock = progressBlock;
    if (progressBlock) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
                if (self.recorder.isRecording) {
                    [self.recorder updateMeters];
                    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
                    self.progressBlock(PROGRESS_TYPE_RECORDER,lowPassResults,1);
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

- (void)stopRecord{
    [self.recorder stop];
}

- (BOOL)isRecording{
    return self.recorder.isRecording;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [[NSFileManager defaultManager] moveItemAtURL:recorder.url toURL:self.desPath error:nil];
    [recorder deleteRecording];
    self.progressBlock = nil;
    if (self.completeBlock) {
        self.completeBlock(flag,self.desPath);
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    self.progressBlock = nil;
    if (self.completeBlock) {
        self.completeBlock(NO,self.desPath);
    }
}

@end
