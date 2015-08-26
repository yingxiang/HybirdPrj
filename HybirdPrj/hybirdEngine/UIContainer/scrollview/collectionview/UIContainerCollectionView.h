//
//  UIContainerCollectionView.h
//  HybirdPrj
//
//  Created by xiang ying on 15/6/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerScrollView.h"

@interface UIContainerCollectionView : UIContainerScrollView

nonatomic_strong(NSMutableArray, *dataSource);
nonatomic_strong(NSMutableArray, *cells);

@end
