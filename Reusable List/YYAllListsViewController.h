//
//  YYAllListsViewController.h
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYListViewController.h"
#import <MessageUI/MessageUI.h>

@class YYList;

extern NSString *const APPVERSION;

@interface YYAllListsViewController : UITableViewController <YYListViewControllerDelegate,MFMailComposeViewControllerDelegate>

- (IBAction)sendFeedback:(id)sender;

@end
