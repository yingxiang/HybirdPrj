//
//  UIContainerWebView.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerWebView.h"
#import "WebViewJavascriptBridge.h"
#import "NSModelFuctionCenter.h"
#import "NSString+TPCategory.h"
#import <WebKit/WebKit.h>
#import "URLCache.h"
#import "UIWebView+progress.h"

#pragma mark - ios8 webview

typedef NSDictionary WVJBMessage;

@interface  WKJSBridge: NSObject

nonatomic_strong  (NSMutableArray,      *startupMessageQueue)
nonatomic_strong  (NSMutableDictionary, *responseCallbacks)
nonatomic_strong  (NSMutableDictionary, *messageHandlers)
nonatomic_assign  (long,                uniqueId)
nonatomic_copy    (WVJBHandler,           messageHandler)
nonatomic_assign  (NSUInteger,          numRequestsLoading)
nonatomic_weak    (WKWebView,             *webView)

@end

@implementation WKJSBridge

- (void)dealloc{
    
}

+ (instancetype)bridgeForWebView:(WKWebView*)webView handler:(WVJBHandler)messageHandler{
    WKJSBridge* bridge = [[WKJSBridge alloc] init];
    bridge.messageHandler = messageHandler;
    bridge.webView = webView;
    bridge.startupMessageQueue = [NSMutableArray array];
    bridge.responseCallbacks = [NSMutableDictionary dictionary];
    bridge.uniqueId = 0;
    bridge.messageHandlers = [NSMutableDictionary dictionary];
    return bridge;
}

- (void)dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];

    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
        });
    }
}

- (void)runJavscript{
    [self.webView evaluateJavaScript:@"WebViewJavascriptBridge._fetchQueue();" completionHandler:^(id messageQueueString, NSError *error) {
        id messages = [NSJSONSerialization JSONObjectWithData:[messageQueueString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        if ([messages isKindOfClass:[NSArray class]]) {
            for (NSDictionary* message in messages) {
                if (![message isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
                    continue;
                }
                
                NSString* responseId = message[@"responseId"];
                if (responseId) {
                    WVJBResponseCallback responseCallback = self.responseCallbacks[responseId];
                    responseCallback(message[@"responseData"]);
                    [self.responseCallbacks removeObjectForKey:responseId];
                } else {
                    WVJBResponseCallback responseCallback = NULL;
                    NSString* callbackId = message[@"callbackId"];
                    if (callbackId) {
                        responseCallback = ^(id responseData) {
                            if (responseData == nil) {
                                responseData = [NSNull null];
                            }
                            
                            NSDictionary* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                            if (self.startupMessageQueue) {
                                [self.startupMessageQueue addObject:msg];
                            } else {
                                [self dispatchMessage:msg];
                            }
                        };
                    } else {
                        responseCallback = ^(id ignoreResponseData) {
                            // Do nothing
                        };
                    }
                    
                    WVJBHandler handler;
                    if (message[@"handlerName"]) {
                        handler = self.messageHandlers[message[@"handlerName"]];
                    } else {
                        handler = self.messageHandler;
                    }
                    
                    if (!handler) {
                        [NSException raise:@"WVJBNoHandlerException" format:@"No handler for message from JS: %@", message];
                    }
                    handler(message[@"data"], responseCallback);
                }
            }
        }
    }];

}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback{
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        _responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (_startupMessageQueue) {
        [_startupMessageQueue addObject:message];
    } else {
        [self dispatchMessage:message];
    }
}

@end

#pragma mark -

@interface UIContainerWebView()<UIWebViewProgressDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

nonatomic_strong(UIWebView              , *webView)
nonatomic_strong(WebViewJavascriptBridge, *javascriptBridge)

nonatomic_assign(BOOL                   , useNewWebView)
nonatomic_strong(WKWebView              , *wkwebView)
nonatomic_strong(WKJSBridge             , *wkjavascriptBridge)

@end

@implementation UIContainerWebView

- (void)dealloc{
    if (self.wkwebView) {
        [self.wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

- (void)createView:(NSDictionary*)dict
{
    if ([dict[@"useNewWebView"] obj_bool:nil] && [_sysVersion floatValue]>=8.0) {
        self.useNewWebView = YES;
    }
    if (self.useNewWebView) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addUserScript:script];
//        [config.userContentController addScriptMessageHandler:self name:@"observe"];
        self.view = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        self.wkwebView.navigationDelegate = self;
        self.wkwebView.UIDelegate = self;
        __weak __typeof(self)weakSelf = self;
        self.wkjavascriptBridge = [WKJSBridge bridgeForWebView:self.wkwebView handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"ObjC received message from JS: %@", data);
            [weakSelf receiveCommand:data handler:responseCallback];
        }];
        [self.wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }else{
        self.view = _obj_alloc(UIWebView)
        __weak __typeof(self)weakSelf = self;
        self.javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"ObjC received message from JS: %@", data);
            [weakSelf receiveCommand:data handler:responseCallback];
        }];
        self.webView.progressDelegate = self;
    }
}

- (void)setView:(id )view{
    [super setView:view];
    if (_useNewWebView) {
        _wkwebView = view;
    }else{
        _webView = view;
    }
}

- (UIScrollView*)scrollView{
    if (_webView.scrollView) {
        return _webView.scrollView;
    }
    return _wkwebView.scrollView;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    
    if (_useNewWebView) {
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqualToString:@"url"]){
                NSURL * url = [NSURL URLWithString:obj];
                [self loadRequest:[NSURLRequest requestWithURL:url]];
            }else if ([key isEqualToString:@"allowsBackForwardNavigationGestures"]){
                self.wkwebView.allowsBackForwardNavigationGestures = [obj obj_bool:nil];
            }
        }];
    }else{
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            obj = [self assignment:obj :data];

            if ([key isEqualToString:@"scalesPageToFit"]) {
                self.webView.scalesPageToFit = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"dataDetectorTypes"]) {
                self.webView.dataDetectorTypes = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"dataDetectorTypes"]) {
                self.webView.dataDetectorTypes = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"allowsInlineMediaPlayback"]) {
                self.webView.allowsInlineMediaPlayback = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"mediaPlaybackRequiresUserAction"]) {
                self.webView.mediaPlaybackRequiresUserAction = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"mediaPlaybackAllowsAirPlay"]) {
                self.webView.mediaPlaybackAllowsAirPlay = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"suppressesIncrementalRendering"]) {
                self.webView.suppressesIncrementalRendering = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);

                    }
                }];
            }else if ([key isEqualToString:@"keyboardDisplayRequiresUserAction"]) {
                self.webView.keyboardDisplayRequiresUserAction = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);

                    }
                }];
            }else if ([key isEqualToString:@"paginationMode"]) {
                self.webView.paginationMode = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"pageLength"]) {
                self.webView.pageLength = [obj obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"url"]){
                NSURL * url = [NSURL URLWithString:obj];
                [self loadRequest:[NSURLRequest requestWithURL:url]];
            }
        }];
    }
    return data;
}

#pragma mark - actions
- (void)reload{
    obj_msgSend(self.view, @selector(reload));
}

- (void)loadRequest:(NSURLRequest *)request{
    obj_msgSend(self.view, @selector(loadRequest:),request);
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    obj_msgSend(self.view, @selector(loadHTMLString:baseURL:),string,baseURL);
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL{
    obj_msgSend(self.view, @selector(loadData:MIMEType:textEncodingName:baseURL:),data,MIMEType,textEncodingName,baseURL);
}

#pragma mark - JS 指令处理

- (void)sendCommond:(NSDictionary*)dic{
    if (self.javascriptBridge) {
        [self.javascriptBridge send:dic responseCallback:^(id responseData) {
            NSMutableDictionary *function = [[[NSModelFuctionCenter shareInstance] objectForKey:[dic[@"command"] stringByAppendingString:@"_response"]] obj_copy];
            if (function) {
                //回调处理
                [function addEntries:[dic obj_copy]];
                runFunction(function, self);
            }
        }];
    }else if (self.wkjavascriptBridge){
        [self.wkjavascriptBridge send:dic responseCallback:^(id responseData) {
            NSMutableDictionary *function = [[[NSModelFuctionCenter shareInstance] objectForKey:[dic[@"command"] stringByAppendingString:@"_response"]] obj_copy];
            if (function) {
                //回调处理
                [function addEntries:[dic obj_copy]];
                runFunction(function, self);
            }
        }];
    }
}

/**
 *  处理页面发起的JS调用
 *
 *  @param dic              页面传入的参数
 *  @param responseCallback 返回APP处理结果
 */
- (void)receiveCommand:(NSDictionary*)dic handler:(void(^)(id data))responseCallback
{
    NSLog(@"start dic command is:%@",dic[@"command"]);
    NSDictionary *command = [[NSModelFuctionCenter shareInstance] objectForKey:dic[@"command"]];
    
    if (command) {
        NSMutableDictionary *function = [dic obj_copy];
        if (dic[@"operation"]) {
            [function addEntries:[command[dic[@"operation"]] obj_copy]];
        }else{
            [function addEntries:[command obj_copy]];
        }
        runFunction(function, self);
        
        if (responseCallback) {
            id result = [self getValue:function[@"result"]];
            responseCallback(result);
        }
    }else{
        showException(dic.description);
    }
}

- (void)goBack{
    if (self.webView) {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }else{
            [[UIViewControllerHelper shareInstance] goBackanimated:YES];
        }
    }else if(self.wkwebView){
        if ([self.wkwebView canGoBack]) {
            [self.wkwebView goBack];
        }else{
            [[UIViewControllerHelper shareInstance] goBackanimated:YES];
        }
    }
}

#pragma mark - IOS 8.0 以下webView执行方法
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (self.view.viewController.title.length == 0) {
        NSString *theTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.view.viewController.title = theTitle;
    }
    return [[URLCache shareInstance] webView:webView loadRequest:request.URL];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSMutableDictionary *function = [self.functionList[@"webViewDidStartLoad:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.view.viewController.title.length == 0) {
        NSString *theTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.view.viewController.title = theTitle;
    }
    NSMutableDictionary *function = [self.functionList[@"webViewDidFinishLoad:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSMutableDictionary *function = [self.functionList[@"webView:didFailLoadWithError:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

- (void) webView:(UIWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources{
    NSMutableDictionary *function = [self.functionList[@"webView:didReceiveResourceNumber:totalResources:"] obj_copy];
    if (function) {
        [function setObject:[NSNumber numberWithInt:resourceNumber] forKey:@"parmer1"];
        [function setObject:[NSNumber numberWithInt:totalResources] forKey:@"parmer2"];
        runFunction(function, self);
    }
}

#pragma mark - IOS 8.0 以上wkwebView执行方法
#pragma mark - WKNavigationDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSMutableDictionary *function = [self.functionList[@"webView:didReceiveResourceNumber:totalResources:"] obj_copy];
        if (function) {
            [function setObject:change[@"new"] forKey:@"parmer1"];
            [function setObject:@"1" forKey:@"parmer2"];
            runFunction(function, self);
        }
    }
}

//1、页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSMutableDictionary *function = [self.functionList[@"webView:didStartProvisionalNavigation:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

//2、当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}

//3、页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSMutableDictionary *function = [self.functionList[@"webView:didFinishNavigation:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

//4、页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSMutableDictionary *function = [self.functionList[@"webView:didFailNavigation:withError:"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

//接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}

//在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if (self.view.viewController.title.length == 0) {
        self.view.viewController.title = webView.title;
    }
    if ([navigationAction.request.URL.absoluteString isEqualToString:@"wvjbscheme://__WVJB_QUEUE_MESSAGE__"]) {
        [self.wkjavascriptBridge runJavscript];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        if([[URLCache shareInstance] webView:self.wkwebView loadRequest:navigationAction.request.URL]){
            decisionHandler(WKNavigationActionPolicyAllow);
        }else{
//            decisionHandler(WKNavigationActionPolicyCancel);
        }
        decisionHandler(WKNavigationActionPolicyAllow);

    }
}

/*
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
}
*/

#pragma mark - WKUIDelegate
//创建一个新的webview
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    return webView;
}

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler{
    [BaseAlertView alertWithTitle:message message:nil clickIndex:^(NSInteger index) {
        completionHandler();
    } cancelButtonTitle:@"确定" otherButtonTitles:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    [BaseAlertView alertWithTitle:message message:nil clickIndex:^(NSInteger index) {
        if (index == 0) {
            completionHandler(NO);
        }else{
            completionHandler(YES);
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"]];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler{
    completionHandler(prompt);
}

@end
