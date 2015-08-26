//
//  AlignmentLabel.h
//  HybirdPrj
//
//  Created by xiangying on 15/7/1.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
@interface AlignmentLabel : UILabel

nonatomic_assign(VerticalAlignment, verticalAlignment);

@end
