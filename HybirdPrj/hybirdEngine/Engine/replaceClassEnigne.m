//
//  replaceClassEnigne.m
//  HybirdPrj
//
//  Created by xiangying on 15/8/17.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

void replaceClassMethods(Class className,SEL newSEL,SEL origSEL){
    Method orig = class_getInstanceMethod(className, origSEL);
    Method new = class_getInstanceMethod(className, newSEL);
    if(class_addMethod(className, origSEL, method_getImplementation(new), method_getTypeEncoding(new)))
    {
        class_replaceMethod(className, newSEL, method_getImplementation(orig), method_getTypeEncoding(orig));
    }
    else
    {
        method_exchangeImplementations(orig, new);
    }
}

void replaceClass(){
    //UIWindow
    replaceClassMethods([UIWindow class], NSSelectorFromString(@"setVSRootViewController:"), NSSelectorFromString(@"setRootViewController:"));
    
    //UIViewController
    replaceClassMethods([UIViewController class],NSSelectorFromString(@"presentHBViewController:animated:completion:"), NSSelectorFromString(@"presentViewController:animated:completion:"));
    
    replaceClassMethods([UIViewController class], NSSelectorFromString(@"dismissHBViewControllerAnimated:completion:"), NSSelectorFromString(@"dismissViewControllerAnimated:completion:"));
    
    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidLoad"), NSSelectorFromString(@"viewDidLoad"));

    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontviewWillAppear:"), NSSelectorFromString(@"viewWillAppear:"));

    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidAppear:"), NSSelectorFromString(@"viewDidAppear:"));
    
    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontviewWillDisappear:"), NSSelectorFromString(@"viewWillDisappear:"));

    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontviewDidDisappear:"), NSSelectorFromString(@"viewDidDisappear:"));
    
    replaceClassMethods([UIViewController class], NSSelectorFromString(@"commpontpreferredStatusBarStyle:"), NSSelectorFromString(@"preferredStatusBarStyle:"));
    
}













