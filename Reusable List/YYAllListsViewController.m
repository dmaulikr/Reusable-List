//
//  YYAllListsViewController.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYAllListsViewController.h"
#import "YYList.h"
#import "YYSettingViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <ChameleonFramework/Chameleon.h>
#import "Masonry.h"

//@import CoreData;

@interface YYAllListsViewController ()

@end

@implementation YYAllListsViewController {
  NSMutableArray *_listsWithDate;
  NSMutableArray *_listsWithoutDate;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
  NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
  [self.tableView reloadSections:indexSet
                withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
                                     ascending:YES
                                 withPredicate:noRemindFilter] mutableCopy];
}

- (NSString *)formatDetailLabel:(YYList *)list {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [NSLocale autoupdatingCurrentLocale];

  NSUInteger units =
      NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
  NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
  NSDateComponents *comps1 = [calendar components:units fromDate:[NSDate date]];
  NSDate *today = [calendar dateFromComponents:comps1];
  comps1.day += 1;
  NSDate *tomorrow = [calendar dateFromComponents:comps1];
  comps1.day += 1;
  NSDate *dayAfterTomorrow = [calendar dateFromComponents:comps1];
  NSDateComponents *comps2 =
      [calendar components:units fromDate:list.remindTime];
  NSDate *listDateWithDate = [calendar dateFromComponents:comps2];
  NSDateComponents *comps3 =
      [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                  fromDate:list.remindTime];
  NSDate *listDateWithTime = [calendar dateFromComponents:comps3];

  if ([listDateWithDate isEqualToDate:today]) {
    [formatter setDateFormat:@"今天 aaHH:mm"];
  } else if ([listDateWithDate isEqualToDate:tomorrow]) {
    [formatter setDateFormat:@"明天 aaHH:mm"];
  } else if ([listDateWithDate isEqualToDate:dayAfterTomorrow]) {
    [formatter setDateFormat:@"后天 aaHH:mm"];
  } else {
    [formatter setDateFormat:@"yy/M/d  aaHH:mm"];
    return [formatter stringFromDate:list.remindTime];
  }
  return [formatter stringFromDate:listDateWithTime];
}

- (void)clearAllListsWithoutDate {
  UIAlertController *alertController = [UIAlertController
      alertControllerWithTitle:@"删除所有可用事项"
                       message:@"确" @"定"
                       @"要删除所有可用事项吗？该操作不可恢复"
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancel =
      [UIAlertAction actionWithTitle:@"取消"
                               style:UIAlertActionStyleCancel
                             handler:nil];
  UIAlertAction *delete = [UIAlertAction
      actionWithTitle:@"删除"
                style:UIAlertActionStyleDestructive
              handler:^(UIAlertAction *_Nonnull action) {
                for (YYList *list in _listsWithoutDate) {
                  [list MR_deleteEntity];
                }
                [[NSManagedObjectContext MR_defaultContext]
                    MR_saveToPersistentStoreWithCompletion:nil];
//                [self.tableView reloadData];
                NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
                [self.tableView
                      reloadSections:indexSet
                    withRowAnimation:UITableViewRowAnimationAutomatic];
              }];
  [alertController addAction:cancel];
  [alertController addAction:delete];
  [self presentViewController:alertController animated:YES completion:nil];
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
  if (section == 0) {
    return nil;
  }
  UIView *headerView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
  headerView.backgroundColor = [UIColor colorWithHexString:@"#F7F7F7"];

  UILabel *headerLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 22)];
  headerLabel.text = @"可用事项";
  headerLabel.font = [UIFont systemFontOfSize:14];
  [headerView addSubview:headerLabel];

  UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [headerButton setTitle:@"清空所有" forState:UIControlStateNormal];
  [headerButton setTitleColor:[UIColor colorWithHexString:@"#0C7EFB"]
                     forState:UIControlStateNormal];
  headerButton.titleLabel.font = [UIFont systemFontOfSize:14];
  headerButton.contentHorizontalAlignment =
      UIControlContentHorizontalAlignmentRight;
  [headerButton addTarget:self
                   action:@selector(clearAllListsWithoutDate)
         forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:headerButton];
  [headerButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(headerView.mas_right).with.offset(-15);
    make.top.equalTo(headerView.mas_top);
    make.bottom.equalTo(headerView.mas_bottom);
    make.width.equalTo(headerLabel.mas_width);
    make.height.equalTo(headerLabel.mas_height);
  }];

  return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 0;
  } else {
    if ([_listsWithoutDate count] == 0) {
      return 0;
    }
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

    NSString *remindTimeStr = [self formatDetailLabel:list];
    if (list.repeatType) {
      cell.detailTextLabel.text =
          [NSString stringWithFormat:@"%@ %@", remindTimeStr, list.repeatType];
    } else {
      cell.detailTextLabel.text = [NSString stringWithString:remindTimeStr];
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
  //  if ([segue.identifier isEqualToString:@"AddList"]) {
  //    UINavigationController *navController = segue.destinationViewController;
  //    YYListViewController *controller =
  //        (YYListViewController *)navController.topViewController;
  //    controller.delegate = self;
  //  } else if ([segue.identifier isEqualToString:@"EditList"]) {
  //    UINavigationController *navController = segue.destinationViewController;
  //    YYListViewController *controller =
  //        (YYListViewController *)navController.topViewController;
  //    controller.delegate = self;
  //    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
  //    if (indexPath.section == 0) {
  //      controller.itemToEdit = _listsWithDate[indexPath.row];
  //    } else {
  //      controller.itemToEdit = _listsWithoutDate[indexPath.row];
  //    }
  //  }

  if ([segue.identifier isEqualToString:@"EditList"]) {
    UINavigationController *navController = segue.destinationViewController;
    YYListViewController *controller =
        (YYListViewController *)navController.topViewController;
    //       controller.delegate = self;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.section == 0) {
      controller.itemToEdit = _listsWithDate[indexPath.row];
    } else {
      controller.itemToEdit = _listsWithoutDate[indexPath.row];
    }
  }
}

//#pragma mark - YYListViewControllerDelegate
//- (void)YYListViewControllerDismiss:(YYListViewController *)controller {
//  [self dismissViewControllerAnimated:YES
//                           completion:^{
//                               [self.tableView reloadData];
//                               NSIndexSet *indexSet = [[NSIndexSet alloc]
//                               initWithIndex:1];
//                               [self.tableView reloadSections:indexSet
//                                             withRowAnimation:UITableViewRowAnimationAutomatic];
//                           }];
//}

//- (void)YYListViewController:(YYListViewController *)controller
//         didFinishAddingList:(YYList *)list {
//    [[NSManagedObjectContext MR_defaultContext]
//     MR_saveToPersistentStoreWithCompletion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.tableView reloadData];
//}
//
//- (void)YYListViewController:(YYListViewController *)controller
//        didFinishEditingList:(YYList *)list {
//    [[NSManagedObjectContext MR_defaultContext]
//     MR_saveToPersistentStoreWithCompletion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.tableView reloadData];
//}

@end
