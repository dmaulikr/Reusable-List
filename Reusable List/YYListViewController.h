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

- (void)YYListViewControllerDidCancel:(YYListViewController *)controller;
- (void)YYListViewController:(YYListViewController *)controller didFinishAddingList:(YYList *)list;
- (void)YYListViewController:(YYListViewController *)controller didFinishEditingList:(YYList *)list;

@end

@interface YYListViewController : UITableViewController

@property (nonatomic,weak) id <YYListViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
