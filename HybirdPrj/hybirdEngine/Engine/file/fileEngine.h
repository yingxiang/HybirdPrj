//
//  fileEngine.h
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileEngine : NSObject

/**
 * 下载文件
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址
 * @param string aFileName 文件名
 */

void downloadFile(NSString *aUrl,Block_progress progressBlock,Block_complete completeBlock);

/**
 *  上传文件
 *
 *
 */
void uploadFile(NSString *aUrl,NSString *aFilePath,NSString *aFileName,Block_progress progressBlock,Block_complete completeBlock);

@end
