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
#import <ChameleonFramework/Chameleon.h>
#import "Masonry.h"
#import "UIScrollView+EmptyDataSet.h"
#import "YYPopReminderClass.h"

NSString *const APPVERSION = @"1.0";

@interface YYAllListsViewController () <DZNEmptyDataSetSource,
                                        DZNEmptyDataSetDelegate>

@end

@implementation YYAllListsViewController {
  NSMutableArray *_listsWithDate;
  NSMutableArray *_listsWithoutDate;
  NSCalendar *calendar;
  UIColor *backgroundColor;
  YYPopReminderClass *reminder;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // set tableview backgroundview and navigationbar / status bar style
  backgroundColor = [UIColor colorWithHexString:@"#346888"];
  NSArray *colors = @[ backgroundColor, [UIColor flatMintColorDark] ];
  UIView *view = [[UIView alloc] initWithFrame:self.tableView.frame];
  view.backgroundColor =
      [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                            withFrame:CGRectMake(0, 0, view.bounds.size.width,
                                                 view.bounds.size.height)
                            andColors:colors];
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.backgroundView = view;

  [self.navigationController.navigationBar setBarTintColor:backgroundColor];
  [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  self.navigationController.navigationBar.translucent = NO;

  // init varibale
  calendar = [NSCalendar autoupdatingCurrentCalendar];
  reminder = [[YYPopReminderClass alloc] init];

  // Empty State delegate
  self.tableView.emptyDataSetSource = self;
  self.tableView.emptyDataSetDelegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter addObserver:self
                    selector:@selector(popReminder:)
                        name:@"PopReminder"
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(calculateBadge)
                        name:@"CalculateBadge"
                      object:nil];
  [defaultCenter addObserver:self
                    selector:@selector(refresh)
                        name:@"RefreshApp"
                      object:nil];
  [self reloadTableViewAndSection];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"PopReminder"
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"CalculateBadge"
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"RefreshApp"
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)sendFeedback:(id)sender {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *picker =
        [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"【反馈】Reusable List Feedback"];
    [picker setToRecipients:[NSArray arrayWithObject:@"molayyu@gmail.com"]];
    NSString *body =
        [NSString stringWithFormat:
                      @"App version: %@\niOS version: %@\nDevice modal: %@\n",
                      APPVERSION, [[UIDevice currentDevice] systemVersion],
                      [[UIDevice currentDevice] model]];
    [picker setMessageBody:body isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
  } else {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Cannot sent email", nil)
                         message:NSLocalizedString(
                                     @"Please check the system email setting",
                                     nil)
                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleDefault
                               handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - help methods
// init the mutablearray, add listitems and sort
- (void)classifyLists {
  NSArray *lists = [YYList MR_findAll];
  for (YYList *list in lists) {
    if (!list.content) {
      [list MR_deleteEntity];
    }
  }

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
    [formatter setDateFormat:@" aaK:mm"];
    return [NSLocalizedString(@"Today", nil)
        stringByAppendingString:[formatter stringFromDate:listDateWithTime]];
  } else if ([listDateWithDate isEqualToDate:tomorrow]) {
    [formatter setDateFormat:@" aaK:mm"];
    return [NSLocalizedString(@"Tomorrow", nil)
        stringByAppendingString:[formatter stringFromDate:listDateWithTime]];
  } else if ([listDateWithDate isEqualToDate:dayAfterTomorrow]) {
    [formatter setDateFormat:@" aaK:mm"];
    return [NSLocalizedString(@"Day after tomorrow", nil)
        stringByAppendingString:[formatter stringFromDate:listDateWithTime]];
  } else {
    [formatter setDateFormat:@"yy/M/d  aaK:mm"];
    return [formatter stringFromDate:list.remindTime];
  }
}

- (void)clearAllListsWithoutDate {
  UIAlertController *alertController = [UIAlertController
      alertControllerWithTitle:NSLocalizedString(@"Delete all the spare lists",
                                                 nil)
                       message:NSLocalizedString(
                                   @"This operation cannot be canceled", nil)
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancel =
      [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                               style:UIAlertActionStyleCancel
                             handler:nil];
  UIAlertAction *delete =
      [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *_Nonnull action) {
                               for (YYList *list in _listsWithoutDate) {
                                 [list MR_deleteEntity];
                               }
                               [[NSManagedObjectContext MR_defaultContext]
                                   MR_saveToPersistentStoreWithCompletion:nil];
                               [self reloadTableViewAndSection];
                             }];
  [alertController addAction:cancel];
  [alertController addAction:delete];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)manuallyMarkAsCompleted:(UIButton *)sender {
  // clear notificaitonbar message
  [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

  NSString *itemKey = sender.titleLabel.text;
  YYList *list = [YYList MR_findFirstByAttribute:@"itemKey" withValue:itemKey];
  [reminder resetList:list];
  [reminder cancelNotification:list];
  [self reloadTableViewAndSection];
}

- (void)calculateBadge {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  for (YYList *list in _listsWithDate) {
    if ([list.remindTime compare:[NSDate date]] != NSOrderedDescending) {
      [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }
  }
}

- (void)refresh {
  for (YYList *list in _listsWithDate) {
    if ([list.remindTime compare:[NSDate date]] != NSOrderedDescending) {
      //      [self cancelNotification:list];
      [reminder cancelNotification:list];
    }
  }
  [self reloadTableViewAndSection];
}

#pragma mark - PopReminder notification
- (void)popReminder:(NSNotification *)notification {
  YYList *list = [reminder relatedListWithNotification:notification];
  [reminder cancelNotification:list];
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:@""
                                          message:list.content
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancel =
      [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) {
                               [self reloadTableViewAndSection];
                             }];
  UIAlertAction *complete = [UIAlertAction
      actionWithTitle:NSLocalizedString(@"Complete", nil)
                style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *action) {
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                    1;
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                    0;
                [reminder resetList:list];
                [self reloadTableViewAndSection];
              }];
  [alertController addAction:cancel];
  [alertController addAction:complete];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reloadTableViewAndSection {
  [self.tableView reloadData];
  NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
  [self.tableView reloadSections:indexSet
                withRowAnimation:UITableViewRowAnimationAutomatic];
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
      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 33)];
  headerView.backgroundColor = [UIColor clearColor];

  UILabel *headerLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 33)];
  headerLabel.text = NSLocalizedString(@"Spare Lists", nil);
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.font = [UIFont systemFontOfSize:14];
  [headerView addSubview:headerLabel];

  UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [headerButton setTitle:NSLocalizedString(@"Delete All", nil)
                forState:UIControlStateNormal];
  [headerButton setTitleColor:[UIColor whiteColor]
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
    return 33;
  }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 66;
  }
  return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"firstSectionCell"
                                        forIndexPath:indexPath];
    YYList *list = _listsWithDate[indexPath.row];

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = list.content;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    cell.imageView.userInteractionEnabled = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"Stars"]
                      forState:UIControlStateNormal];
    [button addTarget:self
                  action:@selector(manuallyMarkAsCompleted:)
        forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 40, 40);
    button.titleLabel.text = list.itemKey;
    button.titleLabel.hidden = YES;
    [cell.imageView addSubview:button];

    NSString *remindTimeStr = [self formatDetailLabel:list];
    if ([list.remindTime compare:[NSDate date]] != NSOrderedDescending) {
      cell.detailTextLabel.textColor =
          [[UIColor colorWithHexString:@"#F5675D"] lightenByPercentage:0.2];
    } else {
      cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    }

    if (list.repeatType && ![list.repeatType isEqualToString:@"Never"]) {
      cell.detailTextLabel.text =
          [NSString stringWithFormat:@"%@ %@", remindTimeStr,
                                     NSLocalizedString(list.repeatType, nil)];
    } else {
      cell.detailTextLabel.text = [NSString stringWithString:remindTimeStr];
    }
    return cell;

  } else {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"secondSectionCell"
                                        forIndexPath:indexPath];
    YYList *list = _listsWithoutDate[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = list.content;
    cell.imageView.userInteractionEnabled = NO;
    return cell;
  }
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

      for (UILocalNotification *notification in
           [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"UUID"] isEqualToString:list.itemKey]) {
          [[UIApplication sharedApplication]
              cancelLocalNotification:notification];
          break;
        }
      }
      [list MR_deleteEntity];

    } else {
      YYList *list = _listsWithoutDate[indexPath.row];
      [list MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext]
        MR_saveToPersistentStoreWithCompletion:nil];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(reloadTableViewAndSection)
               withObject:self
               afterDelay:0.25];
  }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    [self performSegueWithIdentifier:@"EditList" sender:indexPath];
  } else {
    [self performSegueWithIdentifier:@"EditSpareList" sender:indexPath];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  UINavigationController *navController = segue.destinationViewController;
  YYListViewController *controller =
      (YYListViewController *)navController.topViewController;
  controller.delegate = self;
  NSIndexPath *indexPath = sender;
  if ([segue.identifier isEqualToString:@"EditList"]) {
    controller.itemToEdit = _listsWithDate[indexPath.row];
  } else if ([segue.identifier isEqualToString:@"EditSpareList"]) {
    controller.itemToEdit = _listsWithoutDate[indexPath.row];
  }
}

#pragma mark - YYListViewControllerDelegate
- (void)DismissYYListViewController:(YYListViewController *)controller {
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             [self reloadTableViewAndSection];
                           }];
}

#pragma mark - Empty State

// data source
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
  return [UIImage imageNamed:@"Astronaut"];
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView {
  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"transform"];
  animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  animation.toValue = [NSValue
      valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
  animation.duration = 0.25;
  animation.cumulative = YES;
  animation.repeatCount = MAXFLOAT;

  return animation;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView
                                          forState:(UIControlState)state {
  NSDictionary *attributes = @{
    NSFontAttributeName : [UIFont boldSystemFontOfSize:24.0f],
    NSForegroundColorAttributeName : [UIColor whiteColor]
  };

  return [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"Start Adding Your List", nil)
          attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
  NSArray *colors = @[ backgroundColor, [UIColor flatMintColorDark] ];
  return [UIColor
      colorWithGradientStyle:UIGradientStyleTopToBottom
                   withFrame:CGRectMake(0, 0, self.tableView.bounds.size.width,
                                        self.tableView.bounds.size.height)
                   andColors:colors];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
  return -66;
}

// delegate
- (BOOL)emptyDataSetShouldShow:(UIScrollView *)scrollView {
  return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
  return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
  return NO;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView {
  return YES;
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
  [self performSegueWithIdentifier:@"AddList" sender:nil];
}

@end
