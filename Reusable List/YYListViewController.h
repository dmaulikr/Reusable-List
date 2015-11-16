//
//  YYListViewController.h
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYListViewController;
@class YYList;

@protocol YYListViewControllerDelegate <NSObject>
- (void)DismissYYListViewController:(YYListViewController *)controller;
@end

@interface YYListViewController
    : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) IBOutlet UITextView *textView;
@property(weak, nonatomic) IBOutlet UISwitch *alertSwitch;
@property(weak, nonatomic) IBOutlet UISwitch *endAlertSwitch;
@property(weak, nonatomic) IBOutlet UILabel *alertTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property(weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property(weak, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property(weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property(weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property(nonatomic, weak) id<YYListViewControllerDelegate> delegate;
@property(nonatomic, strong) YYList *itemToEdit;
@property(weak, nonatomic) IBOutlet UILabel *reminderTitle;
@property(weak, nonatomic) IBOutlet UILabel *alertTimeTitle;
@property(weak, nonatomic) IBOutlet UILabel *repeatTitle;
@property(weak, nonatomic) IBOutlet UILabel *endRepeatTitle;
@property(weak, nonatomic) IBOutlet UILabel *endTimeTitle;
@property(weak, nonatomic) IBOutlet UILabel *placeholderLabel;

- (IBAction)setAlert:(id)sender;
- (IBAction)setEndDate:(id)sender;

@end
