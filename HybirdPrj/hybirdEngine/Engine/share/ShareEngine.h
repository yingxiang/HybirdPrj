//
//  ShareEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSModel.h"
#import <WXApiObject.h>

typedef void (^ShareManageCallback)(BOOL success,NSString*msg);

typedef enum {
    SHARE_TYPE_WX_FRIEND    = WXSceneSession,   //0
    SHARE_TYPE_WX_Timeline  = WXSceneTimeline,  //1
    SHARE_TYPE_Weibo        = 2,               //2
    SHARE_TYPE_QQ           = 3,
    SHARE_TYPE_QQZone       = 4,
}SHARE_TYPE;


@interface ShareObject : NSObject

nonatomic_assign  (SHARE_TYPE, shareType)
nonatomic_copy    (NSString,  *shareTitle)
nonatomic_copy    (NSString,  *shareContent)
nonatomic_copy    (NSString,  *shareUrl)
nonatomic_strong  (UIImage,   *shareImage)

+ (instancetype)shareObject:(NSDictionary*)dic;

@end

@interface ShareEngine : NSObject

nonatomic_strong(ShareObject, *shareObject)

DECLARE_AS_SINGLETON(ShareEngine)

- (void)registerApp;

- (void)shareCallBack:(ShareManageCallback)callback;

- (BOOL)handle:(NSURL *)url;

- (BOOL)wxisInstalled;

- (BOOL)qqisInstalled;

@end
