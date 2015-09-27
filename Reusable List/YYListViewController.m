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

//@property (nonatomic,copy) NSArray *pickerViewArray;
//@property (nonatomic,strong) UIDatePicker *dateTimePicker;
//@property (nonatomic,strong) UIDatePicker *datePicker;
//@property (nonatomic,strong) UIPickerView *pickerView;

@end

@implementation YYListViewController {
  NSArray *_pickerViewArray;
  UIDatePicker *_dateTimePicker;
  UIDatePicker *_datePicker;
  UIPickerView *_pickerView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;

  _pickerViewArray = [[NSArray alloc]
      initWithObjects:@"永不", @"每天", @"每周", @"每周工作日",
                      @"每周末", @"每月", @"每年", nil];

  _pickerView = [[UIPickerView alloc] init];
  _pickerView.delegate = self;
  _pickerView.dataSource = self;
  _pickerView.tag = 2;

  _dateTimePicker = [[UIDatePicker alloc] init];
  _dateTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
  _dateTimePicker.tag = 1;
  [_dateTimePicker addTarget:self
                      action:@selector(dateChanged:)
            forControlEvents:UIControlEventValueChanged];

  _datePicker = [[UIDatePicker alloc] init];
  _datePicker.datePickerMode = UIDatePickerModeDate;
  _datePicker.tag = 3;
  [_datePicker addTarget:self
                  action:@selector(dateChanged:)
        forControlEvents:UIControlEventValueChanged];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else {
    return 5;
  }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView
dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#>
forIndexPath:indexPath];

    // Configure the cell...

    return cell;
}
*/

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == 1) {
    [self.contentView resignFirstResponder];
  }
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

- (void)dateChanged:(UIDatePicker *)datePicker {
}

@end
