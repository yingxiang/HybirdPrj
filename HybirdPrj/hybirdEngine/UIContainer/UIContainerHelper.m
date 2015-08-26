//
//  UIContainerHelper.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerHelper.h"

@implementation UIContainerHelper

DECLARE_SINGLETON(UIContainerHelper);

+ (id)createViewContainerWithDic:(NSDictionary*)aDic{
    NSString *_uiContainerTypeView = [aDic objectForKey:@"UIContainerType"];
    
    UIContainerView *container = nil;
    
    @try {
        if ([aDic[@"identify"] hasPrefix:@"~/"]) {
            NSString *className = [aDic[@"identify"] substringFromIndex:2];
            NSDictionary *vDic = readFile(_HYBIRD_PATH_VIEW, className);
            _uiContainerTypeView = [vDic objectForKey:@"UIContainerType"];
            container = [[NSClassFromString(_uiContainerTypeView) alloc] initWithDict:vDic];
        
        }else{
            if (!_uiContainerTypeView) {
                showException(aDic.description);
            }
            container = [[NSClassFromString(_uiContainerTypeView) alloc] initWithDict:aDic];
        }

    }
    @catch (NSException *exception) {
        showException(exception.description);
        container = nil;
    }
    @finally {

    }
    
    return container;

}

@end
