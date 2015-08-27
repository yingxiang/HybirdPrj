//
//  UILabel+sizefit.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/26.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UILabel+sizefit.h"
#import <objc/runtime.h>

static const void *autowidthfitKey = &autowidthfitKey;

@implementation UILabel (sizefit)

- (CGFloat)autowidthfit{
    return [objc_getAssociatedObject(self, autowidthfitKey) floatValue];
}

- (void)setAutowidthfit:(CGFloat)autowidthfit{
    objc_setAssociatedObject(self, autowidthfitKey, [NSNumber numberWithFloat:autowidthfit], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self relayoutIfNeeded];
}

- (void)setfitText:(NSString *)text{
    [self setfitText:text];
    [self relayoutIfNeeded];
}

- (void)relayoutIfNeeded{
    //自动布局自己
    if (self.autowidthfit!=0 && self.text ) {
        if (self.frame.size.width != 0) {

            NSDictionary *fontAttributes = @{
                                             NSFontAttributeName:self.font
                                             };
            
            CGRect titleRect = [self.text boundingRectWithSize:CGSizeMake(self.autowidthfit, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttributes context:nil];
            //
            NSDictionary *layout = self.container.jsonData[@"layout"];
            if (layout) {
                if (layout[@"height"]) {
                    [layout setValue:[NSNumber numberWithFloat:titleRect.size.height] forKey:@"height"];
                    if (layout[@"width"]) {
                        CGFloat width = self.autowidthfit;
                        if (titleRect.size.width < self.autowidthfit) {
                            width = ceilf(titleRect.size.width);
                        }
                        [layout setValue:[NSNumber numberWithFloat:titleRect.size.height] forKey:@"width"];
                    }
                    [self.container setUI:layout];
                }else {
                    //
                    showException(@"UILabel sizefit must set layout height")
                }
            }else{
                //frame 布局
                CGFloat width = self.autowidthfit;
                if (titleRect.size.width < self.autowidthfit) {
                    width = ceilf(titleRect.size.width);
                }
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, ceilf(titleRect.size.height));
                UIView *superView = self.superview;
                while (superView) {
                    NSDictionary *layout = superView.container.jsonData[@"layout"];
                    if (layout) {
                        [superView.container setUI:@{@"layout":layout}];
                    }else{
                        layout = superView.container.jsonData[@"frame"];
                        if (layout) {
                            [superView.container setUI:@{@"frame":layout}];
                        }
                    }
                    superView = superView.superview;
                }
            }
        }
    }
}
@end
