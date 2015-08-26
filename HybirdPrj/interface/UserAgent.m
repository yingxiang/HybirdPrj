//
//  UserAgent.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/20.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UserAgent.h"

@interface UserAgent ()<UIWebViewDelegate>

nonatomic_strong(UIWebView,     *webView)
nonatomic_strong(NSString,      *agentString)

@end

@implementation UserAgent

DECLARE_SINGLETON(UserAgent)

- (instancetype)init{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return self;
}

- (void)fetchUserAgent{
    [_webView loadRequest:[NSURLRequest requestWithURL:
                           [NSURL URLWithString:@"http://www.apple.com"]]];
}

- (void)registerToken:(NSString*)token{
    while (!self.agentString) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/app/regtoken?token=%@",[NSModelDataCenter shareInstance].baseUrl , token];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!self.agentString)
    {
        self.agentString = [request valueForHTTPHeaderField:@"User-Agent"];
        // namibox only want to get the useragent
        
        NSString *addUserAgent = [NSString stringWithFormat:@"%@ NamiBox/iOS/%@", self.agentString, _appVersion];
        
        NSLog(@"%@",addUserAgent);
        NSDictionary *dictionary = @{@"UserAgent": addUserAgent};
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
    return YES;
}
@end
