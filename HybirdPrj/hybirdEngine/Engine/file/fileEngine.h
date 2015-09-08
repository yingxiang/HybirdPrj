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
 *  @param aUrl          上传地址
 *  @param aFilePath     本地文件地址
 *  @param aFileName     <#aFileName description#>
 *  @param progressBlock <#progressBlock description#>
 *  @param completeBlock <#completeBlock description#>
 */
void uploadFile(NSString *aUrl,NSString *aFilePath,NSString *aFileName,Block_progress progressBlock,Block_complete completeBlock);

NSDictionary* file_read(NSString *filepath , NSString *filename);

bool file_exist(NSString *dscPath);

bool file_copy(NSString *srcPath,NSString *dstPath);

bool file_delete(NSString *dscPath);

bool file_move(NSString *srcPath,NSString *dstPath);

bool file_createDirectory(NSString *dstPath);

@end
