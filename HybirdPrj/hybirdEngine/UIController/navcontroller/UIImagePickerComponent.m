//
//  UIImagePickerComponent.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/13.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIImagePickerComponent.h"

@interface UIImagePickerController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

nonatomic_strong(UIContainerView, *cameraOverlayContainer);

@end

@implementation UIImagePickerController(UIImagePickerComponent)

- (instancetype)initWithJson:(NSDictionary *)json{
    self = [self init];
    if (self) {
        [self createController:json];
    }
    return self;
}

- (void)createController:(NSDictionary *)json{
    [super createController:json];
    self.delegate = self;
}

- (NSDictionary*)setUI:(NSDictionary*)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        @try {
            if ([key isEqualToString:@"sourceType"]) {
                UIImagePickerControllerSourceType sourceType = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
                if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
                    self.sourceType = sourceType;
                }else{
                    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                        showException(@"UIImagePickerControllerSourceTypePhotoLibrary sourceTypeunAvailable");
                    }else if (sourceType == UIImagePickerControllerSourceTypeCamera){
                        showException(@"UIImagePickerControllerSourceTypeCamera sourceTypeunAvailable");
                    }else if (sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
                        showException(@"UIImagePickerControllerSourceTypeSavedPhotosAlbum sourceTypeunAvailable");
                    }
                }
            }else if ([key isEqualToString:@"allowsEditing"]){
                self.allowsEditing = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"videoMaximumDuration"]){
                self.videoMaximumDuration = [obj obj_double:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"videoQuality"]){
                self.videoQuality = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"showsCameraControls"]){
                self.showsCameraControls = [obj obj_bool:^(BOOL success) {
                    if (!success) {
                        showBoolException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"cameraOverlayView"]){
                if(!self.cameraOverlayContainer){
                    self.cameraOverlayContainer = [UIContainerHelper createViewContainerWithDic:obj];
                    self.cameraOverlayView = self.cameraOverlayContainer.view;
                }
                [self.cameraOverlayContainer setUI:obj];
            }else if ([key isEqualToString:@"cameraCaptureMode"]){
                self.cameraCaptureMode = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"cameraDevice"]){
                self.cameraDevice = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
            }else if ([key isEqualToString:@"cameraFlashMode"]){
                self.cameraFlashMode = [obj obj_integer:^(BOOL success) {
                    if (!success) {
                        showIntegerException(key, obj);
                    }
                }];
            }
        }
        @catch (NSException *exception) {
            _hybird_tips_(exception.description)
        }
        @finally {
            
        }
    }];
    return data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSMutableDictionary *function = [[self.delegateConatiner.functionList objectForKey:@"imagePickerController:didFinishPickingMediaWithInfo:"] obj_copy];
    if (function) {
        __weak typeof(picker) weakPicker = picker;
        [function setObject:weakPicker forKey:@"parmer1"];
        [function setObject:image forKey:@"parmer2"];
        runFunction(function, self.delegateConatiner);
    }else{
        runFunction(@{@"type":@"FT_VIEWROOTBACK"}, nil);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSMutableDictionary *function = [[self.delegateConatiner.functionList objectForKey:@"imagePickerControllerDidCancel:"] obj_copy];
    if (function) {
        __weak typeof(picker) weakPicker = picker;
        [function setObject:weakPicker forKey:@"parmer1"];
        runFunction(function, self.delegateConatiner);
    }else{
        runFunction(@{@"type":@"FT_VIEWROOTBACK"}, nil);
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (navigationController.viewControllers.count > 1) {
        //设置非根视图的导航样式
        [viewController setUI:self.jsonData[@"viewcontroller"]];
    }else{
        //设置根视图的导航样式
        [viewController setUI:self.jsonData[@"rootcontroller"]];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
 
}
@end
