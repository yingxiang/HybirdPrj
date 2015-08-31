//
//  FTPEngine.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "FTPEngine.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+TPCategory.h"

@implementation FTPEngine

/**
 * 下载文件
 */
+ (void)downloadFileURL:(NSString *)aUrl progress:(Block_progress)progressBlock complete:(Block_complete)completeBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cachefile = [NSTemporaryDirectory() stringByAppendingString:[fileManager displayNameAtPath:aUrl]];
    
    //下载附件
    NSURL *url = [NSURL URLWithString:aUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:cachefile append:NO];
    
    //下载进度控制
    if (progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            progressBlock(PROGRESS_TYPE_DOWNLOAD,totalBytesRead,totalBytesExpectedToRead);
        }];
    }
    
    //已完成下载
    if (completeBlock) {
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            completeBlock(YES,cachefile);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //下载失败
            completeBlock(NO,nil);
        }];
    }
    
    [operation start];
}

+ (void)uploadFileURL:(NSString *)aUrl filePath:(NSString *)aFilePath fileName:(NSString *)aFileName progress:(Block_progress)progressBlock complete:(Block_complete)completeBlock{
    
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", aFilePath, aFileName];
    
    if (file_exit(fileName)) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        AFHTTPRequestOperation *operation = [manager POST:aUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileName] name:aFileName error:nil];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                completeBlock(YES,nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(NO,nil);
            }
        }];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (progressBlock) {
                progressBlock(PROGRESS_TYPE_UPLOAD,totalBytesWritten,totalBytesExpectedToWrite);
            }
        }];
    }
}


@end
