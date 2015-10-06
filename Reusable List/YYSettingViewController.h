//
//  YYSettingViewController.h
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

extern NSString *const APPVERSION;

@interface YYSettingViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *icloudSyn;
@property (weak, nonatomic) IBOutlet UISwitch *autoChangeTheme;

- (IBAction)feedback:(id)sender;

@end
