//
//  UIContainerTextView.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/22.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTextView.h"


@interface UIContainerTextView()<UITextViewDelegate>

nonatomic_strong(UITextView, *textView);

@end

@implementation UIContainerTextView

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UITextView)
    self.textView.delegate = self;
}

- (void)setView:(id )view{
    [super setView:view];
    _textView = view;
}

- (UIScrollView*)scrollView{
    return _textView;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"text"]) {
            self.textView.text = obj;
        }else if ([key isEqualToString:@"font"]){
            self.textView.font = [UIFont systemFontOfSize:[obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }]];
        }else if ([key isEqualToString:@"textColor"]){
            self.textView.textColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"textAlignment"]){
            self.textView.textAlignment = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"editable"]){
            self.textView.editable = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"attributedText"]){
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:obj[@"string"] attributes:obj[@"attributes"]];
            self.textView.attributedText = attributedString;
        }
    }];
    return data;
}

@end
