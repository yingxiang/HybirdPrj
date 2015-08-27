//
//  URLCache.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/20.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCache : NSURLCache

DECLARE_AS_SINGLETON(URLCache)

- (void)cache;

- (BOOL)webView:(id)webView loadRequest:(NSURL*)url;

@end
