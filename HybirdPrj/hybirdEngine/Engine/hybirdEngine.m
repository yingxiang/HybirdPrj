//
//  hybirdEngine.m
//  HybirdPrj
//
//  Created by xiang ying on 15/8/13.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "fileEngine.h"
#import <AFNetworking/AFNetworking.h>
#import "ShareEngine.h"
#import "CALayer+animation.h"
#import "NSString+TPCategory.h"
#import "StartManage.h"
#import <ZipArchive/ZipArchive.h>
#import "PlayerEngine.h"

#pragma mark - function type
//下载文件
static NSString *const FT_DOWNLOAD         = @"FT_DOWNLOAD";
//网络请求
static NSString *const FT_REQUEST          = @"FT_REQUEST";
//数据解析
static NSString *const FT_PARSEDATA        = @"FT_PARSEDATA";
//页面跳转
static NSString *const FT_VIEWSKIP         = @"FT_VIEWSKIP";
//返回上一级页面
static NSString *const FT_VIEWBACK         = @"FT_VIEWBACK";
//返回到根页面
static NSString *const FT_VIEWBACKROOT     = @"FT_VIEWBACKROOT";
//返回到根页面的上一级页面
static NSString *const FT_VIEWROOTBACK     = @"FT_VIEWROOTBACK";
//返回到指定页面
static NSString *const FT_VIEWBACKTO       = @"FT_VIEWBACKTO";
//添加视图
static NSString *const FT_ADDVIEW          = @"FT_ADDVIEW";
//移除视图
static NSString *const FT_REMOVEVIEW       = @"FT_REMOVEVIEW";
//执行系统方法
static NSString *const FT_SYSTERM          = @"FT_SYSTERM";
//弹出警告框
static NSString *const FT_SHOWALERT        = @"FT_SHOWALERT";
//弹出选择框
static NSString *const FT_SHOWACTIONSHEET  = @"FT_SHOWACTIONSHEET";
//跳转到外部应用
static NSString *const FT_JUMPTOAPP        = @"FT_JUMPTOAPP";
//更新视图
static NSString *const FT_UPDATEVIEW       = @"FT_UPDATEVIEW";
//向js发送指令
static NSString *const FT_JSCOMMOND        = @"FT_JSCOMMOND";
//分享
static NSString *const FT_SHARE            = @"FT_SHARE";
//layer动画
static NSString *const FT_ANIMATION        = @"FT_ANIMATION";
//restart application重启app
static NSString *const FT_RESTART          = @"FT_RESTART";
//弹出tips
static NSString *const FT_SHOWTIPS         = @"FT_SHOWTIPS";
//播放语音
static NSString *const FT_PLAYAUDIO        = @"FT_PLAYAUDIO";

#pragma mark - public declare

void obj_msgSend(id self, SEL op, ...);

void runFunction(NSDictionary *dic, UIContainerView * container);

void alertException(NSString *title, NSString *msg);

#pragma mark - private methods

void unarchivezip (NSString *srcPath,NSString *dstPath,Block_progress progress,Block_complete complete){
    ZipArchive *archive = [[ZipArchive alloc] init];
    if([archive UnzipOpenFile:srcPath]){
        if (progress) {
            archive.progressBlock = ^(int percentage, int filesProcessed, unsigned long numFiles){
                progress(PROGRESS_TYPE_UNZIP,filesProcessed,numFiles);
            };
        }
        dispatch_async(global_queue, ^{
            BOOL result = [archive UnzipFileTo:dstPath overWrite:YES];
            [archive UnzipCloseFile];
            file_delete(srcPath);
            if (result) {
                NSLog(@"archive success");
            }
            complete(result,nil);
        });
    }else{
        complete(NO,nil);
    }
}

/**
 *  下载
 *
 *  @param dic       dic description
 *  @param container container description
 */
void download (NSDictionary *dic , UIContainerView *container){
    NSString *url = dic[@"url"];
    NSString *dirPath = NSHomeDirectory();
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", dirPath, dic[@"filepath"]];

    NSString *fileName = [filePath stringByAppendingFormat:@"/%@",[url stringFromMD5]];

    //reache 为YES，有也重新下载
    BOOL recache = [dic[@"recache"] obj_bool:^(BOOL success) {
        
    }];
    if (!recache && file_exist(fileName)) {
        //已有该文件就不下载
        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
        NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
        if (function) {
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key hasPrefix:@"parmer"]) {
                    [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                }
            }];
            runFunction(function, container);
        }
        return;
    }
    
    downloadFile(url, ^(PROGRESS_TYPE progresstype, long long currentprogress, long long totalprogress) {
        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_progress"];
        NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
        if (function) {
            [function setObject:[NSNumber numberWithFloat:currentprogress] forKey:@"parmer1"];
            [function setObject:[NSNumber numberWithFloat:totalprogress] forKey:@"parmer2"];
            runFunction(function, container);
        }

    }, ^(BOOL success, NSString *cachefile) {
        if (success) {
            
            if ([cachefile hasSuffix:@".zip"]) {
                
                NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_unzip"];
                NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
                if (function) {
                    runFunction(function, container);
                }
                
                unarchivezip(cachefile, filePath, ^(PROGRESS_TYPE progresstype, long long currentprogress, long long totalprogress) {
                    NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_progress"];
                    NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
                    if (function) {
                        [function setObject:[NSNumber numberWithFloat:currentprogress] forKey:@"parmer1"];
                        [function setObject:[NSNumber numberWithFloat:totalprogress] forKey:@"parmer2"];
                        dispatch_async(main_queue, ^{
                            runFunction(function, container);
                        });
                    }
                }, ^(BOOL success, id data) {
                    if (success) {
                        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
                        NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
                        if (function) {
                            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                if ([key hasPrefix:@"parmer"]) {
                                    [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                                }
                            }];
                            dispatch_async(main_queue, ^{
                                runFunction(function, container);
                            });
                        }
                    }else{
                        file_delete(cachefile);
                        //解压失败
                        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_failed"];
                        NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
                        if (function) {
                            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                if ([key hasPrefix:@"parmer"]) {
                                    [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                                }
                            }];
                            runFunction(function, container);
                        }
                    }
                });
            }else {
                //不是zip，不需要解压，直接返回
                file_move(cachefile, fileName);
                NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
                NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
                if (function) {
                    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if ([key hasPrefix:@"parmer"]) {
                            [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                        }
                    }];
                    runFunction(function, container);
                }
            }
        }else{
            //文件下载失败
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_failed"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                    }
                }];
                runFunction(function, container);
            }
        }
    });
}


/**
 *  请求
 *
 *  @param dic       dic description
 *  @param container container description
 */
void request (NSDictionary *dic , UIContainerView *container){
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *method = dic[@"method"];
    NSDictionary *orignparmeters = dic[@"parmeters"];
    NSMutableDictionary *parmeters = nil;
    if (orignparmeters) {
        parmeters = [NSMutableDictionary dictionary];
        [orignparmeters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            @try {
                [parmeters setObject:[container calculate:obj] forKey:key];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }];
    }
    
    NSString *url = dic[@"url"];
    if (![url isURLString]) {
        url = [container getValue:url];
    }
        
    if ([method isEqualToString:@"post"]) {
        [manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            [function setObject:responseObject forKey:@"dataList"];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:key];
                    }
                }];
                runFunction(function, container);
            }
#ifndef  COPY_ANYTIME
            //写文件到本地
            NSString *file = [[NSString stringWithFormat:@"%@_%@",container.identify,dic[@"url"]] stringFromMD5];
            NSString *desPath = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:file];
            [responseObject writeToFile:desPath atomically:NO];
#endif
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }else if ([method isEqualToString:@"put"]){
        [manager PUT:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }else{
        [manager GET:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            [function setObject:responseObject forKey:@"dataList"];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:key];
                    }
                }];
                runFunction(function, container);
            }
#ifndef  COPY_ANYTIME
            //写文件到本地
            NSString *file = [[NSString stringWithFormat:@"%@_%@",container.identify,dic[@"url"]] stringFromMD5];
            NSString *desPath = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:file];
            [responseObject writeToFile:desPath atomically:NO];
#endif
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] copy];
#ifndef  COPY_ANYTIME
            NSString *file = [[NSString stringWithFormat:@"%@_%@",container.identify,dic[@"url"]] stringFromMD5];
            NSString *desPath = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:file];
            NSDictionary *responseObject = [NSMutableDictionary dictionaryWithContentsOfFile:desPath];
            [function setObject:responseObject forKey:@"dataList"];
#endif
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:key];
                    }
                }];
                runFunction(function, container);
            }
        }];
    }
}

/**
 *  数据解析
 *
 *  @param dic       dic description
 *  @param container container description
 */
void parsedata (NSDictionary *dic , UIContainerView *container){
    NSDictionary *parse = dic[@"respond"];
    id data = dic[@"dataList"];
    if (!data) {
        return;
    }
    [parse enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [obj assignment:obj :dic];
        if ([obj isKindOfClass:[NSString class]]) {
            NSArray *array = [key componentsSeparatedByString:@"."];
            if (array.count == 1) {
                id value = data;
                NSArray *dataArray = [obj componentsSeparatedByString:@"."];
                for (int i = 0;i<dataArray.count;i++) {
                    value = [value objectForKey:value[0]];
                }
                [container setUI:@{key:value}];
            }else{
                //super-identify.xx
                id value = data;
                NSArray *dataArray = [obj componentsSeparatedByString:@"."];
                for (int i = 0;i<dataArray.count;i++) {
                    NSString *property = dataArray[i];
                    value = [value objectForKey:property];
                }
                //查询最终的视图，设置其属性
                UIContainerView *containView = container;
                for (int i = 0; i<array.count; i++) {
                    NSString *property = array[i];
                    if ([property isEqualToString:@"superContainer"]) {
                        containView = containView.superContainer;
                    }else if([property hasPrefix:@"container_"]){
                        NSString *key = [property substringFromIndex:10];
                        containView = [containView.subViews objectForKey:key];
                    }else{
                        [containView setUI:@{property:value}];
                    }
                }
            }
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            if ([key isEqualToString:@"cell"]) {
                [obj enumerateKeysAndObjectsUsingBlock:^(id key1, id obj1, BOOL *stop) {
                    if ([key1 isEqualToString:@"dataSource"]) {
                        id value = data;
                        NSArray *dataArray = [obj1 componentsSeparatedByString:@"."];
                        for (int i = 0;i<dataArray.count;i++) {
                            NSArray *property = [dataArray[i] componentsSeparatedByString:@"-"];
                            value = [value objectForKey:property[0]];
                            if (property.count > 2) {
                                value = value[0];
                            }
                        }
                        //try
                        [container setValue:value forKey:@"dataSource"];
                    }
                }];
                
                [container setValue:[NSMutableDictionary dictionaryWithDictionary:parse[@"cell"]] forKey:@"parseCell"];
                obj_msgSend(container.view, @selector(reloadData));
            }else if ([key isEqualToString:@"creatView"]){
                
            }
        }
    }];
}

/**
 *  页面跳转
 *
 *  @param dic       dic description
 *  @param container container description
 */
void viewskip (NSDictionary *dic , UIContainerView *container){
    NSString *className = dic[@"identify"];
    UIViewControllerAnimationModel model = (UIViewControllerAnimationModel)[dic[@"model"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"UIViewControllerAnimationModel", dic[@"model"]);
        }
    }];
    BOOL animated = YES;
    if (dic[@"animated"]) {
        animated = [dic[@"animated"] obj_bool:^(BOOL success) {
            if (!success) {
                showBoolException(@"animated", dic[@"animated"]);
            }
        }];
    }
    NSDictionary *data = [dic[@"parmers"] assignment:[dic[@"parmers"] obj_copy] :dic];
    UIViewController *controller = [[UIViewControllerHelper shareInstance] goTo:className model:model data:data animated:animated];
    controller.delegateConatiner = container;
}

/**
 *  回退到上一级页面
 *
 *  @param dic       dic description
 *  @param container container description
 */
void viewback (NSDictionary *dic , UIContainerView *container){
//    if ([container.view.viewController.container respondsToSelector:@selector(goBack)]) {
//        id target = container.view.viewController.container;
//        obj_msgSend(target, @selector(goBack));
//    }else{
        BOOL animated = YES;
        if (dic[@"animated"]) {
            animated = [dic[@"animated"] obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(@"animated", dic.description);
                }
            }];
        }
        [[UIViewControllerHelper shareInstance] goBackanimated:animated];
//    }
}

/**
 *  回退到根页面
 *
 *  @param dic       <#dic description#>
 *  @param container <#container description#>
 */
void viewroot (NSDictionary *dic , UIContainerView *container){
    BOOL animated = YES;
    if (dic[@"animated"]) {
        animated = [dic[@"animated"] obj_bool:^(BOOL success) {
            if (!success) {
                showBoolException(@"animated", dic.description);
            }
        }];
    }
    UIViewController *vc = [[UIViewControllerHelper shareInstance] getCurrentViewController];
    [vc.navigationController popToRootViewControllerAnimated:animated];
}

/**
 *  回退到根页面的上一级页面
 *
 *  @param dic       dic description
 *  @param container container description
 */
void viewrootback (NSDictionary *dic , UIContainerView *container){
    BOOL animated = YES;
    if (dic[@"animated"]) {
        animated = [dic[@"animated"] obj_bool:^(BOOL success) {
            if (!success) {
                showBoolException(@"animated", dic.description);
            }
        }];
    }
    UIViewController *vc = [[UIViewControllerHelper shareInstance] getCurrentViewController];
    [vc dismissViewControllerAnimated:animated completion:nil];
}

/**
 *  回退到指定的某一级页面
 *
 *  @param dic       dic description
 *  @param container container description
 */
void viewto (NSDictionary *dic , UIContainerView *container){
    BOOL animated = YES;
    if (dic[@"animated"]) {
        animated = [dic[@"animated"] obj_bool:^(BOOL success) {
            if (!success) {
                showBoolException(@"animated", dic.description);
            }
        }];
    }
    NSString *identy = dic[@"identify"];
    [[UIViewControllerHelper shareInstance] goBackTo:identy animated:animated];
}

/**
 *  添加视图
 *
 *  @param dic       dic description
 *  @param container container description
 */
void addview (NSDictionary *dic , UIContainerView *container){
    UIContainerView *superContainer = [container getContainer:dic[@"superView"]];
    UIContainerView *subContainer = [superContainer.subViews objectForKey:dic[@"subView"][@"identify"]];
    
    superContainer.view.viewController = nil;
    superContainer.view.viewController = container.view.viewController;
    
    if (!subContainer) {
        subContainer = newContainer(dic[@"subView"]);
    }
    [superContainer addSubContainer:subContainer data:subContainer.jsonData];
    if (dic[@"animation"]) {
        NSString *obj = dic[@"animation"][@"duration"];
        CGFloat duration = [[container calculate:obj] obj_float:^(BOOL success) {
            if (!success) {
                showFloatException(@"duration", obj);
            }
        }];
        superContainer.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:duration animations:^{
            [subContainer setUI:dic[@"animation"]];
            [subContainer.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            //具有先后顺序的方法
            superContainer.view.userInteractionEnabled = YES;
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                    }
                }];
                runFunction(function, container);
            }
        }];
    }
}

/**
 *  移除视图
 *
 *  @param dic       dic description
 *  @param container container description
 */
void removeview (NSDictionary *dic , UIContainerView *container){
    UIContainerView *subContainer = container;
    if (dic[@"container"]) {
        subContainer = [container getContainer:dic[@"container"]];
    }
    if (dic[@"animation"]) {
        NSString *obj = dic[@"animation"][@"duration"];
        CGFloat duration = [[container calculate:obj] obj_float:^(BOOL success) {
            if (!success) {
                showFloatException(@"duration", obj);
            }
        }];
        container.superContainer.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:duration animations:^{
            [subContainer setUI:dic[@"animation"]];
            [subContainer.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            container.superContainer.view.userInteractionEnabled = YES;
            [subContainer removeFromSuperContainer];
            //具有先后顺序的方法
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                    }
                }];
                runFunction(function, container);
            }
        }];
    }else{
        [subContainer removeFromSuperContainer];
    }
}

/**
 *  系统方法
 *
 *  @param dic       dic description
 *  @param container container description
 */
void systerm (NSDictionary *dic , UIContainerView *container){
    dic = [dic assignment:dic :dic];
    id  target = [container getValue:dic[@"target"]];
    SEL selector = NSSelectorFromString(dic[@"selector"]);
    
    if ([target respondsToSelector:selector]) {
        id objectOne = [container calculate:dic[@"objectone"]];
        id objectTwo = [container calculate:dic[@"objecttwo"]];
//        NSLog(@"%@",objectOne);
        obj_msgSend(target, selector, objectOne, objectTwo);
    }
}

/**
 *  显示alertview
 *
 *  @param dic       <#dic description#>
 *  @param container <#container description#>
 */
void alert (NSDictionary *dic , UIContainerView *container){
    NSString *title = dic[@"title"];
    NSString *message = dic[@"message"];
    NSString *cancel = dic[@"canceltitle"];
    NSArray *others = dic[@"othertitles"];
    
    __weak typeof(container)weakContainer = container;
    [BaseAlertView alertWithTitle:title message:message clickIndex:^(NSInteger index) {
        NSString *functionName = [NSString stringWithFormat:@"%@_%ld",dic[@"functionname"],(long)index];
        NSDictionary *function = [weakContainer.functionList objectForKey:functionName];
        if (function) {
            runFunction(function, weakContainer);
        }
    } cancelButtonTitle:cancel otherButtonTitles:others];
}

/**
 *  显示actionsheet
 *
 *  @param dic       <#dic description#>
 *  @param container <#container description#>
 */
void actionsheet (NSDictionary *dic , UIContainerView *container){
    NSString *title = dic[@"title"];
    NSString *message = dic[@"message"];
    NSString *cancel = dic[@"canceltitle"];
    NSArray *others = dic[@"othertitles"];
    __weak typeof(container)weakContainer = container;
    
    NSMutableArray *titles = [NSMutableArray array];
    __block NSMutableArray *actions = [NSMutableArray array];
    for (int i = 0; i < others.count; i++) {
        NSDictionary *item = others[i];
        if ([item isKindOfClass:[NSDictionary class]]) {
            if (item[@"title"]) {
                [titles addObject:item[@"title"]];
            }
            if (item[@"action"]) {
                [actions addObject:item[@"action"]];
            }
        }
    }
    //特别注意的是在ipad中，正确的展示方式为设置UIPopoverPresentationController
    [BaseActionSheet actionSheetShowInView:container.view  withTitle:title destructiveButtonTitle:message clickIndex:^(NSInteger index) {
        if (index!=0 && index < actions.count+1) {
            NSDictionary *function = [actions objectAtIndex:index-1];
            if (function) {
                runFunction(function, weakContainer);
            }
        }
        actions = nil;
    } cancelButtonTitle:cancel otherButtonTitles:titles];
}

/**
 *  跳转到外部app
 *
 *  @param dic       dic description
 *  @param container container description
 */
void openurl (NSDictionary *dic , UIContainerView *container){
    NSString *url = dic[@"url"];
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

/**
 *  更新视图
 *
 *  @param dic       dic description
 *  @param container container description
 */
void updateview (NSDictionary *dic , UIContainerView *container){
    UIContainerView *updateContainer = [container getContainer:dic[@"container"]];
    if (dic[@"animation"]) {
        NSString *obj = dic[@"animation"][@"duration"];
        CGFloat duration = [[updateContainer calculate:obj] obj_float:^(BOOL success) {
            if (!success) {
                showFloatException(@"duration", obj);
            }
        }];
        [UIView animateWithDuration:duration animations:^{
            [updateContainer setUI:dic];
        } completion:^(BOOL finished) {
            NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
            NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                    }
                }];
                runFunction(function, container);
            }
        }];
    }else{
        [updateContainer setUI:dic];
    }
}

/**
 *  js指令
 *
 *  @param dic       dic description
 *  @param container container description
 */
void jscommond (NSDictionary *dic , UIContainerView *container){
    //找到指定的需要执行js的web页面
    UIContainerView *containerWeb = [container getContainer:dic[@"container"]];
    if (containerWeb) {
        if ([containerWeb respondsToSelector:NSSelectorFromString(@"sendCommond:")]) {
            NSMutableDictionary *commondDic = [dic obj_copy];
            [commondDic removeObjectForKey:@"container"];
            obj_msgSend(containerWeb, NSSelectorFromString(@"sendCommond:"), commondDic);
        }else {
            showException(dic.description);
        }
    }else{
        
    }
}

/**
 *  分享
 *
 *  @param dic       dic description
 *  @param container container description
 */
void share (NSDictionary *dic , UIContainerView *container){
    ShareObject *shareObjetc = [ShareObject shareObject:dic];
    [ShareEngine shareInstance].shareObject = shareObjetc;
    
    __weak typeof(container)weakContainer = container;
    [[ShareEngine shareInstance] shareCallBack:^(BOOL success, NSString *msg) {
        if (msg) {
            [[NSModelFuctionCenter shareInstance] showTips:msg];
        }
        
        if (success) {
            NSMutableDictionary *function = [weakContainer.functionList[@"FT_SHARE_block"] obj_copy];
            if (function) {
                [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key hasPrefix:@"parmer"]) {
                        [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                    }
                }];
                runFunction(function, weakContainer);
            }
        }
    }];
}

/**
 *  动画
 *
 *  @param dic       dic description
 *  @param container container description
 */
void animation (NSDictionary *dic , UIContainerView *container){
    animType animationType = (animType)[dic[@"animType"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"animType", dic);
        }
    }];
    
    animSubType subType = (animSubType)[dic[@"animSubType"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"animSubType", dic);
        }
    }];
    
    animCurve curve = (animCurve)[dic[@"animCurve"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"animCurve", dic);
        }
    }];
    
    CGFloat duration = [dic[@"duration"] obj_float:^(BOOL success) {
        if (!success) {
            showFloatException(@"duration", dic[@"duration"]);
        }
    }];
    
    NSInteger repeats = [dic[@"repeats"] obj_integer:^(BOOL success) {
        if (!success) {
            showFloatException(@"repeats", dic[@"repeats"]);
        }
    }];
    
    if (repeats == 0) {
        repeats = 1;
    }else if (repeats < 0){
        repeats = MAXFLOAT;
    }
    
    UIView *animationView = [container getValue:dic[@"animationView"]];
    
    animationView.userInteractionEnabled = NO;
    
    [animationView.layer animationWithType:animationType subType:subType curve:curve duration:duration repeatsCount:repeats completion:^{
        animationView.userInteractionEnabled = YES;
        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_block"];
        NSMutableDictionary *function = [[container.functionList objectForKey:functionName] obj_copy];
        if (function) {
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key hasPrefix:@"parmer"]) {
                    [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                }
            }];
            runFunction(function, container);
        }
    }];
}

/**
 *  restart action
 *
 */
void restart(){
    [StartManage restartApplication];
}

/**
 *  showtips action
 *
 *  @param dic       parmers
 *  @param container uicontainer
 */
void showtips(NSDictionary *dic , UIContainerView *container){
    NSString *msg = [dic[@"msg"] assignment:dic[@"msg"] :dic];
    [[NSModelFuctionCenter shareInstance] showTips:msg];
}


/**
 *  playaudio
 *
 *  @param dic       parmers
 *  @param container view container
 */
void playaudio(NSDictionary *dic , UIContainerView *container){
    
    NSString *url            =  dic[@"url"];
    NSTimeInterval duration  = [dic[@"duration"] obj_float:^(BOOL success) {
        if (!success) {
            showBoolException(@"duration", dic[@"duration"])
        }
    }];
    NSTimeInterval begintime = [dic[@"begintime"] obj_float:^(BOOL success) {
        if (!success) {
            showBoolException(@"duration", dic[@"duration"])
        }
    }];
    __weak UIContainerView *weakContainer = container;
    [[PlayerEngine shareInstance] playAudio:url startTime:begintime endTime:duration repeats:1];
    //download file progress or palying progress
    [PlayerEngine shareInstance].progressBlock = ^(PROGRESS_TYPE progresstype ,long long currentprogress, long long totalprogress) {
        NSString *functionname = [dic[@"functionname"] stringByAppendingString:@"_audioProgress"];
        NSMutableDictionary *function = weakContainer.functionList[functionname];
        if (function) {
            [function setObject:[NSNumber numberWithFloat:currentprogress] forKey:@"parmer1"];
            [function setObject:[NSNumber numberWithFloat:totalprogress] forKey:@"parmer2"];
            runFunction(function, weakContainer);
        }
    };
    [PlayerEngine shareInstance].delegateContainer = container;
    
    [PlayerEngine shareInstance].completeBlock = ^(BOOL success, id data){
        NSString *functionname = [dic[@"functionname"] stringByAppendingString:@"_audioComplete"];
        NSMutableDictionary *function = [weakContainer.functionList[functionname] obj_copy];
        if (function) {
            runFunction(function, weakContainer);
        }
    };
}

/**
 *  detaial action
 *
 *  @param dic       parmers
 *  @param container uicontainer
 */
void run(NSDictionary *dic , UIContainerView *container){
    NSString *functionType = dic[@"type"];
    
    if (functionType) {
        @try {
            if ([functionType isEqualToString:FT_DOWNLOAD]) {
                //下载
                download(dic, container);
            }else if ([functionType isEqualToString:FT_REQUEST]) {
                //请求
                request(dic, container);
            }else if ([functionType isEqualToString:FT_PARSEDATA]) {
                //数据解析
                parsedata(dic, container);
            }else if ([functionType isEqualToString:FT_VIEWSKIP]){
                //页面跳转
                viewskip(dic, container);
            }else if ([functionType isEqualToString:FT_VIEWBACK]){
                //返回上一级页面
                viewback(dic, container);
            }else if ([functionType isEqualToString:FT_VIEWBACKROOT]){
                //返回到根页面
                viewroot(dic, container);
            }else if ([functionType isEqualToString:FT_VIEWROOTBACK]){
                //返回到根页面的上一级页面
                viewrootback(dic, container);
            }else if ([functionType isEqualToString:FT_VIEWBACKTO]){
                //返回到指定页面
                viewto(dic, container);
            }else if ([functionType isEqualToString:FT_ADDVIEW]){
                //添加视图
                addview(dic, container);
            }else if ([functionType isEqualToString:FT_REMOVEVIEW]){
                //移除视图
                removeview(dic, container);
            }else if ([functionType isEqualToString:FT_SYSTERM]){
                //执行系统方法
                systerm(dic, container);
            }else if ([functionType isEqualToString:FT_SHOWALERT]){
                //弹出警告框
                alert(dic, container);
            }else if ([functionType isEqualToString:FT_SHOWACTIONSHEET]){
                //弹出选择框
                actionsheet(dic, container);
            }else if ([functionType isEqualToString:FT_JUMPTOAPP]){
                //跳转到外部应用
                openurl(dic, container);
            }else if ([functionType isEqualToString:FT_UPDATEVIEW]){
                //更新视图
                updateview(dic, container);
            }else if ([functionType isEqualToString:FT_JSCOMMOND]){
                //向js发送指令
                jscommond(dic, container);
            }else if ([functionType isEqualToString:FT_SHARE]){
                //分享
                share(dic, container);
            }else if ([functionType isEqualToString:FT_ANIMATION]){
                //动画
                animation(dic, container);
            }else if ([functionType isEqualToString:FT_RESTART]){
                //重启
                restart();
            }else if ([functionType isEqualToString:FT_SHOWTIPS]){
                //show tips
                showtips(dic, container);
            }else if ([functionType isEqualToString:FT_PLAYAUDIO]){
                //paly audio
                playaudio(dic, container);
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        //同步一起的方法
        NSString *functionName = [dic[@"functionname"] stringByAppendingString:@"_complete"];
        BOOL isInstance = [dic[@"ModelCenterFunction"] obj_bool:nil];
        NSMutableDictionary *function = nil;
        if (isInstance) {
            function = [[NSModelFuctionCenter shareInstance] objectForKey:functionName];
        }else {
            function = [[container.functionList objectForKey:functionName] obj_copy];
        }
        if (function) {
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key hasPrefix:@"parmer"]) {
                    [function setObject:[obj obj_copy] forKey:[key obj_copy]];
                }
            }];
            runFunction(function, container);
        }
    }else {
        NSString *mesage = [dic.description stringByAppendingFormat:@"\n%@",container.identify];
        showException(mesage);
    }
}

#pragma mark - public methods

/**
 *  obj_msgSend
 *
 *  @param self target
 *  @param op   selecter
 *  @param ...  parmers
 */
void obj_msgSend(id self, SEL op, ...){
    if ([self respondsToSelector:op]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:op];
        NSUInteger length = [signature numberOfArguments];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:op];
        
        va_list arg_ptr;
        va_start(arg_ptr, op);
        for (NSUInteger i = 2; i < length; ++i) {
            id parameter = va_arg(arg_ptr, id);
            NSString *type = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]];
            if ([[type lowercaseString] isEqualToString:@"f"]
                ||[[type lowercaseString] isEqualToString:@"d"]) {
                float Value = [parameter floatValue];
                [invocation setArgument:&Value atIndex:i];
            }else if ([[type lowercaseString] isEqualToString:@"b"]){
                BOOL Value = [parameter boolValue];
                [invocation setArgument:&Value atIndex:i];
            }else if ([[type lowercaseString] isEqualToString:@"q"]
                      ||[[type lowercaseString] isEqualToString:@"i"]){
                NSInteger Value = [parameter integerValue];
                [invocation setArgument:&Value atIndex:i];
            }else{
                if (![parameter isKindOfClass:[NSNull class]]) {
                    [invocation setArgument:&parameter atIndex:i];
                }
            }
        }
        va_end(arg_ptr);
        [invocation invokeWithTarget:self];
    }else{
        NSString *msg = [NSString stringWithFormat:@"%@ cannot respondselector:%@",self,NSStringFromSelector(op)];
        showException(msg)
    }
}


/**
 *  showexpection
 *
 *  @param title expection title
 *  @param msg   expection message
 */
void alertException(NSString *title, NSString *msg){
    NSString *exception = [NSString stringWithFormat:@"%@\n%@",title,msg];
#ifdef DEBUG
    [[NSModelFuctionCenter shareInstance] showTips:exception];
//    if (([UIViewControllerHelper shareInstance].isPresenting)) {
//        return;
//    }
//    [BaseAlertView alertWithTitle:@"" message:exception clickIndex:nil cancelButtonTitle:@"yes" otherButtonTitles:nil];
#else
    //记载错误日志，并上传错误日志
    
#endif
}

/**
 *  assign actions
 *
 *  @param dic       parmers
 *  @param container uicontainer
 */
void runFunction(NSDictionary *dic , UIContainerView * container){
    NSArray *cases = dic[@"cases"];
    if (cases) {
        for (NSDictionary *acase in cases) {
            BOOL canrun = [[container calculate:acase[@"case"]] obj_bool:nil];
            if (canrun) {
                runFunction(acase, container);
            }
        }
        return;
    }
    
    if (dic[@"delay"]) {
        NSString *delay = dic[@"delay"];
        //延迟函数
        CGFloat delayInSeconds = [[container calculate:delay] obj_float:^(BOOL success) {
            if (!success) {
                showFloatException(@"delay", delay);
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            run(dic, container);
        });
    }else if(dic[@"dispatch"]){
        //开线程
        NSString *dispatch = dic[@"dispatch"];
        
        dispatch_queue_t queue;
        if ([dispatch isEqualToString:@"0"]) {
            queue = main_queue;
        }else{
            queue = global_queue;
        }
        dispatch_async(queue, ^{
            run(dic, container);
        });
    }else if (dic[@"timer"]){
        
    }else{
        run(dic, container);
    }
}
