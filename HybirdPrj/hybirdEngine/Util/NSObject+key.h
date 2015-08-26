//
//  NSObject+key.h
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(BOOL success);

@interface NSObject (key)

nonatomic_strong(NSString, *identify)

- (id)getProperty:(NSString*)property;

- (NSInteger)obj_integer:(successBlock)block;

- (CGFloat)obj_float:(successBlock)block;

- (CGFloat)obj_double:(successBlock)block;

- (BOOL)obj_bool:(successBlock)block;

- (id)obj_copy;

/**
 *  动态取值
 *
 *  @param obj  配置信息
 *  @param data 目标源数据
 *
 *  @return 最终数据
 */
- (id)assignment:(id)obj :(NSDictionary*)data;


#pragma mark - for Exception

- (id)objectForKey:(NSString*)aKey;

- (id)objectForKeyedSubscript:(NSString*)aKey;

- (void)setObject:(id)obj forKey:(NSString*)aKey;

@end
