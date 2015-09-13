//
//  YYAllListsViewController.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYAllListsViewController.h"
#import "YYList.h"
#import <MagicalRecord/MagicalRecord.h>

@import CoreData;

@interface YYAllListsViewController ()

@property(nonatomic, strong) NSMutableArray *listsWithDate;
@property(nonatomic, strong) NSMutableArray *listsWithoutDate;

@end

@implementation YYAllListsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  [self classifyLists];
  if (section == 0) {
    return [_listsWithDate count];
  } else {
    return [_listsWithoutDate count];
  }
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  if (section == 1) {
    return @"可用事项";
  } else {
    return nil;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"listCell"
                                      forIndexPath:indexPath];
  UILabel *contentLabel = (UILabel *)[cell viewWithTag:100];
  UILabel *remindLabel = (UILabel *)[cell viewWithTag:200];
  if (indexPath.section == 0) {
    YYList *list = _listsWithDate[indexPath.row];
    contentLabel.text = list.content;
    if (list.repeatType) {
      remindLabel.text = [NSString
          stringWithFormat:@"%@ %@", list.remindTime, list.repeatType];
    } else {
      remindLabel.text = [NSString stringWithFormat:@"%@", list.remindTime];
    }
  } else {
    YYList *list = _listsWithoutDate[indexPath.row];
    contentLabel.text = list.content;
      remindLabel.hidden = YES;
  }
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the
array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath
*)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// init the mutablearray, add list item into them and sort by date
- (void)classifyLists {
  NSPredicate *hasRemindFilter =
      [NSPredicate predicateWithFormat:@"remindTime == nil"];
  [_listsWithoutDate removeAllObjects];
  _listsWithoutDate = [[YYList MR_findAllSortedBy:@"dateCreated"
                                        ascending:NO
                                    withPredicate:hasRemindFilter] mutableCopy];

  NSPredicate *noRemindFilter =
      [NSPredicate predicateWithFormat:@"remindTime != nil"];
  [_listsWithDate removeAllObjects];
  _listsWithDate = [[YYList MR_findAllSortedBy:@"remindTime"
                                     ascending:NO
                                 withPredicate:noRemindFilter] mutableCopy];
}

@end
