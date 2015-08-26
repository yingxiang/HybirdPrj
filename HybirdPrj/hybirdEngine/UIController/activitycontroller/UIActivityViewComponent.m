//
//  UIActivityViewComponent.m
//  HybirdPrj
//
//  Created by xiangying on 15/7/30.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIActivityViewComponent.h"


@implementation UIActivityViewController(UIActivityViewComponent)

- (instancetype)initWithJson:(NSDictionary *)json{
    
    NSArray *array = @[];
    if (json[@"items"]) {
        array = json[@"items"];
    }
    NSMutableArray *items = [NSMutableArray arrayWithArray:json[@"items"]];
    for (int i = 0 ; i < items.count;i++) {
        id item = items[i];
        id replaceItem = [self assignment:[item obj_copy] :json];
        [items replaceObjectAtIndex:i withObject:replaceItem];
    }
    if (items.count == 0) {
        [items addObjectsFromArray:@[@"没有设置标题以及更多"]];
    }
    
    self = [self initWithActivityItems:items applicationActivities:nil];
    self.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypeAirDrop];
    if (self) {
        [self createController:json];
    }
    return self;
}

- (void)createController:(NSDictionary *)json{
    [super createController:json];
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
    };
    self.completionWithItemsHandler = myBlock;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
