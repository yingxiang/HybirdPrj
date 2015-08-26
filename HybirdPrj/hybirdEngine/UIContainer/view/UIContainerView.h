//
//  UIContainerView.h
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <Masonry/Masonry.h>
#import "UIView+container.h"
#import "UIBarItem+container.h"

@interface UIContainerView : NSObject

nonatomic_strong(UIView,              *view)

nonatomic_strong(NSMutableDictionary, *jsonData)

nonatomic_strong(NSMutableDictionary, *subViews)

nonatomic_strong(NSMutableDictionary, *functionList)

nonatomic_strong(NSModel,             *modelList)

//数据解析规则
nonatomic_strong(NSMutableDictionary, *functionParse)
nonatomic_strong(NSMutableDictionary, *parseCell)

nonatomic_weak(UIContainerView,       *superContainer)

- (id)initWithDict:(NSDictionary*)dict;

//创建视图
- (void)createView:(NSDictionary*)dict;

//获取frame设置
- (CGRect)layoutFrame:(id)obj;

//设置视图
- (NSDictionary*)setUI:(NSDictionary*)data;

//重新布局视图
- (void)layoutSubViews:(NSMutableDictionary*)uiDic;

//映射数据
- (void)updateView:(NSDictionary*)key :(NSDictionary*)data;

//添加子视图
- (void)addSubContainer:(UIContainerView *)view  data:(NSDictionary*)dic;

//移除视图
- (void)removeFromSuperContainer;

//计算
- (id)calculate:(NSString*)map;

//路径取值
- (id)getValue:(NSString*)map;

//路径取container
- (UIContainerView *)getContainer:(NSString*)map;

//设置字符串
- (NSString*)stringFormat:(NSString*)map;

#pragma mark - 用户事件

- (void)reload;

//用户自定义事件
- (void)actionForKey:(NSString*)key sender:(id)sender;

//基本事件--点击
- (void)eventTouchUpInside;

//基本事件--valuechange
- (void)eventValueChanged;

//基本事件--按下
- (void)eventTouchDown;

#pragma mark - view apper

- (void)viewWillAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidAppear:(BOOL)animated;

- (void)viewDidDisappear:(BOOL)animated;

@end
