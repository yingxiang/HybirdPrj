//
//  UIWebView+progress.h
//  HybirdNamibox
//
//  Created by xiang ying on 15/9/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UIWebViewProgressDelegate <UIWebViewDelegate>

@optional
- (void) webView:(UIWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;

@end

@interface UIWebView (progress)

nonatomic_assign(int, resourceCount)
nonatomic_assign(int, resourceCompletedCount)
nonatomic_weak  (id<UIWebViewProgressDelegate>, progressDelegate)

@end
