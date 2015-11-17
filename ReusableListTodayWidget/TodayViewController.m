//
//  TodayViewController.m
//  ReusableListTodayWidget
//
//  Created by Molay on 15/11/15.
//  Copyright © 2015年 yuying. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    NSUserDefaults *sharedData;
    NSArray *lists;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    sharedData = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.yuying.reusablelist.sharing"];
    lists = [sharedData arrayForKey:@"group.com.yuying.reusablelist.sharing"];
    if (lists.count == 0) {
        lists = @[NSLocalizedString(@"Start Adding Your List", nil)];
    }
    if (lists.count <= 5) {
        self.preferredContentSize = CGSizeMake(0, lists.count * 44);
    }else {
        self.preferredContentSize = CGSizeMake(0, 5 * 44);
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    [self.tableView reloadData];
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"list"
                                    forIndexPath:indexPath];
    cell.textLabel.text = lists[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.extensionContext openURL:[NSURL URLWithString:@"reusablelist://"] completionHandler:nil];
}

@end
