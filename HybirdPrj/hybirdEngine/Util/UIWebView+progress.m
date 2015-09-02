//
//  UIWebView+progress.m
//  HybirdNamibox
//
//  Created by xiang ying on 15/9/2.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIWebView+progress.h"
#import <objc/runtime.h>

static const void *resourceCountKey             = &resourceCountKey;
static const void *resourceCompletedCountKey    = &resourceCompletedCountKey;
static const void *progressDelegateKey          = &progressDelegateKey;

@implementation UIWebView (progress)
@dynamic resourceCount,resourceCompletedCount;
@dynamic progressDelegate;

- (void)setResourceCount:(int)resourceCount{
    objc_setAssociatedObject(self, resourceCountKey, [NSNumber numberWithInt:resourceCount], OBJC_ASSOCIATION_ASSIGN);
}

- (int)resourceCount{
    return [objc_getAssociatedObject(self, resourceCountKey) intValue];
}


- (void)setResourceCompletedCount:(int)resourceCompletedCount{
    objc_setAssociatedObject(self, resourceCompletedCountKey, [NSNumber numberWithInt:resourceCompletedCount], OBJC_ASSOCIATION_ASSIGN);
}

- (int)resourceCompletedCount{
    return [objc_getAssociatedObject(self, resourceCompletedCountKey) intValue];
}

- (id)progressDelegate{
    return objc_getAssociatedObject(self, progressDelegateKey);
}

- (void)setProgressDelegate:(id<UIWebViewProgressDelegate>)progressDelegate{
    objc_setAssociatedObject(self, progressDelegateKey, progressDelegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - UIWebViewProgressDelegate

- (void)setHBDelegate:(id)delegate{
    [self setHBDelegate:delegate];
    self.progressDelegate = delegate;
}

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    return [NSNumber numberWithInt:self.resourceCount++];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource {
    self.resourceCompletedCount++;
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.progressDelegate webView:self didReceiveResourceNumber:self.resourceCompletedCount totalResources:self.resourceCount];
    }
}

-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    self.resourceCompletedCount++;
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.progressDelegate webView:self didReceiveResourceNumber:self.resourceCompletedCount totalResources:self.resourceCount];
    }
}


@end
