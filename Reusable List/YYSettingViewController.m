//
//  YYSettingViewController.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYSettingViewController.h"

NSString *const APPVERSION = @"1.0";

@interface YYSettingViewController ()

@end

@implementation YYSettingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)feedback:(id)sender {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *picker =
        [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"【反馈】"];
    [picker
        setToRecipients:[NSArray arrayWithObject:@"reusablelist@gmail.com"]];
    NSString *body = [NSString
        stringWithFormat:@"App version: %@\niOS version: %@\nDevice modal: %@\n",
                         APPVERSION, [[UIDevice currentDevice] systemVersion],
                         [[UIDevice currentDevice] model]];
    [picker setMessageBody:body isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
  } else {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"无法发送邮件"
                         message:@"请检查系统邮件的设置"
                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好的"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  //    switch (result) {
  //        case MFMailComposeResultCancelled:
  //            [self dismissViewControllerAnimated:YES completion:NULL];
  //            break;
  //        case MFMailComposeResultFailed:
  //            [self dismissViewControllerAnimated:YES completion:NULL];
  //            break;
  //        case MFMailComposeResultSaved:
  //            [self dismissViewControllerAnimated:YES completion:NULL];
  //            break;
  //        case MFMailComposeResultSent:
  //            [self dismissViewControllerAnimated:YES completion:NULL];
  //            break;
  //        default:
  //            break;
  //    }
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
