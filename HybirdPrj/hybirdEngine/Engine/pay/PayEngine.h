//
//  PayEngine.h
//  HybirdPrj
//
//  Created by xiangying on 15/8/4.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PAY_TYPE_WX             = 0,    //微信支付
    PAY_TYPE_QQ             = 1,    //QQ支付
    PAY_TYPE_ALI            = 2,    //支付宝支付
}PAY_TYPE;

@interface PayEngine : NSObject

@end
