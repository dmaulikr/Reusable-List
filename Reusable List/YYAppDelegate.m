//
//  YYAppDelegate.m
//  Reusable List
//
//  Created by Molay on 15/9/4.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYAppDelegate.h"
#import <MagicalRecord/MagicalRecord.h>
#import "YYList.h"

@import CoreData;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [MagicalRecord setupCoreDataStackWithStoreNamed:@"Reusabl List"];
//  [YYList MR_truncateAll];
  NSArray *lists = [YYList MR_findAll];
  if ([lists count] == 0) {
    YYList *list1 = [YYList MR_createEntity];
    list1.content = @"超市";
    YYList *list2 = [YYList MR_createEntity];
    list2.content = @"取钱";
    YYList *list3 = [YYList MR_createEntity];
    list3.content = @"粥";
    list3.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list4 = [YYList MR_createEntity];
    list4.content = @"剪指甲";
    list4.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list5 = [YYList MR_createEntity];
    list5.content = @"粥";
    list5.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list6 = [YYList MR_createEntity];
    list6.content = @"剪指甲";
    list6.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list7 = [YYList MR_createEntity];
    list7.content = @"粥";
    list7.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list8 = [YYList MR_createEntity];
    list8.content = @"剪指甲";
    list8.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list9 = [YYList MR_createEntity];
    list9.content = @"粥";
    list9.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list10 = [YYList MR_createEntity];
    list10.content = @"剪指甲";
    list10.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list11 = [YYList MR_createEntity];
    list11.content = @"粥";
    list11.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list12 = [YYList MR_createEntity];
    list12.content = @"剪指甲";
    list12.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list13 = [YYList MR_createEntity];
    list13.content = @"粥";
    list13.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list14 = [YYList MR_createEntity];
    list14.content = @"剪指甲";
    list14.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list15 = [YYList MR_createEntity];
    list15.content = @"粥";
    list15.remindTime = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    YYList *list16 = [YYList MR_createEntity];
    list16.content = @"剪指甲";
    list16.remindTime = [NSDate dateWithTimeIntervalSinceNow:120 * 60];
    YYList *list17 = [YYList MR_createEntity];
    list17.content = @"超市";
    YYList *list18 = [YYList MR_createEntity];
    list18.content = @"取钱";
    YYList *list19 = [YYList MR_createEntity];
    list19.content = @"超市";
    YYList *list20 = [YYList MR_createEntity];
    list20.content = @"取钱";
    YYList *list21 = [YYList MR_createEntity];
    list21.content = @"超市";
    YYList *list22 = [YYList MR_createEntity];
    list22.content = @"取钱";
    YYList *list23 = [YYList MR_createEntity];
    list23.content = @"超市";
    YYList *list24 = [YYList MR_createEntity];
    list24.content = @"取钱";
    YYList *list25 = [YYList MR_createEntity];
    list25.content = @"超市";
    YYList *list26 = [YYList MR_createEntity];
    list26.content = @"取钱";
  }
  [[NSManagedObjectContext MR_defaultContext]
      MR_saveToPersistentStoreWithCompletion:nil];
//    NSLog(@"%lu",[lists count]);
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [MagicalRecord cleanUp];
}

@end
