//
//  replaceClassEnigne.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/17.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

//替换对象方法
void replaceInstanceMethods(Class className,SEL newSEL,SEL origSEL){
    Method orig = class_getInstanceMethod(className, origSEL);
    Method new = class_getInstanceMethod(className, newSEL);
    if(class_addMethod(className, origSEL, method_getImplementation(new), method_getTypeEncoding(new)))
    {
        class_replaceMethod(className, newSEL, method_getImplementation(orig), method_getTypeEncoding(orig));
    }else {
        method_exchangeImplementations(orig, new);
    }
}

//替换类方法
void replaceClassMethods(Class className,SEL newSEL,SEL origSEL){
    Method orig = class_getClassMethod(className, origSEL);
    Method new = class_getClassMethod(className, newSEL);
    method_exchangeImplementations(orig, new);
}

void replaceClass(){
    //UIWindow
    replaceInstanceMethods([UIWindow class], NSSelectorFromString(@"setHBRootViewController:"), NSSelectorFromString(@"setRootViewController:"));
    
    //UIViewController
    replaceInstanceMethods([UIViewController class],NSSelectorFromString(@"presentHBViewController:animated:completion:"), NSSelectorFromString(@"presentViewController:animated:completion:"));
    
    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"dismissHBViewControllerAnimated:completion:"), NSSelectorFromString(@"dismissViewControllerAnimated:completion:"));
    
    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidLoad"), NSSelectorFromString(@"viewDidLoad"));

    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontviewWillAppear:"), NSSelectorFromString(@"viewWillAppear:"));

    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidAppear:"), NSSelectorFromString(@"viewDidAppear:"));
    
    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontviewWillDisappear:"), NSSelectorFromString(@"viewWillDisappear:"));

    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidDisappear:"), NSSelectorFromString(@"viewDidDisappear:"));
    
    replaceInstanceMethods([UIViewController class], NSSelectorFromString(@"commpontpreferredStatusBarStyle:"), NSSelectorFromString(@"preferredStatusBarStyle:"));
    
    replaceInstanceMethods([UILabel class], NSSelectorFromString(@"setfitText:"), NSSelectorFromString(@"setText:"));
    
    replaceClassMethods([NSURL class], NSSelectorFromString(@"ENCODEURLWithString:"), NSSelectorFromString(@"URLWithString:"));

}













