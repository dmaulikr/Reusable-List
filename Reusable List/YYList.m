//
//  YYList.m
//  Reusable List
//
//  Created by Molay on 15/9/8.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import "YYList.h"

@implementation YYList

@dynamic itemKey;
@dynamic content;
@dynamic remindTime;
@dynamic repeatType;
@dynamic endDate;
@dynamic dateCreated;
@dynamic hasAlert;
@dynamic hasEndDate;
@dynamic day;
@synthesize hour;
@dynamic minute;

- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.dateCreated = [NSDate date];
  NSUUID *uuid = [[NSUUID alloc] init];
  NSString *key = [uuid UUIDString];
  self.itemKey = key;
}

@end
