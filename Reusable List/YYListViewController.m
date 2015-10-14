//
//  YYListViewController.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYListViewController.h"
#import "YYList.h"
#import <MagicalRecord/MagicalRecord.h>
#import <ChameleonFramework/Chameleon.h>

@interface YYListViewController ()

@end

@implementation YYListViewController {
  NSArray *_repeatTypeArray;
  NSArray *_pickerArray;
  BOOL datePickerIsShowing;
  BOOL dateTimePickerIsShowing;
  BOOL pickerViewIsShowing;
  NSDateFormatter *formatter;
  NSString *repeat;    // store choosed picker value
  YYList *unsavedList; // used for saving when app be terminated
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter addObserver:self
                    selector:@selector(keyboardWillShow)
                        name:UIKeyboardWillShowNotification
                      object:nil];

  // make textview autoresizing according to it's content
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.textView.textContainerInset = UIEdgeInsetsMake(12, 12, 0, 12);

  // init private variables
  _repeatTypeArray = @[
    @"Never",
    @"Daily",
    @"Weekly",
    @"Workday",
    @"Weekends",
    @"Monthly",
    @"Yearly"
  ];
  _pickerArray = @[ @100, @200, @300 ];
  datePickerIsShowing = NO;
  dateTimePickerIsShowing = NO;
  pickerViewIsShowing = NO;

  formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [NSLocale autoupdatingCurrentLocale];

  if (!self.itemToEdit) {
    unsavedList = [YYList MR_createEntity];
  }

  // init pickerView
  self.pickerView.delegate = self;
  self.pickerView.dataSource = self;

  // configure the view
  if (self.itemToEdit != nil) {
    self.doneButton.enabled = YES;
    self.textView.text = self.itemToEdit.content;
    self.alertSwitch.on = [self.itemToEdit.hasAlert boolValue];
    if (self.alertSwitch.on) {
      self.alertTimeLabel.textColor = [UIColor blackColor];
    }
    if (self.itemToEdit.remindTime) {
      [self configDateFormatterForDateTimeLabel];
      self.alertTimeLabel.text =
          [formatter stringFromDate:self.itemToEdit.remindTime];
      self.repeatLabel.textColor = [UIColor blackColor];
    } else {
      self.alertTimeLabel.text = NSLocalizedString(@"None", nil);
    }
    if (self.itemToEdit.repeatType) {
      self.repeatLabel.text =
          NSLocalizedString(self.itemToEdit.repeatType, nil);
    } else {
      self.repeatLabel.text = NSLocalizedString(@"Never", nil);
    }
    if ([self.itemToEdit.repeatType isEqualToString:@"Never"]) {
      self.endAlertSwitch.enabled = NO;
    }
    self.endAlertSwitch.on = [self.itemToEdit.hasEndDate boolValue];
    if (self.endAlertSwitch.on) {
      self.endTimeLabel.textColor = [UIColor blackColor];
    }
    if (self.itemToEdit.endDate) {
      [self configDateFormatterForDateLabel];
      self.endTimeLabel.text =
          [formatter stringFromDate:self.itemToEdit.endDate];
    } else {
      self.endTimeLabel.text = NSLocalizedString(@"None", nil);
    }
  } else {
    [self.textView becomeFirstResponder];
    self.endAlertSwitch.enabled = NO;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
  [self.textView resignFirstResponder];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
  if (self.itemToEdit != nil) {
    self.itemToEdit.content = self.textView.text;
    self.itemToEdit.hasAlert = [NSNumber numberWithBool:self.alertSwitch.on];
    [self configDateFormatterForDateTimeLabel];
    self.itemToEdit.remindTime =
        [formatter dateFromString:self.alertTimeLabel.text];
    if (repeat) {
      self.itemToEdit.repeatType = repeat;
    } else {
      self.itemToEdit.repeatType = @"Never";
    }
    self.itemToEdit.hasEndDate =
        [NSNumber numberWithBool:self.endAlertSwitch.on];
    [self configDateFormatterForDateLabel];
    self.itemToEdit.endDate = [formatter dateFromString:self.endTimeLabel.text];
    if (self.itemToEdit.remindTime) {
      self.itemToEdit.timeInterval =
          [NSNumber numberWithFloat:
                        [self.itemToEdit.remindTime
                            timeIntervalSinceDate:self.itemToEdit.dateCreated]];
    } else {
      self.itemToEdit.dateCreated = [NSDate date];
    }

    if (self.itemToEdit.remindTime) {
      [self scheduleNotificaiton:self.itemToEdit];
    }

  } else {
    YYList *list = [YYList MR_createEntity];
    list.content = self.textView.text;
    list.hasAlert = [NSNumber numberWithBool:self.alertSwitch.on];
    [self configDateFormatterForDateTimeLabel];
    list.remindTime = [formatter dateFromString:self.alertTimeLabel.text];
    if (repeat) {
      list.repeatType = repeat;
    } else {
      list.repeatType = @"Never";
    }
    list.hasEndDate = [NSNumber numberWithBool:self.endAlertSwitch.on];
    [self configDateFormatterForDateLabel];
    list.endDate = [formatter dateFromString:self.endTimeLabel.text];
    list.timeInterval =
        [NSNumber numberWithDouble:[list.remindTime timeIntervalSinceNow]];

    if (list.remindTime) {
      [self scheduleNotificaiton:list];
    }

    [unsavedList MR_deleteEntity];
    unsavedList = nil;
  }
  [[NSManagedObjectContext MR_defaultContext]
      MR_saveToPersistentStoreWithCompletion:nil];
  [self.textView resignFirstResponder];
  [self.delegate DismissYYListViewController:self];
}

- (IBAction)setAlert:(id)sender {
  [self.textView resignFirstResponder];
  if (self.alertSwitch.on) {
    self.alertTimeLabel.textColor = [UIColor blackColor];
    if (self.itemToEdit) {
      NSDate *suggestDate =
          [NSDate dateWithTimeIntervalSinceNow:[self.itemToEdit.timeInterval
                                                       floatValue]];
      [self configDateFormatterForDateTimeLabel];
      self.alertTimeLabel.text = [formatter stringFromDate:suggestDate];
    } else {
      [self configDateFormatterForDateTimeLabel];
      self.alertTimeLabel.text = [formatter stringFromDate:[NSDate date]];
    }
  } else {
    self.alertTimeLabel.textColor = [UIColor lightGrayColor];
    self.alertTimeLabel.text = NSLocalizedString(@"None", nil);
    self.repeatLabel.textColor = [UIColor lightGrayColor];
    self.repeatLabel.text = NSLocalizedString(@"Never", nil);
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = NSLocalizedString(@"None", nil);
    [self hidePicker:100];
    [self hidePicker:200];
    [self hidePicker:300];
    self.endAlertSwitch.on = NO;
    self.endAlertSwitch.enabled = NO;
  }
}

- (IBAction)setEndDate:(id)sender {
  [self.textView resignFirstResponder];
  if (self.endAlertSwitch.on) {
    self.endTimeLabel.textColor = [UIColor blackColor];
  } else {
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = NSLocalizedString(@"None", nil);
    [self hidePicker:300];
  }
}

- (void)keyboardWillShow {
  [self hidePicker:100];
  [self hidePicker:200];
  [self hidePicker:300];
}

- (void)hideOtherPickerAndShowPicker:(NSInteger)tag {
  for (NSNumber *picker in _pickerArray) {
    if ([picker isEqualToNumber:[NSNumber numberWithInteger:tag]]) {
      [self showPicker:[picker integerValue]];
    } else {
      [self hidePicker:[picker integerValue]];
    }
  }
}

- (void)configDateFormatterForDateTimeLabel {
  [formatter setDateFormat:@"yy/MM/d EEE  aaK:mm"];
}

- (void)configDateFormatterForDateLabel {
  [formatter setDateStyle:NSDateFormatterLongStyle];
  [formatter setTimeStyle:NSDateFormatterNoStyle];
}

- (void)scheduleNotificaiton:(YYList *)list {
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  notification.alertBody = list.content;
  notification.fireDate = list.remindTime;
  notification.timeZone = [NSTimeZone defaultTimeZone];
  notification.soundName = UILocalNotificationDefaultSoundName;
  notification.userInfo = @{ @"UUID" : list.itemKey };
  notification.category = @"listCategory";
  //    notification.applicationIconBadgeNumber++;
  if ([list.repeatType isEqualToString:@"Daily"]) {
    notification.repeatInterval = NSCalendarUnitDay;
  } else if ([list.repeatType isEqualToString:@"Weekly"]) {
    notification.repeatInterval = NSCalendarUnitWeekday;
  } else if ([list.repeatType isEqualToString:@"Monthly"]) {
    notification.repeatInterval = NSCalendarUnitMonth;
  } else if ([list.repeatType isEqualToString:@"Yearly"]) {
    notification.repeatInterval = NSCalendarUnitYear;
  }
  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = self.tableView.rowHeight;
  if (indexPath.section == 1) {
    if (indexPath.row == 2) {
      height = dateTimePickerIsShowing ? 217 : 0;
    } else if (indexPath.row == 4) {
      height = pickerViewIsShowing ? 217 : 0;
    } else if (indexPath.row == 7) {
      height = datePickerIsShowing ? 217 : 0;
    }
  }
  return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    [self.textView resignFirstResponder];

    if (indexPath.row == 1 && self.alertSwitch.on) {
      if (dateTimePickerIsShowing) {
        [self hidePicker:100];
      } else {
        [self hideOtherPickerAndShowPicker:100];
      }
    } else if (indexPath.row == 3) {
      if (pickerViewIsShowing) {
        [self hidePicker:200];
      } else if (self.alertSwitch.on &&
                 ![self.alertTimeLabel.text
                     isEqualToString:NSLocalizedString(@"None", nil)]) {
        [self hideOtherPickerAndShowPicker:200];
      }
    } else if (indexPath.row == 6 && self.endAlertSwitch.on) {
      if (datePickerIsShowing) {
        [self hidePicker:300];
      } else {
        [self hideOtherPickerAndShowPicker:300];
      }
    }
  } else if (indexPath.section == 0) {
    [self.textView becomeFirstResponder];
  }

  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView;
{
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  self.doneButton.enabled = (text.length > 0);
  if ([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if (self.itemToEdit) {
    self.itemToEdit.content = textView.text;
  } else {
    unsavedList.content = textView.text;
  }
}

#pragma mark - UIPickerViewDelegate

- (IBAction)alertTimeChanged:(UIDatePicker *)sender {
  [self configDateFormatterForDateTimeLabel];
  self.alertTimeLabel.text = [formatter stringFromDate:sender.date];
  self.repeatLabel.textColor = [UIColor blackColor];
}

- (IBAction)endDateChanged:(UIDatePicker *)sender {
  [self configDateFormatterForDateLabel];
  self.endTimeLabel.text = [formatter stringFromDate:sender.date];
}

- (void)showPicker:(NSInteger)tag {
  NSDate *currentDate = [NSDate date];
  switch (tag) {
  case 100:
    dateTimePickerIsShowing = YES;
    self.dateTimePicker.minimumDate = currentDate;
    break;
  case 200:
    pickerViewIsShowing = YES;
    break;
  case 300:
    datePickerIsShowing = YES;
    self.datePicker.minimumDate = currentDate;
    break;
  default:
    break;
  }
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

- (void)hidePicker:(NSInteger)tag {
  switch (tag) {
  case 100:
    dateTimePickerIsShowing = NO;
    break;
  case 200:
    pickerViewIsShowing = NO;
    break;
  case 300:
    datePickerIsShowing = NO;
    break;
  default:
    break;
  }
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
  return [_repeatTypeArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return NSLocalizedString([_repeatTypeArray objectAtIndex:row], nil);
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  repeat = [_repeatTypeArray objectAtIndex:row];
  self.repeatLabel.text = NSLocalizedString(repeat, nil);
  if ([self.repeatLabel.text
          isEqualToString:NSLocalizedString(@"Never", nil)]) {
    self.endAlertSwitch.enabled = NO;
    self.endAlertSwitch.on = NO;
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = NSLocalizedString(@"None", nil);
  } else {
    self.endAlertSwitch.enabled = YES;
    self.repeatLabel.textColor = [UIColor blackColor];
  }
}

@end
