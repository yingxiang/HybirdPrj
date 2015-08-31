//
//  UIContainerWindow.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/3.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerWindow.h"

@interface UIContainerWindow()

nonatomic_strong(UIWindow, *window);

@end

@implementation UIContainerWindow

- (void)createView:(NSDictionary*)dict
{
    if ([dict[@"type"] isEqualToString:@"delegateWindow"]) {
        self.view = [[UIApplication sharedApplication].delegate window];
    }else if([dict[@"type"] isEqualToString:@"statusWindow"]){
        CGRect rect = [UIApplication sharedApplication].statusBarFrame;
        if (dict[@"height"]) {
            rect.size.height = [dict[@"height"] obj_float:nil];
        }
        self.view = [[UIWindow alloc] initWithFrame:rect];
    }else{
        self.view = _obj_alloc(UIWindow)
    }
}

- (void)setView:(id )view{
    [super setView:view];
    _window = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"windowLevel"]) {
            self.window.windowLevel = UIWindowLevelNormal + [obj obj_float:nil];
        }
    }];
    return data;
}

+ (UIContainerView*)containerWindow{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (!window) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [window setBackgroundColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication].delegate setWindow:window];
        [window makeKeyAndVisible];
        
        UIContainerView *windowContainer = newContainer(@{@"identify":@"window_identify",@"type":@"delegateWindow",@"UIContainerType":@"UIContainerWindow",@"windowLevel":@"1"});
        window.strong_container = windowContainer;
    }
    return window.strong_container;
}

- (void)toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
        CGAffineTransform transform = self.view.transform;
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                transform= CGAffineTransformMakeRotation(M_PI);
                break;
            case UIInterfaceOrientationLandscapeLeft:{
                transform= CGAffineTransformMakeRotation(-M_PI/2);
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                transform= CGAffineTransformMakeRotation(M_PI/2);
            }
                break;
            case UIInterfaceOrientationPortrait:
                transform= CGAffineTransformMakeRotation(M_PI*0);
                break;
            default:
                break;
        }
        self.view.transform = transform;
}

@end
