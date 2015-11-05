//
//  YYPopReminderClass.m
//  Reusable List
//
//  Created by Molay on 15/11/1.
//  Copyright © 2015年 yuying. All rights reserved.
//

#import "YYPopReminderClass.h"
#import "YYList.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation YYPopReminderClass

- (instancetype)init {
  self = [super init];
  if (self) {
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
  }
  return self;
}

- (YYList *)relatedListWithNotification:(NSNotification *)notification {
  NSDictionary *dic = notification.userInfo;
  NSString *UUID = dic[@"UUID"];
  YYList *list = [YYList MR_findFirstByAttribute:@"itemKey" withValue:UUID];
  return list;
}

- (void)cancelNotification:(YYList *)list {
  NSDate *nextFireDate = [self nextFireDate:list];
  if (nextFireDate && list.endDate) {
    if ([self date:nextFireDate reachEndDate:list.endDate]) {
      for (UILocalNotification *notification in
           [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"UUID"] isEqualToString:list.itemKey]) {
          [[UIApplication sharedApplication]
              cancelLocalNotification:notification];
          break;
        }
      }
    }
  }
}

- (void)removeListInfomation:(YYList *)list {
  list.remindTime = nil;
  list.dateCreated = [NSDate date];
  list.endDate = nil;
  list.repeatType = @"Never";
  list.hasAlert = [NSNumber numberWithBool:NO];
  list.hasEndDate = [NSNumber numberWithBool:NO];
  [[NSManagedObjectContext MR_defaultContext]
      MR_saveToPersistentStoreWithCompletion:nil];
}

- (void)resetList:(YYList *)list {
  NSDate *nextFireDate = [self nextFireDate:list];
  if (nextFireDate) {
    if (![self date:nextFireDate reachEndDate:list.endDate]) {
      list.remindTime = nextFireDate;
    } else {
      [self removeListInfomation:list];
    }
  } else {
    [self removeListInfomation:list];
  }
}

- (BOOL)date:(NSDate *)date reachEndDate:(NSDate *)endDate {
  NSDateComponents *comps = [_calendar
      components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
        fromDate:date];
  NSDate *newDate = [_calendar dateFromComponents:comps];
  if ([newDate compare:endDate] == NSOrderedDescending) {
    return YES;
  }
  return NO;
}

- (NSDate *)nextFireDate:(YYList *)list {
  NSDate *nextFireDate;
  if ([list.repeatType isEqualToString:@"Daily"]) {
    nextFireDate = [_calendar dateByAddingUnit:NSCalendarUnitDay
                                         value:1
                                        toDate:list.remindTime
                                       options:0];
  } else if ([list.repeatType isEqualToString:@"Weekly"]) {
    nextFireDate = [_calendar dateByAddingUnit:NSCalendarUnitWeekOfYear
                                         value:1
                                        toDate:list.remindTime
                                       options:0];
  } else if ([list.repeatType isEqualToString:@"Monthly"]) {
    nextFireDate = [_calendar dateByAddingUnit:NSCalendarUnitMonth
                                         value:1
                                        toDate:list.remindTime
                                       options:0];
  } else if ([list.repeatType isEqualToString:@"Yearly"]) {
    nextFireDate = [_calendar dateByAddingUnit:NSCalendarUnitYear
                                         value:1
                                        toDate:list.remindTime
                                       options:0];
  }
  return nextFireDate;
}

@end
