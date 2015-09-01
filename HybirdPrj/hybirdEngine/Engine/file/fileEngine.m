//
//  fileEngine.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "fileEngine.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+TPCategory.h"

@implementation fileEngine

/**
 * 下载文件
 */
void downloadFile(NSString *aUrl,Block_progress progressBlock,Block_complete completeBlock)
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

void uploadFile(NSString *aUrl,NSString *aFilePath,NSString *aFileName,Block_progress progressBlock,Block_complete completeBlock){

    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", aFilePath, aFileName];
    
    if (file_exist(fileName)) {
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

#pragma mark - NSFile methods

/**
 *  assign readjsonFile to dic
 *
 *  @param filepath
 *  @param filename
 */
NSDictionary* file_read(NSString *filepath , NSString *filename){
    if (filepath) {
        if (filename) {
            if ([filename hasSuffix:@".json"]) {
                filepath = [filepath stringByAppendingPathComponent:filename];
            }else{
                filepath = [[filepath stringByAppendingPathComponent:filename] stringByAppendingString:@".json"];
            }
        }
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                showException(error.localizedDescription);
            }else {
                return dic;
            }
        }else {
            showException(filename);
        }
    }
    return nil;
}

bool file_exist(NSString *dscPath){
    bool exist = [[NSFileManager defaultManager] fileExistsAtPath:dscPath];
    //    if (!exist) {
    //        showException(dscPath)
    //    }
    return exist;
}

bool file_copy(NSString *srcPath,NSString *dstPath){
    NSError *error = nil;
    bool result = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
    if (error) {
        showException(error.description)
    }
    return result;
}

bool file_delete(NSString *dscPath){
    NSError *error = nil;
    bool result = [[NSFileManager defaultManager] removeItemAtPath:dscPath error:&error];
    if (error) {
        showException(error.description)
    }
    return result;
}

bool file_move(NSString *srcPath,NSString *dstPath){
    NSError *error = nil;
    //    BOOL result = [[NSFileManager defaultManager] moveItemAtURL:[NSURL URLWithString:srcPath] toURL:[NSURL URLWithString:dstPath] error:&error];
    
    bool result = [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:&error];
    if (error) {
        showException(error.description)
    }
    return result;
}

bool file_createDirectory(NSString *dstPath){
    bool result = YES;
    if (!file_exist(dstPath)) {
        NSError *error = nil;
        result =  [[NSFileManager defaultManager] createDirectoryAtPath:dstPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            showException(error.description)
        }
    }
    return result;
}
@end
