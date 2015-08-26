//
//  UIContainerCollectionView.m
//  HybirdPrj
//
//  Created by xiang ying on 15/6/28.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerCollectionView.h"

@interface UIContainerCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate>

nonatomic_strong(UICollectionView,    *collectionView)
nonatomic_strong(UIContainerView,     *collectionHeadView)

@end

@implementation UIContainerCollectionView

- (void)createView:(NSDictionary*)dict
{
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    if (dict[@"frame"]) {
        id obj = dict[@"frame"];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            //layout frame
            //x
            CGFloat x = 0;
            if (obj[@"x"]) {
                NSString* xString = [self calculate:obj[@"x"]];
                x = [[self calculate:xString] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"x", xString);
                    }
                }];
            }            //y
            CGFloat y = 0;
            if (obj[@"y"]) {
                NSString* yString = [self calculate:obj[@"y"]];
                y = [[self calculate: yString ] obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"y", yString);
                    }
                }];
            }
            
            //width
            CGFloat width = 0;
            if (obj[@"width"]) {
                NSString *widthString = [self calculate:obj[@"width"]];
                width = [widthString obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"width", widthString);
                    }
                }];
            }
            
            //height
            CGFloat height = 0;
            if (obj[@"height"]) {
                NSString* heightString = [self calculate:obj[@"height"]];
                height = [heightString obj_float:^(BOOL success) {
                    if (!success) {
                        showFloatException(@"height", heightString);
                    }
                }];
            }
            self.view = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, width, height) collectionViewLayout:flowLayout];
        }else {
            self.view = [[UICollectionView alloc] initWithFrame:CGRectFromString(obj) collectionViewLayout:flowLayout];
        }
        [self.jsonData removeObjectForKey:@"frame"];
    }else{
        self.view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) collectionViewLayout:flowLayout];
    }
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.cells = [dict objectForKey:@"cells"];
    self.dataSource = [dict objectForKey:@"dataSource"];
    NSString *identy = self.cells[0][@"identify"];
    
    if (dict[@"collectionHeadView"]) {
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeadView"];
    }

    if (dict[@"heads"]) {
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:dict[@"heads"][0][@"identify"]];
    }
    if (dict[@"foots"]) {
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:dict[@"heads"][0][@"identify"]];
    }
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identy];
}

- (void)setView:(id )view{
    [super setView:view];
    _collectionView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];
        
        if ([key isEqualToString:@"allowsSelection"]) {
            self.collectionView.allowsSelection = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"allowsMultipleSelection"]) {
            self.collectionView.allowsMultipleSelection = [obj obj_bool:^(BOOL success) {
                if (!success) {
                    showBoolException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"collectionHeadView"]){
            if (!self.collectionHeadView) {
                self.collectionHeadView = [UIContainerHelper createViewContainerWithDic:obj];
                self.collectionHeadView.superContainer = self;
                [self.collectionView reloadData];
            }
        }
    }];
    return data;
}

- (void)reload{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
//@required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.collectionHeadView) {
        if (section == 0) {
            return 0;
        }
        return [self.dataSource[section-1][@"section"] count];
    }
    return [self.dataSource[section][@"section"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identy = self.cells[0][@"identify"];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identy forIndexPath:indexPath];
    if (!cell.container) {
        NSMutableDictionary *dic= [NSMutableDictionary dictionary];
        [dic addEntries:self.cells[0]];
        if (self.collectionHeadView) {
            [dic setObject:[NSString stringWithFormat:@"%@_%ld_%ld",dic[@"identify"],(long)indexPath.section - 1,(long)indexPath.row] forKey:@"identify"];
        }else {
            [dic setObject:[NSString stringWithFormat:@"%@_%ld_%ld",dic[@"identify"],(long)indexPath.section,(long)indexPath.row] forKey:@"identify"];
        }
        UIContainerCollectionCell *containerCell = [UIContainerHelper createViewContainerWithDic:dic];
        containerCell.superContainer = self;
        containerCell.cell = cell;
        [containerCell setUI:containerCell.jsonData];
    }
    
    if (self.collectionHeadView) {
        [cell.container updateView:self.parseCell :self.dataSource[indexPath.section-1][@"section"][indexPath.row]];
    }else{
        [cell.container updateView:self.parseCell :self.dataSource[indexPath.section][@"section"][indexPath.row]];
    }
    return cell;
}

//@optional

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.collectionHeadView) {
        return self.dataSource.count + 1;
    }
    return self.dataSource.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = collectionView.frame.size;
    NSDictionary *itemdata = self.jsonData[@"item"];
    if (itemdata[@"height"]) {
        size.height =  [[self calculate:itemdata[@"height"]] obj_float:nil];
    }
    if (itemdata[@"itemnum"]) {
        
        NSInteger items = [itemdata[@"itemnum"] obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"itemnum", itemdata[@"itemnum"]);
            }
        }];
        UIEdgeInsets edge = UIEdgeInsetsZero;
        if (itemdata[@"EdgeInsets"]) {
            edge = UIEdgeInsetsFromString(itemdata[@"EdgeInsets"]);
        }
        CGFloat width = 0;
        if (itemdata[@"interspacing"]) {
            width = [itemdata[@"interspacing"] obj_float:^(BOOL success) {
                if (!success) {
                    showIntegerException(@"interspacing", itemdata[@"interspacing"]);
                }
            }];
        }
        
        size.width = floorf((collectionView.frame.size.width-edge.left-edge.right)/items-width);
    }else if (itemdata[@"width"]){
        size.width = [[self calculate:itemdata[@"width"]] obj_float:^(BOOL success) {
            if (!success) {
                showIntegerException(@"width", itemdata[@"width"]);
            }
        }];
    }
    return size;
}

//每个item之间的间距(横向）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    NSDictionary *itemdata = self.jsonData[@"item"];
    if (itemdata[@"interspacing"]) {
        return [itemdata[@"interspacing"] obj_float:^(BOOL success) {
            if (!success) {
                showIntegerException(@"interspacing", itemdata[@"interspacing"]);
            }
        }];
    }
    return 0;
}

//每个item之间的间距(竖向）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    NSDictionary *itemdata = self.jsonData[@"item"];
    if (itemdata[@"linespacing"]) {
        return [itemdata[@"linespacing"] obj_float:^(BOOL success) {
            if (!success) {
                showIntegerException(@"linespacing", itemdata[@"linespacing"]);
            }
        }];
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.collectionHeadView) {
        if (section == 0) {
            CGRect rect = [self.collectionHeadView layoutFrame:self.collectionHeadView.jsonData[@"frame"]];
            return rect.size;
        }
    }
    CGSize size = CGSizeZero;//{240,25};
    NSArray *heads = self.jsonData[@"heads"];
    if (heads) {
        size = CGSizeFromString(heads[0][@"size"]);
        size.width = collectionView.frame.size.width;
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;//{240,25};
    NSArray *foots = self.jsonData[@"foots"];
    if (foots) {
        size = CGSizeFromString(foots[0][@"size"]);
        size.width = collectionView.frame.size.width;
    }
    return size;
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSDictionary *itemdata = self.jsonData[@"item"];
    
    if (itemdata[@"EdgeInsets"]) {
        return UIEdgeInsetsFromString(itemdata[@"EdgeInsets"]);
    }
    return UIEdgeInsetsZero;
}

#pragma mark - head & foot view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    
    if([kind isEqual:UICollectionElementKindSectionHeader])
    {
        if (self.collectionHeadView && indexPath.section == 0) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeadView" forIndexPath:indexPath];
            if (!reusableView.container) {
                self.collectionHeadView.view = reusableView;
                //                    self.collectionHeadView.view.frame = frame;
                reusableView.container = self.collectionHeadView;
            }
            [self.collectionHeadView setUI:self.jsonData[@"collectionHeadView"]];
        }else{
            NSArray *heads = self.jsonData[@"heads"];
            if (heads) {
                reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:heads[0][@"identify"] forIndexPath:indexPath];
                if (!reusableView.container) {
                    NSMutableDictionary *dic= [NSMutableDictionary dictionary];
                    [dic addEntries:heads[0]];
                    [dic setObject:[NSString stringWithFormat:@"%@_%ld_%ld",dic[@"identify"],(long)indexPath.section,(long)indexPath.row] forKey:@"identify"];
                    
                    UIContainerReusableView *reusableContainer = [UIContainerHelper createViewContainerWithDic:dic];
                    reusableContainer.superContainer = self;
                    reusableContainer.view = reusableView;
                    reusableView.container = reusableContainer;
                    [reusableContainer setUI:heads[0]];
                }
                if (self.collectionHeadView && indexPath.section!=0) {
                    [reusableView.container updateView:self.parseCell :self.dataSource[indexPath.section - 1]];
                }else{
                    [reusableView.container updateView:self.parseCell :self.dataSource[indexPath.section]];
                }
            }
        }
    }
    else if([kind isEqual:UICollectionElementKindSectionFooter])
    {
        NSArray *foots = self.jsonData[@"foots"];
        if (foots) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:foots[0][@"identify"] forIndexPath:indexPath];
            if (!reusableView.container) {
                NSMutableDictionary *dic= [NSMutableDictionary dictionary];
                [dic addEntries:foots[0]];
                [dic setObject:[NSString stringWithFormat:@"%@_%ld_%ld",dic[@"identify"],(long)indexPath.section,(long)indexPath.row] forKey:@"identify"];
                
                UIContainerView *reusableContainer = [UIContainerHelper createViewContainerWithDic:dic];
                reusableContainer.superContainer = self;
                reusableContainer.view = reusableView;
                reusableView.container = reusableContainer;
                [reusableContainer setUI:foots[0]];
            }
            [reusableView.container updateView:self.parseCell :self.dataSource[indexPath.section]];
        }
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIContainerView *containerCell = cell.container;
    NSMutableDictionary *function = [[containerCell.functionList objectForKey:@"didSelectCell"] obj_copy];
    if (function) {
        NSDictionary *data = nil;
        if (self.collectionHeadView) {
            data = self.dataSource[indexPath.section - 1][@"section"][indexPath.row];
        }else{
            data = self.dataSource[indexPath.section][@"section"][indexPath.row];
        }
        
        if (data[@"changeFunction"]) {
            [function addEntries:data[@"changeFunction"]];
        }
        runFunction(function, containerCell);
    }
}

#pragma mark -

- (void)layoutSubViews:(NSMutableDictionary *)uiDic{
    [super layoutSubViews:uiDic];
    [self.collectionView reloadData];
}

@end
