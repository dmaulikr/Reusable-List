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

@interface YYListViewController ()

@end

@implementation YYListViewController {
  NSArray *_repeatTypeArray;
  NSArray *_pickerArray;
  BOOL datePickerIsShowing;
  BOOL dateTimePickerIsShowing;
  BOOL pickerViewIsShowing;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // make textview autoresizing according to it's content
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.contentView.textContainerInset = UIEdgeInsetsMake(12, 12, 0, 12);

  self.endAlertSwitch.enabled = NO;

  // init private variables
  _repeatTypeArray = [[NSArray alloc]
      initWithObjects:@"永不", @"每天", @"每周", @"每周工作日",
                      @"每周末", @"每月", @"每年", nil];
  _pickerArray = [[NSArray alloc] initWithObjects:@100, @200, @300, nil];
  datePickerIsShowing = NO;
  dateTimePickerIsShowing = NO;
  pickerViewIsShowing = NO;

  // init pickerView
  self.pickerView.delegate = self;
  self.pickerView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.contentView becomeFirstResponder];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillShow)
             name:UIKeyboardWillShowNotification
           object:nil];
  self.doneButton.enabled = (self.contentView.text.length > 0);
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
  [self.delegate YYListViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    
}

- (IBAction)setAlert:(id)sender {
  [self.contentView resignFirstResponder];
  if (self.alertSwitch.on) {
    self.alertTimeLabel.textColor = [UIColor blackColor];
  } else {
    self.alertTimeLabel.textColor = [UIColor lightGrayColor];
    self.alertTimeLabel.text = @"无";
    self.repeatLabel.textColor = [UIColor lightGrayColor];
    self.repeatLabel.text = @"永不";
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = @"无";
    [self hidePicker:100];
    [self hidePicker:200];
    [self hidePicker:300];
    self.endAlertSwitch.on = NO;
    self.endAlertSwitch.enabled = NO;
  }
}

- (IBAction)setEndDate:(id)sender {
  [self.contentView resignFirstResponder];
  if (self.endAlertSwitch.on) {
    self.endTimeLabel.textColor = [UIColor blackColor];
  } else {
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = @"无";
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
    [self.contentView resignFirstResponder];

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
                 ![self.alertTimeLabel.text isEqualToString:@"无"]) {
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
    [self.contentView becomeFirstResponder];
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
  self.doneButton.enabled = (self.contentView.text.length > 0);
  if ([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}

#pragma mark - UIPickerViewDelegate

- (IBAction)alertTimeChanged:(UIDatePicker *)sender {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yy/MM/d EEE  aaHH:mm"];
    formatter.locale = [NSLocale autoupdatingCurrentLocale];
  self.alertTimeLabel.text = [formatter stringFromDate:sender.date];
  self.repeatLabel.textColor = [UIColor blackColor];
}

- (IBAction)endDateChanged:(UIDatePicker *)sender {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterLongStyle];
  [formatter setTimeStyle:NSDateFormatterNoStyle];
    formatter.locale = [NSLocale autoupdatingCurrentLocale];
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
  return [_repeatTypeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  self.repeatLabel.text = [_repeatTypeArray objectAtIndex:row];
  if ([self.repeatLabel.text isEqualToString:@"永不"]) {
    self.endAlertSwitch.enabled = NO;
    self.endAlertSwitch.on = NO;
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
    self.endTimeLabel.text = @"无";
  } else {
    self.endAlertSwitch.enabled = YES;
    self.repeatLabel.textColor = [UIColor blackColor];
  }
}

@end
