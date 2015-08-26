//
//  UILabel+sizefit.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/26.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UILabel+sizefit.h"
#import <objc/runtime.h>

static const void *sizefitKey = &sizefitKey;

@implementation UILabel (sizefit)

- (BOOL)autoSizefit {
    return [objc_getAssociatedObject(self, sizefitKey) boolValue];
}

- (void)setAutoSizefit:(BOOL)autoSizefit{
    objc_setAssociatedObject(self, sizefitKey, [NSNumber numberWithBool:autoSizefit], OBJC_ASSOCIATION_ASSIGN);
    [self relayoutIfNeeded];
}

- (void)setfitText:(NSString *)text{
    [self setfitText:text];
    [self relayoutIfNeeded];
}

- (void)relayoutIfNeeded{
    //自动布局自己
    if (self.autoSizefit && self.text ) {
        if (self.frame.size.width != 0) {
            NSDictionary *fontAttributes = @{
                                             NSFontAttributeName:self.font
                                             };
            
            CGRect titleRect = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttributes context:nil];
            //
            NSDictionary *layout = self.container.jsonData[@"layout"];
            if (layout) {
                if (layout[@"height"]) {
                    [layout setValue:[NSNumber numberWithFloat:titleRect.size.height] forKey:@"height"];
                    [self.container setUI:layout];
                }else if (layout[@"top"] && layout[@"bottom"]){
                    
                }
            }else{
                //frame 布局
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, ceilf(titleRect.size.height));
            }
        }
    }
}
@end
