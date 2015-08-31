//
//  UIContainerTableView.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTableView.h"

@interface UIContainerTableView()<UITableViewDelegate,UITableViewDataSource>

nonatomic_strong(UITableView,             *tableView)
nonatomic_strong(NSArray,                 *dataSource)

@end

@implementation UIContainerTableView

- (void)createView:(NSDictionary*)dict
{
    NSString* styleStr  = [dict objectForKey:@"UITableViewStyle"];
    UITableViewStyle style = UITableViewStylePlain;
    if (styleStr) {
        style = [styleStr obj_integer:^(BOOL success) {
            if (!success) {
                showIntegerException(@"UITableViewStyle", styleStr);
            }
        }];
    }
    self.view = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cells = [dict objectForKey:@"cells"];
    self.dataSource = [dict objectForKey:@"dataSource"];
}

- (void)setView:(id )view{
    [super setView:view];
    _tableView = view;
}

- (NSDictionary*)setUI:(NSDictionary *)data{
    data = [super setUI:data];
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self assignment:obj :data];

        if ([key isEqualToString:@"separatorStyle"]) {
            self.tableView.separatorStyle = [obj obj_integer:^(BOOL success) {
                if (!success) {
                    showIntegerException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"separatorColor"]){
            self.tableView.separatorColor = [UIColor colorWithHexString:obj];
        }else if ([key isEqualToString:@"tableHeaderView"]){
            
            UIContainerView *container = self.tableView.tableHeaderView.container;
            if (!container) {
                container = newContainer(obj);
                container.superContainer = self;
            }else{
                self.tableView.tableHeaderView = nil;
            }
            [container setUI:obj];  //必须是layoutframe
            self.tableView.tableHeaderView = container.view;
        }else if ([key isEqualToString:@"tableFooterView"]){
            UIContainerView *container = self.tableView.tableHeaderView.container;
            if (!container) {
                container = newContainer(obj);
                container.superContainer = self;
            }else{
                self.tableView.tableFooterView = nil;
            }
            [container setUI:obj];
            self.tableView.tableFooterView = container.view;
        }else if ([key isEqualToString:@"dataSource"]){
            self.dataSource = obj;
            [self reload];
        }else if ([key isEqualToString:@"estimatedSectionHeaderHeight"]){
            self.tableView.estimatedSectionHeaderHeight = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"estimatedSectionFooterHeight"]){
            self.tableView.estimatedSectionFooterHeight = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }else if ([key isEqualToString:@"estimatedRowHeight"]){
            self.tableView.estimatedRowHeight = [obj obj_float:^(BOOL success) {
                if (!success) {
                    showFloatException(key, obj);
                }
            }];
        }
    }];
    return data;
}

- (void)reload{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIContainerView *containerCell = cell.container;
    NSMutableDictionary *function = [[containerCell.functionList objectForKey:@"didSelectCell"] obj_copy];
    if (function) {
        NSDictionary *data = self.dataSource[indexPath.section][@"section"][indexPath.row];
        if (data[@"changeFunction"]) {
            [function addEntries:data[@"changeFunction"]];
        }
        [function setObject:indexPath forKey:@"parmer1"];
        runFunction(function,containerCell);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource[section][@"section"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identy = self.cells[0][@"identify"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (!cell) {
        NSDictionary *dic= self.cells[0];
        NSString *cellIdentify = [NSString stringWithFormat:@"%@_%ld_%ld",dic[@"identify"],(long)indexPath.section,(long)indexPath.row];
        UIContainerCell *containerCell = [self.subViews objectForKey:cellIdentify];
        if (!containerCell) {
            containerCell = newContainer(dic);
            containerCell.identify = cellIdentify;
            containerCell.superContainer = self;
            [containerCell setUI:containerCell.jsonData];
        }
        cell = containerCell.cell;
    }
    [cell.container updateView:self.parseCell :self.dataSource[indexPath.section][@"section"][indexPath.row]];
    //布局数据
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.cells[0];
    return [[self calculate:dic[@"height"]] obj_float:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSArray *heads = self.jsonData[@"heads"];
    if (heads) {
        NSDictionary *dic = heads[0];
        return [[self calculate:dic[@"height"]] obj_float:nil];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    NSArray *foots = self.jsonData[@"foots"];
    if (foots) {
        NSDictionary *dic = foots[0];
        return [[self calculate:dic[@"height"]] obj_float:nil];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSArray *heads = self.jsonData[@"heads"];
    if (heads) {
        NSDictionary *dic = heads[0];
        NSString *identify = [NSString stringWithFormat:@"%@_%ld",dic[@"identify"],(long)section];
        UIContainerCell *containerCell = [self.subViews objectForKey:identify];
        if (!containerCell) {
            containerCell = newContainer(dic);
            containerCell.identify = identify;
            containerCell.superContainer = self;
            [containerCell setUI:containerCell.jsonData];
        }
        [containerCell updateView:self.parseCell :self.dataSource[section]];
        return containerCell.view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    NSArray *foots = self.jsonData[@"foots"];
    if (foots) {
        NSDictionary *dic = foots[0];
        NSString *identify = [NSString stringWithFormat:@"%@_%ld",dic[@"identify"],(long)section];
        UIContainerCell *containerCell = [self.subViews objectForKey:identify];
        if (!containerCell) {
            containerCell = newContainer(dic);
            containerCell.identify = identify;
            containerCell.superContainer = self;
            [containerCell setUI:containerCell.jsonData];
        }
        [containerCell updateView:self.parseCell :self.dataSource[section]];
        return containerCell.view;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [self layoutSubViews:[NSMutableDictionary dictionary]];
}

- (void)layoutSubViews:(NSMutableDictionary*)uiDic{
    if (self.tableView.tableHeaderView) {
        UIContainerView *head = self.tableView.tableHeaderView.container;
        if (head) {
            self.tableView.tableHeaderView = nil;
            [head setUI:head.jsonData];
            self.tableView.tableHeaderView = head.view;
        }
    }
    
    if (self.tableView.tableFooterView) {
        UIContainerView *foot = self.tableView.tableFooterView.container;
        if (foot) {
            self.tableView.tableFooterView = nil;
            [foot setUI:foot.jsonData];
            self.tableView.tableFooterView = foot.view;
        }
    }
    [super layoutSubViews:uiDic];
}

@end
