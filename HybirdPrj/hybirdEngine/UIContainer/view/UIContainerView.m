//
//  UIContainerView.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerView.h"
#import "FXBlurView.h"
#import "NSString+TPCategory.h"

//基本事件
//点击
static NSString *const UITapGesture                     = @"UITapGesture";
//长按
static NSString *const UILongPressGesture               = @"UILongPressGesture";
//捏合
static NSString *const UIPinchGesture                   = @"UIPinchGesture";
//旋转
static NSString *const UIRotationGesture                = @"UIRotationGesture";
//滑动
static NSString *const UISwipeGesture                   = @"UISwipeGesture";
//拖移
static NSString *const UIPanGesture                     = @"UIPanGesture";

//按下松开
static NSString *const ControlEventTouchUpInside        = @"UIControlEventTouchUpInside";
//按下
static NSString *const ControlEventTouchDown            = @"UIControlEventTouchDown";
//数值变化
static NSString *const ControlEventValueChanged         = @"UIControlEventValueChanged";

@interface UIContainerView()

nonatomic_assign(BOOL, isFirstLoad)
nonatomic_weak  (id  , actionTarget)

@end

@implementation UIContainerView
@synthesize view = _view;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSDictionary *function = [self.functionList[@"dealloc"] obj_copy];
    if (function) {
        runFunction(function, self);
    }
}

- (id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.identify = dict[@"identify"];
        self.subViews = [NSMutableDictionary dictionary];
        self.jsonData = [NSMutableDictionary dictionaryWithDictionary:dict];
        self.functionParse = [NSMutableDictionary dictionary];
        self.modelList = [[NSModel alloc] init];
        if (dict[@"functionList"]) {
            self.functionList = [NSMutableDictionary dictionary];
            for (id function in dict[@"functionList"]) {
                if ([function isKindOfClass:[NSDictionary class]]) {
                    [self.functionList setObject:function forKey:function[@"functionname"]];
                }else if([function isKindOfClass:[NSArray class]]){
                    for (NSDictionary *gesture in function) {
                        [self.functionList setObject:gesture forKey:gesture[@"functionname"]];
                    }
                }
            }
        }
        self.isFirstLoad = YES;
        [self createView:dict];
        if (dict[@"parseCell"]) {
            //可以预先设置，也可以在回调里设置
            self.parseCell = [NSMutableDictionary dictionaryWithDictionary:dict[@"parseCell"]];
        }
    }
    return self;
}

- (void)createView:(NSDictionary*)dict
{
    if (dict[@"blurRadius"]) {
        //高斯模糊视图
        FXBlurView *blurView = _obj_alloc(FXBlurView)
        self.view = blurView;
    }else{
        self.view = _obj_alloc(UIView)
    }
}

- (void)setView:(id)view{
    _view = view;
    _view.container = self;
    [self addUserActions];
}

//添加用户事件
- (void)addUserActions{
    
    for (NSDictionary *gestureAction in self.functionList.allValues) {
        if (!gestureAction[@"gesturetype"]) {
            continue;
        }
        if ([gestureAction[@"gesturetype"] isEqualToString:UILongPressGesture]) {
            //长按
            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            gesture.identify = gestureAction[@"functionname"];
            self.view.userInteractionEnabled = YES;
            [self.view addGestureRecognizer:gesture];
            [gestureAction enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqualToString:@"minimumPressDuration"]) {
                    gesture.minimumPressDuration = [obj obj_float:^(BOOL success) {
                        if (!success) {
                            showFloatException(key, obj)
                        }
                    }];
                }
            }];
        }else if ([gestureAction[@"gesturetype"] isEqualToString:UIPinchGesture]) {
            //捏合
            UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            gesture.identify = gestureAction[@"functionname"];
            self.view.userInteractionEnabled = YES;
            [self.view addGestureRecognizer:gesture];
        }else if ([gestureAction[@"gesturetype"] isEqualToString:UITapGesture]) {
            //点击
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            gesture.identify = gestureAction[@"functionname"];
            self.view.userInteractionEnabled = YES;
            [self.view addGestureRecognizer:gesture];
        }else if ([gestureAction[@"gesturetype"] isEqualToString:UISwipeGesture]) {
            //快速滑动
            
            NSInteger direction = [[self calculate:gestureAction[@"direction"]] obj_integer:nil];
            
            UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            gesture.direction = direction;
            gesture.identify = gestureAction[@"functionname"];
            self.view.userInteractionEnabled = YES;
            [self.view addGestureRecognizer:gesture];
            
        }else if ([gestureAction[@"gesturetype"] isEqualToString:UIPanGesture]) {
            //拖移
            UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            self.view.userInteractionEnabled = YES;
            gesture.identify = gestureAction[@"functionname"];
            [self.view addGestureRecognizer:gesture];
        }else if ([gestureAction[@"gesturetype"] isEqualToString:UIRotationGesture]) {
            //旋转
            UIRotationGestureRecognizer *gesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(userAction:)];
            gesture.identify = gestureAction[@"functionname"];
            self.view.userInteractionEnabled = YES;
            [self.view addGestureRecognizer:gesture];
        }

    }
}

//for frame
- (CGRect)layoutFrame:(id)obj{
    
    CGRect sourceRect = CGRectZero;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        //layout frame
        //x
        CGFloat x = 0;
        if (obj[@"x"]) {
            NSString *xString = [self calculate:obj[@"x"]];
            x = [xString obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"x.value", obj[@"x"]);
                }
            }];
        }
        //y
        CGFloat y = 0;
        if (obj[@"y"]) {
            y = [[self calculate:obj[@"y"]] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"y.value", obj[@"y"]);
                }
            }];
        }
        
        //width
        CGFloat width = 0;
        if (obj[@"width"]) {
            width = [[self calculate:obj[@"width"]] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"width.value", obj[@"width"]);
                }
            }];
        }
        //height
        CGFloat height = 0;
        if (obj[@"height"]) {
            height = [[self calculate:obj[@"height"]] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"height.value", obj[@"height"]);
                }
            }];
        }
        
        sourceRect = CGRectMake(x, y, width, height);
    }
    else if([obj isKindOfClass:[NSString class]]){
        @try {
            sourceRect = CGRectFromString(obj);
        }
        @catch (NSException *exception) {
            NSString *msg = exception.description;
            showException(msg);
        }
        @finally {
            
        }
    }
    return  sourceRect;
}

//for layout
- (void)layoutUI:(NSDictionary*)obj :(MASConstraintMaker*)make{
    //相对父视图的布局
    if (obj[@"left"]) {
        id value = [self getValue:obj[@"left"][@"value"]];
        if (value) {
            CGFloat offset = 0;
            if (obj[@"left"][@"offset"]) {
                offset = [[self calculate:obj[@"left"][@"offset"]] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"left.offset", obj[@"left"][@"offset"]);
                    }
                }];
            }
            if ([value isKindOfClass:[MASViewAttribute class]]) {
                make.left.equalTo((MASViewAttribute*)value).mas_offset(offset);
            }else {
                make.left.equalTo(@([value obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"left.offset", obj[@"left"][@"offset"]);
                    }
                }]));
            }
        }
    }
    if (obj[@"right"]) {
        id value = [self getValue:obj[@"right"][@"value"]];
        CGFloat offset = 0;
        if (obj[@"right"][@"offset"]) {
            offset = [[self calculate:obj[@"right"][@"offset"]] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"right.offset", obj[@"right"][@"offset"]);
                }
            }];
        }
        if ([value isKindOfClass:[MASViewAttribute class]]) {
            make.right.equalTo((MASViewAttribute*)value).mas_offset(offset);
        }else {
            make.right.equalTo(@([value obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"right.offset", obj[@"right"][@"offset"]);
                }
            }]));
        }
    }
    if (obj[@"top"]) {
        NSArray *divide = [obj[@"top"][@"value"] componentsSeparatedByString:@"/"];
        id value = [self getValue:divide[0]];
        CGFloat offset = 0;
        if (obj[@"top"][@"offset"]) {
            offset = [[self calculate: obj[@"top"][@"offset"]] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"top.offset", obj[@"top"][@"offset"]);
                }
            }];
        }
        if ([value isKindOfClass:[MASViewAttribute class]]) {
            make.top.equalTo((MASViewAttribute*)value).mas_offset(offset);
        }else {
            if (divide.count == 2) {
                CGFloat dividetwo = [divide[1] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"top.divideBy", obj[@"top"][@"value"]);
                    }
                }];
                if (dividetwo!=0) {
                    make.top.equalTo(@([value obj_float:^(BOOL success) {
                        if (!success) {
                            showFloatException(@"top./divideBy", obj[@"top"][@"value"]);
                        }
                    }]/dividetwo));
                }else{
                    make.top.equalTo(@([value obj_float:^(BOOL success) {
                        if (!success) {
                            showFloatException(@"top./divideBy", obj[@"top"][@"value"]);
                        }
                    }]));
                }
            }else{
                make.top.equalTo(@([value obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"top.value", obj[@"top"][@"value"]);
                    }
                }]));
            }
        }
    }
    if (obj[@"bottom"]) {
        id value = [self getValue:obj[@"bottom"][@"value"]];
        CGFloat offset = 0;
        if (obj[@"bottom"][@"offset"]) {
            offset = [obj[@"bottom"][@"offset"] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"bottom.offset", obj[@"bottom"][@"offset"]);
                }
            }];
        }
        if ([value isKindOfClass:[MASViewAttribute class]]) {
            make.bottom.equalTo((MASViewAttribute*)value).mas_offset(offset);
        }else {
            make.bottom.equalTo(@([value obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"bottom.value", obj[@"bottom"][@"value"]);
                }
            }]));
        }
    }
    if (obj[@"width"]) {
        id value = [self getValue:obj[@"width"][@"value"]];
        CGFloat offset = 0;
        if (value) {
            if (obj[@"width"][@"offset"]) {
                offset = [obj[@"width"][@"offset"] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"width.offset", obj[@"width"][@"offset"]);
                    }
                }];
            }
            if ([value isKindOfClass:[MASViewAttribute class]]) {
                make.width.equalTo((MASViewAttribute*)value).mas_offset(offset);
            }else {
                make.width.equalTo(@([value obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"width.value", obj[@"width"][@"value"]);
                    }
                }]));
            }
        }else{
            NSArray *divide = [obj[@"width"][@"dividedBy"] componentsSeparatedByString:@"/"];
            
            if (obj[@"width"][@"offset"]) {
                offset = [obj[@"width"][@"offset"] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"width.offset", obj[@"width"][@"offset"]);
                    }
                }];
            }
            MASViewAttribute *attribute = [self calculate:divide[0]];
            
            if (divide.count == 2) {
                make.width.equalTo(attribute).dividedBy([divide[1] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"width./dividedBy", obj[@"width"][@"dividedBy"]);
                    }
                }]).mas_offset(offset);
            }else{
                make.width.equalTo(attribute).mas_offset(offset);
            }
        }
    }
    if (obj[@"height"]) {
        id value = [self calculate:obj[@"height"][@"value"]];
        CGFloat offset = 0;
        if (value) {
            if (obj[@"height"][@"offset"]) {
                offset = [obj[@"height"][@"offset"] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"height.offset", obj[@"height"][@"offset"]);
                    }
                }];
            }
            if ([value isKindOfClass:[MASViewAttribute class]]) {
                make.height.equalTo((MASViewAttribute*)value).mas_offset(offset);
            }else {
                make.height.equalTo(@([value obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"height.offset", obj[@"height"][@"offset"]);
                    }
                }]));
            }
        }else{
            NSArray *divide = [obj[@"height"][@"dividedBy"] componentsSeparatedByString:@"/"];
            
            if (obj[@"height"][@"offset"]) {
                offset = [obj[@"height"][@"offset"] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"height.offset", obj[@"height"][@"offset"]);
                    }
                }];
            }
            MASViewAttribute *attribute = [self calculate:divide[0]];
            
            if (divide.count == 2) {
                make.height.equalTo(attribute).dividedBy([divide[1] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"height.dividedBy", obj[@"height"][@"dividedBy"]);
                    }
                }]).mas_offset(offset);
            }else{
                make.height.equalTo(attribute).mas_offset(offset);
            }
        }
    }
    if (obj[@"centerX"]) {
        id value = [self calculate:obj[@"centerX"][@"value"]];
        CGFloat offset = 0;
        if (obj[@"centerX"][@"offset"]) {
            offset = [obj[@"centerX"][@"offset"] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"centerX.offset", obj[@"centerX"][@"offset"]);
                }
            }];
        }
        if ([value isKindOfClass:[MASViewAttribute class]]) {
            make.centerX.equalTo((MASViewAttribute*)value).mas_offset(offset);
        }else {
            make.centerX.equalTo(@([value obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"centerX.value", obj[@"centerX"][@"value"]);
                }
            }]));
        }
    }
    if (obj[@"centerY"]) {
        id value = [self calculate:obj[@"centerY"][@"value"]];
        CGFloat offset = 0;
        if (obj[@"centerY"][@"offset"]) {
            offset = [obj[@"centerY"][@"offset"] obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"centerY.offset", obj[@"centerY"][@"offset"]);
                }
            }];
        }
        if ([value isKindOfClass:[MASViewAttribute class]]) {
            make.centerY.equalTo((MASViewAttribute*)value).mas_offset(offset);
        }else {
            make.centerY.equalTo(@([value obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(@"centerY.value", obj[@"centerY"][@"value"]);
                }
            }]));
        }
    }
}

//布局视图
- (NSDictionary*)setUI:(NSDictionary*)data{
    NSMutableDictionary *copydata = [data obj_copy];
    if ([data[@"identify"] hasPrefix:@"~/"]) {
        NSString *className = [data[@"identify"] substringFromIndex:2];
        NSDictionary *vDic = file_read(_HYBIRD_PATH_VIEW, className);
        [copydata addEntries:vDic];
    }
    data = copydata;
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        obj = [self assignment:obj :data];
        if ([key isEqualToString:@"subViews"]) {
            for (NSDictionary* dict in obj) {
                UIContainerView *container = self.subViews[dict[@"identify"]];
                if (!container) {
                    container = newContainer(dict);;
                }
                [self addSubContainer:container data:dict];
            }
        }else if ([key isEqualToString:@"backgroundColor"]) {
            self.view.backgroundColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"userInteractionEnabled"]){
            self.view.userInteractionEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"hidden"]){
            self.view.hidden = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"tintColor"]){
            self.view.tintColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"alpha"]){
            self.view.alpha = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"exclusiveTouch"]){
            self.view.exclusiveTouch = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"clipsToBounds"]){
            self.view.clipsToBounds = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"multipleTouchEnabled"]){
            self.view.multipleTouchEnabled = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if([key isEqualToString:@"frame"]){
            @try {
                self.view.frame = [self layoutFrame:obj];
            }
            @catch (NSException *exception) {
                NSString *msg = [exception.description stringByAppendingFormat:@"\n%@",obj];
                showException(msg);
            }
            @finally {
                
            }
        }else if([key isEqualToString:@"layout"]){
            @try {
                if (!self.view.mas_attribute) {
                    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
                        [self layoutUI:obj :make];
                    }];
                }else{
                    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        [self layoutUI:obj :make];
                    }];
                }
            }
            @catch (NSException *exception) {
                NSString *msg = [exception.description stringByAppendingFormat:@"\n%@",obj];
                showException(msg);
            }
            @finally {
                
            }
            
        }else if ([key isEqualToString:@"center"]){
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CGPoint center = CGPointZero;
                center.x = [[self calculate:obj[@"x"]] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }];
                center.y = [[self calculate:obj[@"y"]] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(key, obj);
                    }
                }];
                self.view.center = center;
            }else if ([obj isKindOfClass:[NSString class]]){
                self.view.center = CGPointFromString([self calculate:obj]);
            }
        }else if ([key isEqualToString:@"blurRadius"]){
            //for FXBlurView
            [(FXBlurView*)self.view setBlurRadius:[obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }]];
        }else if ([key isEqualToString:@"tintColor"]){
            //for FXBlurView
            [(FXBlurView*)self.view setTintColor:[UIColor colorWithHexString:obj]];
        }else if ([key isEqualToString:@"contentMode"]){
            self.view.contentMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"cornerRadius"]){
            self.view.layer.cornerRadius = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
            self.view.layer.masksToBounds = YES;
        }else if ([key isEqualToString:@"borderWidth"]){
            self.view.layer.borderWidth = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"borderColor"]){
            self.view.layer.borderColor = [UIColor colorWithHexString:obj].CGColor;
        }else if ([key isEqualToString:@"tag"]){
            self.view.tag = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj)
                }
            }];
        }
    }];
    
    if (self.isFirstLoad) {
        //避免第二次setUi导致死循环，因此只有在指定了function时才执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //延迟为了使得子类的视图初始化完成
            NSMutableDictionary *function = [[self.functionList objectForKey:@"setUI:"] obj_copy];
            if (function) {
                runFunction(function, self);
            }
            self.isFirstLoad = NO;
        });
    }
    return copydata;
}

- (void)layoutSubViews:(NSMutableDictionary*)uiDic{
    //只布局frame，其他属性不需要设置
    if (self.jsonData[@"frame"]) {
        [uiDic setObject:self.jsonData[@"frame"] forKey:@"frame"];
    }
    if (self.jsonData[@"layout"]) {
        [uiDic setObject:self.jsonData[@"layout"] forKey:@"layout"];
    }
    [self setUI:uiDic];
    for (UIContainerView *view in self.subViews.allValues) {
        [view layoutSubViews:[NSMutableDictionary dictionary]];
    }
}

#pragma mark - 视图操作

- (void)updateView:(NSDictionary*)key :(NSDictionary*)data{
    if (!self.identify) {
        return;
    }
    [key enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *keyArray = [key componentsSeparatedByString:@"."];
        if ([keyArray[0] hasSuffix:[self.identify componentsSeparatedByString:@"_"][0]]) {
            //只解析属于自己的数据
            UIContainerView *containView = self;
            for (int i = 1; i<keyArray.count; i++) {
                NSString *property = keyArray[i];
                if([property hasPrefix:@"container_"]){
                    NSString *key = [property substringFromIndex:10];
                    containView = [containView.subViews objectForKey:key];
                }else{
                    //在此解析obj
                    id value = data;
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        NSArray *objArray = [obj componentsSeparatedByString:@"."];
                        for (int j = 0; j<objArray.count; j++) {
                            NSString *string = [NSString stringWithFormat:@"%@",objArray[j]];
                            NSArray *strings = [string  componentsSeparatedByString:@"'"];
                            NSArray *valueKey = [strings[0] componentsSeparatedByString:@"-"];
                            value = value[valueKey[0]];
                            if (valueKey.count == 2) {
                                value = value[0];
                                value = value[valueKey[1]];
                            }
                            if (strings.count>1) {
                                string = [string substringFromIndex:([strings[0] length]+1)];
                                value = [value stringByAppendingString:[containView stringFormat:string]];
                            }
                        }
                    }
  
                    [containView setUI:@{property:value}];
                }
            }
        }
    }];
}

- (void)setSuperContainer:(UIContainerView *)superContainer{
    _superContainer = superContainer;
    if (self.identify) {
        if (![superContainer.subViews objectForKey:self.identify]) {
            self.view.viewController = superContainer.view.viewController;
            [superContainer.subViews setObject:self forKey:self.identify];
        }
    }else{
        NSString *msg = [NSString stringWithFormat:@"%@\nidentify = nil",self.jsonData];
         showException(msg)
    }
}

- (void)addSubContainer:(UIContainerView *)view data:(NSDictionary*)dic{
    if (view.view && view.superContainer!=self) {
        view.superContainer = self;
    }
    if (view.view.superview!=self.view) {
        [self.view addSubview:view.view];
    }
    if (view.view.viewController == nil) {
        self.view.viewController = _superContainer.view.viewController;
    }
    [view setUI:dic];

    @try {
        if (view.view.mas_attribute) {
            [view.view layoutIfNeeded];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


- (void)removeFromSuperContainer{
    for (UIContainerView *subView in self.subViews.allValues) {
        [subView removeFromSuperContainer];
    }
    [self.view removeFromSuperview];
    self.view.viewController = nil;
    [self.superContainer.subViews removeObjectForKey:self.identify];
}


#pragma mark - get

static int cal_progress = 0;

- (id)getvalue:(int)i values:(NSArray*)values{
    if (i >= values.count) {
        return nil;
    }
    id value = [self getValue:values[i]];
    cal_progress = i;
    if ([self isoperator:value]) {
        //取值计算
        id objectone = [self getvalue:cal_progress+1 values:values];
        id objecttwo = [self getvalue:cal_progress+1 values:values];
        if ([value isEqualToString:@"+"]) {
            value = [NSNumber numberWithFloat:[objectone floatValue]+[objecttwo floatValue]];
        }else if ([value isEqualToString:@"-"]){
            value = [NSNumber numberWithFloat:[objectone floatValue]-[objecttwo floatValue]];
        }else if ([value isEqualToString:@"*"]){
            value = [NSNumber numberWithFloat:[objectone floatValue]*[objecttwo floatValue]];
        }else if ([value isEqualToString:@"/"]){
            value = [NSNumber numberWithFloat:([objectone floatValue]/[objecttwo floatValue])];
        }else if ([value isEqualToString:@"="]){
            if (objectone!=nil) {
                if ([objectone isKindOfClass:[NSString class]]) {
                    value = [NSNumber numberWithBool:[objectone isEqualToString:objecttwo]];
                }else if([objectone isKindOfClass:[NSNumber class]]){
                    value = [NSNumber numberWithBool:([objectone floatValue]==[objecttwo floatValue])];
                }else {
                    value = [NSNumber numberWithBool:(objectone == objecttwo)];
                }
            }else {
                if ([objecttwo isKindOfClass:[NSString class]]) {
                    value = [NSNumber numberWithBool:[objectone isEqualToString:objecttwo]];
                }else if([objecttwo isKindOfClass:[NSNumber class]]){
                    value = [NSNumber numberWithBool:([objectone floatValue]==[objecttwo floatValue])];
                }else {
                    value = [NSNumber numberWithBool:(objectone == objecttwo)];
                }
            }
        }else if ([value isEqualToString:@"%"]){
            value = [NSNumber numberWithInteger:([objectone integerValue]%[objecttwo integerValue])];
        }else if ([value isEqualToString:@"&"]){
            value = [NSNumber numberWithInteger:([objectone integerValue]&[objecttwo integerValue])];
        }else if ([value isEqualToString:@"|"]){
            value = [NSNumber numberWithInteger:([objectone integerValue]|[objecttwo integerValue])];
        }else if ([value isEqualToString:@"#"]){
            value = [NSNumber numberWithInteger:([objectone floatValue]||[objecttwo floatValue])];
        }else if ([value isEqualToString:@"~"]){
            value = [NSNumber numberWithInteger:([objectone floatValue]&&[objecttwo floatValue])];
        }else if ([value isEqualToString:@">"]){
            value = [NSNumber numberWithBool:([objectone floatValue]>[objecttwo floatValue])];
        }else if ([value isEqualToString:@"<"]){
            value = [NSNumber numberWithBool:([objectone floatValue]<[objecttwo floatValue])];
        }else if ([value isEqualToString:@"《"]){
            value = [NSNumber numberWithInteger:([objectone integerValue]<<[objecttwo integerValue])];
        }else if ([value isEqualToString:@"》"]){
            value = [NSNumber numberWithInteger:([objectone integerValue]>>[objecttwo integerValue])];
        }else if ([value isEqualToString:@"!"]){
            value = [NSNumber numberWithBool:![objectone boolValue]];
        }
    }
    return value;
}

- (BOOL)isoperator:(NSString*)value{
    if (![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@",value];
    }
    if ([value isEqualToString:@"+"]||
        [value isEqualToString:@"-"]||
        [value isEqualToString:@"*"]||
        [value isEqualToString:@"/"]||
        [value isEqualToString:@"#"]||
        [value isEqualToString:@"~"]||
        [value isEqualToString:@"|"]||
        [value isEqualToString:@"&"]||
        [value isEqualToString:@">"]||
        [value isEqualToString:@"<"]||
        [value isEqualToString:@"="]||
        [value isEqualToString:@"》"]||
        [value isEqualToString:@"《"]||
        [value isEqualToString:@"!"]) {
        return YES;
    }
    return NO;
}

- (id)calculate:(NSString*)map{
    //前序遍历算法
    if (![map isKindOfClass:[NSString class]]) {
        return map;
    }

    NSArray *array = [map componentsSeparatedByString:@"("];
    if (array.count == 1) {
        //这个不需要计算，直接返回
        return [self getValue:map];
    }else {
        //-,36),28)*-,3),2)
        NSMutableArray *values = [NSMutableArray array];
        for (NSString *value in array) {
            NSRange range = [value rangeOfString:@")"];
            if (range.length != 0) {
                //数字
                NSString *num = [value substringToIndex:range.location];
                [values addObject:num];
                
                NSString *next = [value substringFromIndex:range.location+1];
                for (int i = 0; i<next.length; i++) {
                    //运算符号
                    NSString *operator = [next substringWithRange:NSMakeRange(i, 1)];
                    if ([self isoperator:operator]) {
                        [values addObject:operator];
                    }else{
                        //不是标准的运算表达式，放弃解析
                        return map;
                    }
                }
            }else{
                for (int i = 0; i<value.length; i++) {
                    //运算符号
                    NSString *operator = [value substringWithRange:NSMakeRange(i, 1)];
                    if ([self isoperator:operator]) {
                        [values addObject:operator];
                    }else{
                        //不是标准的运算表达式，放弃解析
                        return map;
                    }
                }
            }
        }
        return [self getvalue:0 values:values];
    }
    return nil;
}

//向上或平行遍历查找其他视图的属性
- (id)getValue:(NSString*)map{
    if ([map isKindOfClass:[NSString class]]) {
        if ([map isPureFloat]) {
            return map;
        }
        NSArray *array = [map componentsSeparatedByString:@"."];
        if (array.count == 1) {
            return map; //直接返回值
        }else{
            NSString *string = [array[0] substringWithRange:NSMakeRange([array[0] length]-1, 1)];
            if ([string isPureInt]) {
                return map;
            }
            //super-identify.xx
            id value = self;
            for (int i = 0; i<array.count; i++) {
                NSString *property = array[i];
                if ([property isEqualToString:@""]) {
                    return map;
                }else if ([property isEqualToString:@"self"]) {
                    
                }else if ([property isEqualToString:@"windowContainer"]) {
                    value = [UIContainerWindow containerWindow];
                }else if ([property isEqualToString:@"superContainer"]) {
                    value = [value superContainer];
                }else if([property hasPrefix:@"container_"]){
                    NSString *key = [property substringFromIndex:10];
                    value = [[value subViews] objectForKey:key];
                }else{
                    value = [value getProperty:property];
                }
            }

            return value;
        }
    }
    return map;
}

- (UIContainerView*)getContainer:(NSString*)map{
    UIContainerView *containView = self;
    
    if (map != nil) {
        NSArray *array = [map componentsSeparatedByString:@"."];
        for (int i = 0; i<array.count; i++) {
            NSString *property = array[i];
            if ([property isEqualToString:@"windowContainer"]) {
                containView = [UIContainerWindow containerWindow];
                break;
            }else{
                if ([property isEqualToString:@"superContainer"]) {
                    containView = containView.superContainer;
                }else if([property hasPrefix:@"container_"]){
                    NSString *key = [property substringFromIndex:10];
                    containView = [containView.subViews objectForKey:key];
                }
            }
        }
    }
    return containView;
}

//设置字符串
- (NSString*)stringFormat:(NSString*)map{
    NSArray *array = [map componentsSeparatedByString:@"'"];
    NSMutableString *formatString = [NSMutableString string];
    for (NSString *string in array) {
        [formatString appendString:[NSString stringWithFormat:@"%@",[self calculate:string]]];
    }
    return formatString;
}

#pragma mark - 用户事件
- (void)reload{
    
}

- (void)actionForKey:(NSString*)key sender:(id)sender{
    NSMutableDictionary *function = [[self.functionList objectForKey:key] obj_copy];
    if (function) {
        self.actionTarget = sender;
        runFunction(function, self);
    }
}

- (void)userAction:(id)sender{
    if ([sender isKindOfClass:[UIGestureRecognizer class]]){
        NSString *functionName = [(UIGestureRecognizer*)sender identify];
        [self actionForKey:functionName sender:sender];
    }else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *view = (UIBarButtonItem*)sender;
        UIContainerView *container = view.container;
        NSDictionary *function = [[self.functionList objectForKey:container.identify] obj_copy];
        if (function) {
            runFunction(function, self);
        }
    }
}

- (void)eventTouchUpInside{
    [self actionForKey:ControlEventTouchUpInside sender:self];
}

- (void)eventValueChanged{
    [self actionForKey:ControlEventValueChanged sender:self];
}

- (void)eventTouchDown{
    [self actionForKey:ControlEventTouchDown sender:self];
}

#pragma mark - view apper
- (void)viewWillAppear:(BOOL)animated{
    [self layoutSubViews:[NSMutableDictionary dictionary]];
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self layoutSubViews:[NSMutableDictionary dictionary]];
}

- (void)viewDidDisappear:(BOOL)animated{
    
}


@end
