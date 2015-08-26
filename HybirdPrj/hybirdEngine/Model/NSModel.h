//
//  NSModel.h
//  HybirdPrj
//
//  Created by xiang ying on 15/7/14.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSModel : NSObject

nonatomic_strong_readonly (NSMutableDictionary ,*modelList);

- (BOOL)setObject:(id)obj forKey:(NSString*)aKey;

- (id)objectForKey:(NSString*)aKey;

@end
