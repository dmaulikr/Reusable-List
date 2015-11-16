//
//  YYList.h
//  Reusable List
//
//  Created by Molay on 15/9/8.
//  Copyright (c) 2015年 yuying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface YYList : NSManagedObject

@property(nullable, nonatomic, retain) NSString *content;
@property(nullable, nonatomic, retain) NSDate *dateCreated;
@property(nullable, nonatomic, retain) NSDate *endDate;
@property(nullable, nonatomic, retain) NSString *itemKey;
@property(nullable, nonatomic, retain) NSDate *remindTime;
@property(nullable, nonatomic, retain) NSString *repeatType;
@property(nullable, nonatomic, retain) NSNumber *hasAlert;
@property(nullable, nonatomic, retain) NSNumber *hasEndDate;
@property(nullable, nonatomic, retain) NSNumber *day;
@property(nullable, nonatomic, retain) NSNumber *hour;
@property(nullable, nonatomic, retain) NSNumber *minute;

@end
