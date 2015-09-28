//
//  YYListViewController.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYListViewController.h"
#import "YYList.h"

@interface YYListViewController ()

@end

@implementation YYListViewController {
  NSArray *_pickerViewArray;
  BOOL datePickerIsShowing;
  BOOL dateTimePickerIsShowing;
  BOOL pickerViewIsShowing;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // make textview autoresizing according to it's content
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;

  // init private variables
  _pickerViewArray = [[NSArray alloc]
      initWithObjects:@"永不", @"每天", @"每周", @"每周工作日",
                      @"每周末", @"每月", @"每年", nil];
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
  self.doneButton.enabled = (self.contentView.text.length > 0);
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
  if (self.alertSwitch.on) {
    self.alertTimeLabel.textColor = [UIColor blackColor];
  } else {
    self.alertTimeLabel.textColor = [UIColor lightGrayColor];
  }
}

- (IBAction)setEndDate:(id)sender {
  if (self.endAlertSwitch.on) {
    self.endTimeLabel.textColor = [UIColor blackColor];
  } else {
    self.endTimeLabel.textColor = [UIColor lightGrayColor];
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

// TODO: refine
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    [self.contentView resignFirstResponder];

    if (indexPath.row == 1 && self.alertSwitch.on) {
      if (dateTimePickerIsShowing) {
        [self hidePicker:100];
      } else {
        [self hidePicker:200];
        [self hidePicker:300];
        [self showPicker:100];
      }
    } else if (indexPath.row == 3 &&
               ![self.alertTimeLabel.text isEqualToString:@"永不"]) {
      if (pickerViewIsShowing) {
        [self hidePicker:200];
      } else {
        [self hidePicker:100];
        [self hidePicker:300];
        [self showPicker:200];
      }
    } else if (indexPath.row == 6 && self.endAlertSwitch.on) {
      if (datePickerIsShowing) {
        [self hidePicker:300];
      } else {
        [self hidePicker:100];
        [self hidePicker:200];
        [self showPicker:300];
      }
    }
  } else {
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

- (IBAction)alertTimeChanged:(id)sender {
}

- (IBAction)endDateChanged:(id)sender {
}

- (void)showPicker:(NSInteger)tag {
  switch (tag) {
  case 100:
    dateTimePickerIsShowing = YES;
    break;
  case 200:
    pickerViewIsShowing = YES;
    break;
  case 300:
    datePickerIsShowing = YES;
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
  return [_pickerViewArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return [_pickerViewArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
}

@end
