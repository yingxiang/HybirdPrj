//
//  _declare_header.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#ifndef HybirdPrj__declare_header_h
#define HybirdPrj__declare_header_h

#pragma mark - Property

#define nonatomic_strong_readonly(__class__, __property__)\
@property(nonatomic,strong,readonly)__class__   __property__;

#define nonatomic_readonly(__class__, __property__)\
@property(nonatomic,readonly)__class__   __property__;

#define nonatomic_assign(__class__, __property__)\
@property (nonatomic, assign)__class__  __property__;

#define nonatomic_copy(__class__, __property__)\
@property (nonatomic, copy)__class__  __property__;

#define nonatomic_weak(__class__, __property__)\
@property (nonatomic, weak)__class__    __property__;

#define nonatomic_strong(__class__, __property__)\
@property (nonatomic, strong) __class__ __property__;

#pragma mark - Device

#define _infoDictionary [[NSBundle mainBundle] infoDictionary]

#define _appVersion _infoDictionary[@"CFBundleShortVersionString"]

#define _sysVersion [[UIDevice currentDevice] systemVersion]

#define _isIpad ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)

#pragma mark - Alloc

#define _obj_alloc(__obj_class__) \
[[__obj_class__ alloc]init];

#define DECLARE_AS_SINGLETON(interfaceName)               \
+ (interfaceName*)shareInstance;                        \

#define DECLARE_SINGLETON(className) \
static className *singletonInstance = nil; \
+ (className *)shareInstance { \
@synchronized (self) { \
if (!singletonInstance) { \
singletonInstance = [[self alloc] init]; \
} \
return singletonInstance; \
} \
} \

#pragma mark - Directory
/**
 *  整个应用的文件夹目录
 *
 *  @param _msg
 *
 *  @return path
 */
#define _HYBIRD_PATH_LIBRARY    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/hybird.bundle"]

/**
 *  viewController目录
 *
 *  @param _msg viewController
 *
 *  @return path
 */
#define _HYBIRD_PATH_VIEWCONTROLLER [_HYBIRD_PATH_LIBRARY stringByAppendingPathComponent:@"PrjDir/viewControllers"]

/**
 *  views目录
 *
 *  @param _msg
 *
 *  @return path
 */
#define _HYBIRD_PATH_VIEW [_HYBIRD_PATH_LIBRARY stringByAppendingPathComponent:@"PrjDir/views"]

/**
 *  图片目录
 *
 *  @param _msg
 *
 *  @return path
 */
#define _HYBIRD_PATH_IMAGE [_HYBIRD_PATH_LIBRARY stringByAppendingPathComponent:@"PrjDir/images"]

/**
 *  启动viewcontroller目录
 *
 *  @param _msg
 *
 *  @return path
 */
#define _HYBIRD_START_PATH [_HYBIRD_PATH_VIEWCONTROLLER stringByAppendingPathComponent:@"startViewController.json"]

/**
 *  数据存储目录
 *
 *  @param _msg
 *
 *  @return path
 */
#define _HYBIRD_PATH_DATA [_HYBIRD_PATH_LIBRARY stringByAppendingPathComponent:@"PrjDir/data"]

#define DOCUMENTPATH    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define AUDIO_PATH      [DOCUMENTPATH stringByAppendingPathComponent:@"Audio"]

#define BOOK_PATH       [DOCUMENTPATH stringByAppendingPathComponent:@"Book"]

#define RECORDER_PATH   [DOCUMENTPATH stringByAppendingPathComponent:@"Recorder"]

#pragma mark - Function

#define main_queue dispatch_get_main_queue()

#define global_queue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define _hybird_tips_(_msg) [[NSModelFuctionCenter shareInstance] showTips:_msg];

OBJC_EXPORT void obj_msgSend(id self, SEL op, ...);

@class UIContainerView;
OBJC_EXPORT void runFunction(NSDictionary *dic , UIContainerView * container);

OBJC_EXPORT void alertException(NSString *title,NSString *msg);

OBJC_EXPORT NSDictionary* readFile(NSString *path , NSString *filename);

#define exception_title [NSString stringWithFormat:@"%s\nLine:%d",__PRETTY_FUNCTION__,__LINE__]

#define showException(msg) alertException(exception_title,msg);

#define showIntegerException(key,obj) alertException(exception_title,[NSString stringWithFormat:@"%@ [%@ integerValue]",key,obj]);

#define showFloatException(key,obj) alertException(exception_title,[NSString stringWithFormat:@"%@ [%@ floatValue]",key,obj]);

#define showBoolException(key,obj) alertException(exception_title,[NSString stringWithFormat:@"%@ [%@ boolValue]",key,obj]);

#define showDoubleException(key,obj) alertException(exception_title,[NSString stringWithFormat:@"%@ [%@ doubleValue]",key,obj]);

#pragma mark - NSNotification

#define _NSNotification_MotionShake @"UIEventSubtypeMotionShake"

#define _hybird_post_notification_(_postname,_object) [[NSNotificationCenter defaultCenter] postNotificationName:_postname object:_object];

#pragma mark -block

typedef void(^Block)(void);

typedef enum {
    PROGRESS_TYPE_DEFAULT,
    PROGRESS_TYPE_UPLOAD,       //上传进度
    PROGRESS_TYPE_DOWNLOAD,     //下载进度
    PROGRESS_TYPE_PLAYAUDIO,    //播放进度
    PROGRESS_TYPE_RECORDER,      //录音进度
}PROGRESS_TYPE;
//progresstype (downloadprogress、playaudioprogress、recoderprogres...)
typedef void(^Block_progress)(PROGRESS_TYPE progresstype, long long currentprogress,long long totalprogress);

typedef void(^Block_complete)(BOOL success, id data);

#pragma mark - headers

#import "NSObject+key.h"
#import "NSDictionary+addEntries.h"
#import "UIColor+hex.h"
#import "UIImage+path.h"
#import "BaseAlertView.h"
#import "BaseActionSheet.h"
#import "NSTimer+block.h"
#import "NSModelDataCenter.h"
#import "NSModelFuctionCenter.h"
#import "UIContainerHelper.h"
#import "UIViewControllerHelper.h"

#endif
