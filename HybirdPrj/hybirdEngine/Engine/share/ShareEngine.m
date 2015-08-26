//
//  ShareEngine.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "ShareEngine.h"
#import <WXApi.h>
#import <Weibo/WeiboSDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define PostImageData @"https://upload.api.weibo.com/2/statuses/upload.json"

//#define kRedirectURI @"http://sns.whalecloud.com/sina2/callback"

@implementation ShareObject

+(instancetype)shareObject:(NSDictionary*)dic{
    ShareObject *object = [[ShareObject alloc] init];
    
    object.shareType = (SHARE_TYPE)[dic[@"shareType"] obj_integer:^(BOOL success) {
        if (!success) {
            showIntegerException(@"shareType", dic);
        }
    }];
    
    if (dic[@"shareTitle"]) {
        object.shareTitle = dic[@"shareTitle"];
    }else{
        showException(@"shareTitle = nil");
    }
    
    if (dic[@"shareContent"]) {
        object.shareContent = dic[@"shareContent"];
    }else{
        showException(@"shareContent = nil");
    }
    [UIImage imageByPath:dic[@"shareImage"] image:^(UIImage *image) {
        object.shareImage = image;
    }];
    
    object.shareUrl = dic[@"shareUrl"];
    
    return object;
}


@end

#pragma mark -

@interface ShareEngine ()<WXApiDelegate,WBHttpRequestDelegate,WeiboSDKDelegate,TencentSessionDelegate,QQApiInterfaceDelegate>

nonatomic_copy    (ShareManageCallback,   callBack)
nonatomic_strong  (NSString,              *wxKey)
nonatomic_strong  (NSString,              *wbKey)
nonatomic_strong  (NSString,              *wbRedirecturl)
nonatomic_strong  (NSString,              *qqKey)
nonatomic_strong  (TencentOAuth,          *tencentOAuth)

@end

@implementation ShareEngine

DECLARE_SINGLETON(ShareEngine)

- (instancetype)init{
    self = [super init];
    if (self) {
        NSArray *schemes = _infoDictionary[@"CFBundleURLTypes"];
        
        for (NSDictionary *urlscheme in schemes) {
            if ([urlscheme[@"CFBundleURLName"] isEqualToString:@"weixin"]) {
                self.wxKey = urlscheme[@"CFBundleURLSchemes"][0];
            }else if ([urlscheme[@"CFBundleURLName"] isEqualToString:@"com.weibo"]){
                NSArray *CFBundleURLSchemes = urlscheme[@"CFBundleURLSchemes"];
                NSString *schemeString = CFBundleURLSchemes[0];
                //去掉wb
                if ([[schemeString lowercaseString] hasPrefix:@"wb"]) {
                    schemeString = [schemeString substringFromIndex:2];
                }
                self.wbKey = schemeString;
                if (urlscheme[@"redirecturl"]) {
                    self.wbRedirecturl = urlscheme[@"redirecturl"];
                }else{
                    showException(@"没有配置微博分享回调url，请在URL types里添加");
                }
            }else if ([urlscheme[@"CFBundleURLName"] isEqualToString:@"QQ"]){
                //去掉qq开头的qq
                NSArray *CFBundleURLSchemes = urlscheme[@"CFBundleURLSchemes"];
                NSString *schemeString = CFBundleURLSchemes[0];
                if ([[schemeString lowercaseString] hasPrefix:@"tencent"]) {
                    schemeString = [schemeString substringFromIndex:7];
                }
                self.qqKey = schemeString;
            }
        }
    }
    return self;
}

- (void)registerApp{
    [WXApi registerApp:self.wxKey];
    [WeiboSDK registerApp:self.wbKey];
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.qqKey andDelegate:self];
    
#ifdef DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
}

- (void)shareCallBack:(ShareManageCallback)callback{
    self.callBack = callback;
    if (self.shareObject.shareType == SHARE_TYPE_Weibo) {
        //微博分享
        if ([WeiboSDK isWeiboAppInstalled]) {
            WBMessageObject *message = [WBMessageObject message];
            if (self.shareObject.shareContent)
            {
                message.text = [NSString stringWithFormat:@"%@ %@",_shareObject.shareContent,_shareObject.shareUrl];
            }
            
            if (_shareObject.shareImage)
            {
                WBImageObject *imgObject = [WBImageObject object];
                NSData *data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
                while (data.length>32*1024) {
                    _shareObject.shareImage = [UIImage scaleImage:[UIImage imageWithData:data] toScale:0.9];
                    data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
                }
                imgObject.imageData = data;
                message.imageObject = imgObject;
            }
            
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
            [WeiboSDK sendRequest:request];
        }else{
            
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = self.wbRedirecturl;
            authRequest.scope = @"all";
            [WeiboSDK sendRequest:authRequest];
        }
    }else if (self.shareObject.shareType == SHARE_TYPE_WX_FRIEND || self.shareObject.shareType == SHARE_TYPE_WX_Timeline){
        //
        if (![WXApi isWXAppInstalled]) {
            [self callBackResult:NO message:@"未安装微信客户端"];
        }else if(![WXApi isWXAppSupportApi]){
            [self callBackResult:NO message:@"微信版本不支持分享"];
        }else{
            WXMediaMessage *mess = [WXMediaMessage message];
            
            mess.title = _shareObject.shareTitle;
            mess.description = _shareObject.shareContent;
            
            NSData *data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
            while (data.length>32*1024) {
                _shareObject.shareImage = [UIImage scaleImage:[UIImage imageWithData:data] toScale:0.9];
                data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
            }
            
            [mess setThumbData:data];
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = _shareObject.shareUrl;
            mess.mediaObject = ext;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = mess;
            req.scene = self.shareObject.shareType;
            [WXApi sendReq:req];
        }
    }else if (self.shareObject.shareType == SHARE_TYPE_QQ ||self.shareObject.shareType == SHARE_TYPE_QQZone){
        NSData *data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
        while (data.length>32*1024) {
            _shareObject.shareImage = [UIImage scaleImage:[UIImage imageWithData:data] toScale:0.9];
            data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
        }
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:_shareObject.shareUrl]
                                    title:_shareObject.shareTitle
                                    description:_shareObject.shareContent
                                    previewImageData:data];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode resultCode = EQQAPISENDSUCESS;
        if (self.shareObject.shareType == SHARE_TYPE_QQ) {
            //将内容分享到qq
            resultCode = [QQApiInterface sendReq:req];
        }else{
            //将内容分享到空间
            resultCode = [QQApiInterface SendReqToQZone:req];
        }
        if (resultCode != EQQAPISENDSUCESS ) {
            //分享失败
            [self callBackResult:NO message:[NSString stringWithFormat:@"QQApiSendResultCode:%d",resultCode]];
        }
    }
}

- (void)callBackResult:(BOOL)success message:(NSString*)msg{
    if (self.callBack) {
        self.callBack(success,msg);
        _callBack = nil;
        self.shareObject = nil;
    }
}

- (BOOL)handle:(NSURL *)url
{
    if (url == nil || [url isEqual:@""]) {
        return NO;
    }
    NSString *sourceURLString = url.absoluteString;
    if([sourceURLString rangeOfString:self.wbKey].location!=NSNotFound){
        if (self.callBack) {
            return [WeiboSDK handleOpenURL:url delegate:self];
        }
    }else if ([sourceURLString rangeOfString:self.wxKey].location!=NSNotFound){
        if (self.callBack) {
            return [WXApi handleOpenURL:url delegate:self];
        }
    }else if ([sourceURLString rangeOfString:self.qqKey].location!=NSNotFound){
        if (self.callBack) {
            return [QQApiInterface handleOpenURL:url delegate:self];
        }
    }
    return YES;
}


#pragma mark - QQ 

- (BOOL)wxisInstalled{
    return [WXApi isWXAppInstalled];
}

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(id)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SendMessageToWXResp *respond = (SendMessageToWXResp*)resp;
        if (respond.errCode == WXSuccess)
        {
            [self callBackResult:YES message:@"分享成功"];
        }
        else {
            NSString *msg = @"分享失败";
            if (respond.errCode == WXErrCodeUserCancel) {
                msg = @"已取消分享";
            }else if(respond.errCode == WXErrCodeSentFail){
                msg = @"发送失败";
            }
            [self callBackResult:NO message:msg];
        }
    }else if ([resp isKindOfClass:[QQBaseResp class]]){
        QQBaseResp *respond = (QQBaseResp*)resp;
        if ([respond.result obj_integer:nil] == 0) {
            [self callBackResult:YES message:@"分享成功"];
        }else {
            [self callBackResult:NO message:@"分享失败"];
        }
    }
}

#pragma mark - QQ

- (BOOL)qqisInstalled{
    return [QQApiInterface isQQInstalled];
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
}

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin{
    
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork{
    
}

#pragma mark - Weibo

- (void)weiboWebShare:(NSString*)token{
    //
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    if (_shareObject.shareContent.length!=0) {
        if (_shareObject.shareUrl) {
            [para setValue:[NSString stringWithFormat:@"%@ %@",_shareObject.shareContent,_shareObject.shareUrl] forKey:@"status"];
        }else{
            [para setValue:_shareObject.shareContent forKey:@"status"];
        }
    }else{
        if (_shareObject.shareUrl) {
            [para setValue:_shareObject.shareUrl forKey:@"status"];
        }
    }
    if (_shareObject.shareImage) {
        NSData *data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
        while (data.length>32*1024) {
            _shareObject.shareImage = [UIImage scaleImage:[UIImage imageWithData:data] toScale:0.9];
            data = UIImageJPEGRepresentation(_shareObject.shareImage, 0);
        }
        [para setValue:data forKey:@"pic"];
    }
    
    [WBHttpRequest requestWithAccessToken:token url:PostImageData httpMethod:@"POST" params:para delegate:self withTag:@"share"];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            //分享成功
            [self callBackResult:YES message:@"分享成功"];
        }else{
            [self callBackResult:NO message:@"分享失败"];
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            //
            [self weiboWebShare:[(WBAuthorizeResponse*)response accessToken]];
            
        }else{
            [self callBackResult:NO message:@"授权失败"];
        }
    }
}

#pragma WBHttpRequest Delegate
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    [self callBackResult:NO message:@"分享失败"];
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSRange errorRange = [result rangeOfString:@"error_code"];
    
    if (errorRange.location!=NSNotFound) {
        [self callBackResult:NO message:[NSString stringWithFormat:@"分享失败\n%@",result]];
    }else {
        [self callBackResult:YES message:@"分享成功"];
    }
}

@end
