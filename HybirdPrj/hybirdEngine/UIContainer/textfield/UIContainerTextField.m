//
//  UIContainerTextField.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/26.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTextField.h"

@interface UIContainerTextField()<UITextFieldDelegate>

nonatomic_strong(UITextField, *textField);

@end

@implementation UIContainerTextField

- (void)createView:(NSDictionary*)dict
{
    self.view = _obj_alloc(UITextField)
    self.textField.delegate = self;
}

- (void)setView:(id )view{
    [super setView:view];
    _textField = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"text"]) {
            self.textField.text = obj;
        }else if ([key isEqualToString:@"textColor"]) {
            self.textField.textColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"textAlignment"]) {
            self.textField.textAlignment = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"font"]) {
            self.textField.font = [UIFont systemFontOfSize:[obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }]];
        }else if ([key isEqualToString:@"borderStyle"]) {
            self.textField.borderStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"placeholder"]) {
            self.textField.placeholder = obj;
        }else if ([key isEqualToString:@"attributedText"]) {
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:obj[@"string"] attributes:obj[@"attributes"]];
            self.textField.attributedText = attributedString;
        }else if ([key isEqualToString:@"clearsOnBeginEditing"]) {
            self.textField.clearsOnBeginEditing = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"adjustsFontSizeToFitWidth"]) {
            self.textField.adjustsFontSizeToFitWidth = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"minimumFontSize"]) {
            self.textField.minimumFontSize = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"background"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.textField.background = image;
            }];
        }else if ([key isEqualToString:@"disabledBackground"]) {
            [UIImage imageByPath:obj image:^(UIImage *image) {
                self.textField.disabledBackground = image;
            }];
        }else if ([key isEqualToString:@"allowsEditingTextAttributes"]) {
            self.textField.allowsEditingTextAttributes = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"typingAttributes"]) {
            self.textField.typingAttributes = obj;
        }else if ([key isEqualToString:@"clearButtonMode"]) {
            self.textField.clearButtonMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"leftView"]) {
            UIContainerView *containView = [UIContainerHelper createViewContainerWithDic:obj];
            self.textField.leftView = containView.view;
        }else if ([key isEqualToString:@"rightView"]) {
            UIContainerView *containView = [UIContainerHelper createViewContainerWithDic:obj];
            self.textField.rightView = containView.view;
        }else if ([key isEqualToString:@"leftViewMode"]) {
            self.textField.leftViewMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"rightViewMode"]) {
            self.textField.rightViewMode = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }
    }];
    return data;
}


#pragma UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    return YES;
}

@end
