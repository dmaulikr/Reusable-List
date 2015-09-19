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
#import "YYSettingViewController.h"

@import CoreData;

@interface YYAllListsViewController ()

@property(nonatomic, strong) NSMutableArray *listsWithDate;
@property(nonatomic, strong) NSMutableArray *listsWithoutDate;

@end

@implementation YYAllListsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
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

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
  UITableViewCell *headerView =
      [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
  return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 0;
  } else {
    return 22;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"listCell"
                                      forIndexPath:indexPath];
  if (indexPath.section == 0) {
    YYList *list = _listsWithDate[indexPath.row];
    cell.textLabel.text = list.content;
    if (list.repeatType) {
      cell.detailTextLabel.text = [NSString
          stringWithFormat:@"%@ %@", list.remindTime, list.repeatType];
    } else {
      cell.detailTextLabel.text =
          [NSString stringWithFormat:@"%@", list.remindTime];
    }
  } else {
    YYList *list = _listsWithoutDate[indexPath.row];
    cell.textLabel.text = list.content;
    cell.detailTextLabel.text = @" ";
  }

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    if (indexPath.section == 0) {
      YYList *list = _listsWithDate[indexPath.row];
      [list MR_deleteEntity];
    } else {
      YYList *list = _listsWithoutDate[indexPath.row];
      [list MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext]
        MR_saveToPersistentStoreWithCompletion:nil];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationFade];
  }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  UINavigationController *navController = segue.destinationViewController;
  YYListViewController *controller =
      (YYListViewController *)navController.topViewController;
  controller.delegate = self;
}

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

#pragma mark - YYListViewControllerDelegate
- (void)YYListViewControllerDidCancel:(YYListViewController *)controller {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)YYListViewController:(YYListViewController *)controller
         didFinishAddingList:(YYList *)list {
}

- (void)YYListViewController:(YYListViewController *)controller
        didFinishEditingList:(YYList *)list {
}

@end
