//
//  YYPopReminderClass.h
//  Reusable List
//
//  The function for mark as completed button in reminder alert
//
//  Created by Molay on 15/11/1.
//  Copyright © 2015年 yuying. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYList;

@interface YYPopReminderClass : NSObject {
  NSCalendar *_calendar;
}

- (instancetype)init;
- (YYList *)relatedListWithNotification:(NSNotification *)notification;
- (void)cancelNotification:(YYList *)list;
- (void)resetList:(YYList *)list;

@end
