//
//  NSObject+key.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSObject+key.h"
#import <objc/runtime.h>

static const void *keyKey       = &keyKey;
static const void *blocksKey    = &blocksKey;

@implementation NSObject (key)

#pragma mark - category properties

- (NSString *)identify {
    return objc_getAssociatedObject(self, keyKey);
}

- (void)setIdentify:(NSString *)identify{
    objc_setAssociatedObject(self, keyKey, identify, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)blocks{
    return objc_getAssociatedObject(self, blocksKey);
}

- (void)setBlocks:(NSMutableDictionary *)blocks{
    objc_setAssociatedObject(self, blocksKey, blocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - get properties (safe)
- (id)getProperty:(NSString*)property{
    id value = nil;

    if (![property isEqualToString:@"nil"]) {        
        @try {
            if ([property hasPrefix:@"Instance-"]) {
                //取单例
                NSString *className = [property substringFromIndex:9];
                value = [NSClassFromString(className) shareInstance];
            }else{
                value = [self valueForKey:property];
            }
        }
        @catch (NSException *exception) {
            showException(exception.description);
        }
        @finally {
            
        }
    }
    return value;
}

- (NSInteger)obj_integer:(successBlock)block{
    NSInteger integervalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        integervalue = [(NSString*)self integerValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        integervalue = [(NSNumber*)self integerValue];
        success = YES;
    }
    
    if (block) {
        block(success);
    }
    return integervalue;
}

- (CGFloat)obj_float:(successBlock)block{
    CGFloat floatvalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        floatvalue = [(NSString*)self floatValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        floatvalue = [(NSNumber*)self floatValue];
        success = YES;
    }
    if (block) {
        block(success);
    }
    return floatvalue;
}

- (CGFloat)obj_double:(successBlock)block{
    CGFloat doublevalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        doublevalue = [(NSString*)self doubleValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        doublevalue = [(NSNumber*)self doubleValue];
        success = YES;
    }
    if (block) {
        block(success);
    }
    return doublevalue;
}

- (BOOL)obj_bool:(successBlock)block{
    BOOL boolvalue = NO;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        boolvalue = [(NSString*)self boolValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        boolvalue = [(NSNumber*)self boolValue];
        success = YES;
    }
    if (block) {
        block(success);
    }
    return boolvalue;
}

- (id)obj_copy{
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [(NSDictionary*)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [dic setObject:[obj obj_copy] forKey:[key obj_copy]];
        }];
        return dic;
    }else if([self isKindOfClass:[NSString class]]){
        return [self copy];
    }else if ([self isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [NSMutableArray array];
        for (id obj in (NSArray*)self) {
            [array addObject:[obj obj_copy]];
        }
        return array;
    }else if([self isKindOfClass:[NSNumber class]]){
        return self;
    }else {
        NSString *classname = NSStringFromClass([self class]);
        if ([classname hasPrefix:@"__NSCF"] && ![classname isEqualToString:@"NSObject"]) {
            //自定义类
            unsigned int propertyCount;
            objc_property_t *pProperty = class_copyPropertyList([self class], &propertyCount);
            if (propertyCount > 0) {
                id object = [[NSClassFromString(classname) alloc] init];

                for (int i = 0; i<propertyCount; i++) {
                    objc_property_t property = pProperty[i];
                    NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                    [object setValue:[[self valueForKey:propertyname] obj_copy] forKey:propertyname];
                }
                //查找父类属性
                Class A = [[self class] superclass];
                if (A) {
                    while (![NSStringFromClass(A) isEqualToString:@"NSObject"]) {
                        pProperty = class_copyPropertyList(A, &propertyCount);
                        for (int i = 0; i<propertyCount; i++) {
                            objc_property_t property = pProperty[i];
                            NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                            [object setValue:[[self valueForKey:propertyname] obj_copy] forKey:propertyname];
                        }
                        A = [A superclass];
                        if (!A) {
                            break;
                        }
                    }
                }
                return object;
            }
        }
    }
    return self;
}

- (id)assignment:(id)object :(NSDictionary*)data{
    if ([object isKindOfClass:[NSString class]]) {
        //动态取值
        if ([object hasPrefix:@"parmer~"]) {
            NSString *aKey = [object substringFromIndex:7];
            NSArray *array = [aKey componentsSeparatedByString:@"("];
            if (array.count == 1) {
                if (data[aKey]) {
                    object = data[aKey];
                }
            }else{
                //存在多个值表示是一个计算式
                object = [object substringFromIndex:7];
                for (int i = 1;i<array.count;i++) {
                    NSString *key = array[i];
                    NSRange range = [key rangeOfString:@")"];
                    if (range.length != 0) {
                        NSString *bKey = [key substringToIndex:range.location];
                        if (data[bKey]) {
                            object = [object stringByReplacingOccurrencesOfString:bKey withString:[NSString stringWithFormat:@"%@",data[bKey]]];
                        }
                    }
                }
            }
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]]){
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id replaceObj = [self assignment:obj :data];
            if (replaceObj!=obj) {
                //找到了对应的值
                [object setValue:replaceObj forKey:key];
            }
        }];
    }else if ([object isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [NSMutableArray arrayWithArray:object];
        for (int i = 0;i<array.count;i++) {
            id obj = array[i];
            id replaceObj = [self assignment:obj :data];
            if (replaceObj!=obj) {
                //找到了对应的值
                [array replaceObjectAtIndex:i withObject:replaceObj];
            }
        }
        return array;
    }
    return object;
}

#pragma mark - exception (safe)
//for Exception
- (id)objectForKey:(NSString*)aKey{
    showException(aKey)
//    NSString *msg = [NSString stringWithFormat:@"%@\n%@",exception_title,aKey];
//    _hybird_tips_(msg)
    return nil;
}

//obj[aKey]
- (id)objectForKeyedSubscript:(NSString*)aKey{
    showException(aKey)
//    NSString *msg = [NSString stringWithFormat:@"%@\n%@",exception_title,aKey];
//    _hybird_tips_(msg)
    return nil;
}

- (void)setObject:(id)obj forKey:(NSString*)aKey{
    showException(aKey)
//    NSString *msg = [NSString stringWithFormat:@"%@\n:%@ :%@",exception_title,obj,aKey];
//    _hybird_tips_(msg)
}

#pragma mark - thread block
- (void)backgroundSelector:(NSArray*)args{
    NSString *key = [args firstObject];
    Block_complete block = self.blocks[key];
    if (block) {
        if (args.count == 2) {
            block(YES,[args lastObject]);
        }else{
            block(YES,nil);
        }
        [self.blocks removeObjectForKey:key];
    }
}

- (void)mainSelector:(NSArray*)args{
    NSString *key = [args firstObject];
    Block_complete block = self.blocks[key];
    if (block) {
        if (args.count == 2) {
            block(YES,[args lastObject]);
        }else{
            block(YES,nil);
        }
        [self.blocks removeObjectForKey:key];
    }
}

- (void)runmain:(id)arg selector:(Block_complete)block{
    if (block) {
        SEL selector = @selector(mainSelector:);
        if (!self.blocks) {
            self.blocks = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%p",block];
        [self.blocks setObject:block forKey:key];
        [self performSelectorOnMainThread:selector withObject:@[key,arg] waitUntilDone:YES];
    }
}

- (void)runbackground:(id)arg selector:(Block_complete)block{
    if (block) {
        SEL selector = @selector(backgroundSelector:);
        if (!self.blocks) {
            self.blocks = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%p",block];
        [self.blocks setObject:block forKey:key];
        [self performSelectorInBackground:selector withObject:@[key,arg]];
    }
}
@end
