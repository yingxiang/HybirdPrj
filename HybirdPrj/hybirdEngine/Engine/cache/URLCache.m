//
//  URLCache.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/20.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "URLCache.h"
#import <SDWebImage/SDWebImageManager.h>
#import "NSString+TPCategory.h"

#define _HYBIRD_PATH_WEB    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/web.bundle"]

@interface URLCache ()

nonatomic_strong(NSDictionary       , *mimetypeDic)
nonatomic_strong(NSMutableDictionary, *appPageUrlDic)

@end

@implementation URLCache

DECLARE_SINGLETON(URLCache)

- (instancetype)init{
    self = [super init];
    if (self) {
        self.mimetypeDic = @{@"js"     :@"application/x-javascript",
                              @"jpg"    :@"image/jpeg",
                              @"jpeg"   :@"image/jpeg",
                              @"png"    :@"image/png",
                              @"zip"    :@"application/zip",
                              @"gif"    :@"image/gif",
                              @"3gp"    :@"video/3gpp",
                              @"mp3"    :@"audio/x-mpeg",
                              @"mp4"    :@"video/mp4",
                              @"mpeg"   :@"video/mpeg",
                              @"mpg"    :@"video/mpeg",
                              @"mpg4"   :@"video/mp4",
                              @"txt"    :@"text/plain",
                              @"css"    :@"text/css",
                              @"html"   :@"text/html"};
        self.appPageUrlDic = [NSMutableDictionary dictionary];
        [self setMemoryCapacity:1024*1024*30];
        [NSURLCache setSharedURLCache:self];
    }
    return self;
}

- (void)cache{
    //
    if (!file_exit(_HYBIRD_PATH_WEB)) {
        NSString *bundlepath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web.bundle"];
        if (file_exit(bundlepath)) {
            file_copy(bundlepath, _HYBIRD_PATH_WEB);
        }
    }
    [self.appPageUrlDic removeAllObjects];
    if (file_exit(_HYBIRD_PATH_WEB)) {
        //
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *pageDir = [_HYBIRD_PATH_WEB stringByAppendingPathComponent:@"release/app_page"];
        NSArray* array = [fileManager contentsOfDirectoryAtPath:pageDir error:nil];
        BOOL isDir;
        NSString* dirName = nil;
        NSString* pageUrl = nil;
        NSString* fullPath = nil;
        for(int i = 0; i<[array count]; i++)
        {
            isDir = NO;
            dirName = [array objectAtIndex:i];
            fullPath = [pageDir stringByAppendingPathComponent:[array objectAtIndex:i]];
            if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
            {
                pageUrl = [self getPageInfoFromPath:[fullPath stringByAppendingPathComponent:@"ver.ini"] searchFlag:@"URL"];
                if(pageUrl && ![self.appPageUrlDic objectForKey:pageUrl])
                {
                    [self.appPageUrlDic setObject:[[pageDir stringByAppendingPathComponent:dirName] stringByAppendingPathComponent:@"index.html"] forKey:pageUrl];
                }
            }
        }
    }
}

#pragma mark - localcache
- (BOOL)webView:(id)webView loadRequest:(NSURL*)url{
    NSString *decodeUrl = [url.absoluteString URLDecodedString];
    NSString* filePath = self.appPageUrlDic[decodeUrl];
    if (file_exit(filePath))
    {
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        obj_msgSend(webView, @selector(loadData:MIMEType:textEncodingName:baseURL:),data,@"text/html",[NSNull null],[NSURL fileURLWithPath:filePath]);
        NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        obj_msgSend(webView, @selector(loadHTMLString:baseURL:),string,[NSURL URLWithString:filePath]);
        return NO;
    }
    return YES;
}

-(NSString*)getPageInfoFromPath:(NSString*)verionFilePath searchFlag:(NSString*)searchStr
{
    NSError* error = nil;
    NSString* fileContent = [NSString stringWithContentsOfFile:verionFilePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* contentArray = nil;
    NSArray* versionArray = nil;
    NSString* version = nil;
    if(!error && fileContent != nil && [fileContent length] > 0)
    {
        contentArray = [fileContent componentsSeparatedByString:@"\n"];
        for(NSString* content in contentArray)
        {
            if([content rangeOfString:searchStr].length > 0)
            {
                versionArray = [content componentsSeparatedByString:@"="];
                if(versionArray && [versionArray count] > 1)
                {
                    version = [NSString stringWithString:[versionArray objectAtIndex:1]];
                    break;
                }
            }
        }
    }
    if(version)
    {
        version = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return version;
}


#pragma mark - urlcache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request{
    
    NSCachedURLResponse *cacheResponse = [self getCacheResponseByURL:[request URL]];

    if (!cacheResponse) {
        cacheResponse = [super cachedResponseForRequest:request];
    }
    return cacheResponse;
}

- (NSCachedURLResponse*)getCacheResponseByURL:(NSURL*)url{
    NSString* fullPath = [self getResourcePathByUrl:url];
    if(fullPath)
    {
        // 加载替代数据
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        NSString *mimeType = [self mimeTypeWithFilePath:fullPath];
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url MIMEType:mimeType expectedContentLength:[data length] textEncodingName:nil];
        
        NSCachedURLResponse *cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        return cacheResponse;
    }
    return nil;
}

/**
 *  根据url查询本地Cache中是否存在相应的资源
 *
 *  @param url
 */
-(NSString*)getResourcePathByUrl:(NSURL*)url
{
    NSArray* pathArray = [url pathComponents];
    NSString* resourcePath = [[_HYBIRD_PATH_WEB stringByAppendingPathComponent:@"release/app_cache"] stringByAppendingPathComponent:[url host]];
    for(NSString* path in pathArray)
    {
        resourcePath = [resourcePath stringByAppendingPathComponent:path];
    }
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //路径存在并且不是目录
    if ([fileManager fileExistsAtPath:resourcePath isDirectory:&isDir] && !isDir)
    {
        return resourcePath;
    }
    return nil;
}

- (NSString *)mimeTypeWithFilePath:(NSString *)filePath
{
    NSString* extension = [filePath pathExtension];
    NSString* mimeType = nil;
    if(extension)
    {
        mimeType = [_mimetypeDic objectForKey:extension];
    }
    if(!mimeType)
    {
        mimeType = @"image/png";
    }
    return mimeType;
}

@end
