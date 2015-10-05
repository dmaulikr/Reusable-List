//
//  YYSettingViewController.h
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYSettingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *icloudSyn;
@property (weak, nonatomic) IBOutlet UISwitch *autoChangeTheme;

- (IBAction)rate:(id)sender;
- (IBAction)feedback:(id)sender;

@end
