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

@end

@implementation YYAllListsViewController {
  NSMutableArray *_listsWithDate;
  NSMutableArray *_listsWithoutDate;
}

- (void)viewDidLoad {
  [super viewDidLoad];
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
                                     ascending:NO
                                 withPredicate:noRemindFilter] mutableCopy];
}

// TODO: test 2 digital month / today,tomorrow,dayaftertomorrow / repeatlabel
- (NSString *)formatDetailLabel:(YYList *)list {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];

  NSUInteger units =
      NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
  NSDateComponents *comps1 =
      [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
  NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:comps1];
  comps1.day += 1;
  NSDate *tomorrow = [[NSCalendar currentCalendar] dateFromComponents:comps1];
  comps1.day += 1;
  NSDate *dayAfterTomorrow =
      [[NSCalendar currentCalendar] dateFromComponents:comps1];
  NSDateComponents *comps2 =
      [[NSCalendar currentCalendar] components:units fromDate:list.remindTime];
  NSDate *listDateWithDate =
      [[NSCalendar currentCalendar] dateFromComponents:comps2];
  NSDateComponents *comps3 = [[NSCalendar currentCalendar]
      components:(NSCalendarUnitHour | NSCalendarUnitMinute)
        fromDate:list.remindTime];
  NSDate *listDateWithTime =
      [[NSCalendar currentCalendar] dateFromComponents:comps3];

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

// TODO:implement headerview programatically
//- (UIView *)tableView:(UITableView *)tableView
//    viewForHeaderInSection:(NSInteger)section {
//    return nil;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView
//    heightForHeaderInSection:(NSInteger)section {
//  if (section == 0) {
//    return 0;
//  } else {
//    return 22;
//  }
//}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return nil;
  } else {
    return @"可用事项";
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
  UINavigationController *navController = segue.destinationViewController;
  YYListViewController *controller =
      (YYListViewController *)navController.topViewController;
  controller.delegate = self;
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
