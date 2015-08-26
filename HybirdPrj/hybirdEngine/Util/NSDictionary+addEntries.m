//
//  NSMutableDictionary+addEntries.m
//  dicadd
//
//  Created by xiangying on 15/8/24.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSDictionary+addEntries.h"

@implementation NSDictionary (addEntries)

- (void)addEntries:(NSDictionary*)dic{
    for (NSString *key in dic.allKeys) {
        id value = dic[key];
        if (self[key]!=nil) {
            if ([value isKindOfClass:[NSDictionary class]]&&[self[key] isKindOfClass:[NSDictionary class]]) {
                [self[key] addEntries:value];
                [self setValue:self[key] forKey:key];
            }else if([value isKindOfClass:[NSArray class]]&&[self[key] isKindOfClass:[NSArray class]]){
                NSArray *array = self[key];
                for (id item in value) {
                    if ([item isKindOfClass:[NSDictionary class]]) {
                        //复制item的值给原来的数据
                        if (item[@"identify"]) {
                            for (id cell in array) {
                                if ([cell[@"identify"] isEqualToString:item[@"identify"]]) {
                                    [cell addEntries:item];
                                    break;
                                }
                            }
                        }
                    }
                }
            }else {
                [self setValue:value forKey:key];
            }
        }else{
            [self setValue:value forKey:key];
        }
    }
}

@end
