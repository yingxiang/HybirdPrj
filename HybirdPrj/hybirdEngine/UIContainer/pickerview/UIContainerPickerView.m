//
//  UIContainerPickerView.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/13.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerPickerView.h"

@interface UIContainerPickerView()<UIPickerViewDataSource,UIPickerViewDelegate>

nonatomic_strong(UIPickerView,    *pickerView);
nonatomic_strong(NSArray,         *dataSource);

@end

@implementation UIContainerPickerView

- (void)createView:(NSDictionary*)dict{
    self.view = _obj_alloc(UIPickerView)
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)setView:(id )view{
    [super setView:view];
    _pickerView = view;
}


- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    return data;
}

- (void)reload{
    [self.pickerView reloadAllComponents];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.dataSource.count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.dataSource[component] count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 0;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0){
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}
@end
