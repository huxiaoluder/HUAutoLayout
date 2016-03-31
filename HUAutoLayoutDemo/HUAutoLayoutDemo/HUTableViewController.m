//
//  HUTableViewController.m
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/30.
//  Copyright © 2016年 HU. All rights reserved.
//

#import "HUTableViewController.h"
#import "HUTableViewCell.h"
#import "ViewController.h"

@interface HUTableViewController ()

@end

@implementation HUTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HUTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autoLayoutCell" forIndexPath:indexPath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    HUTableViewCell *cell = (HUTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    ViewController *vc = (ViewController *)segue.destinationViewController;
    vc.layoutData = cell.layoutData;
}

@end
