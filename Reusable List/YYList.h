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

@property (nonatomic, retain) NSString * itemKey;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * remindTime;
@property (nonatomic, retain) NSString * repeatType;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * dateCreated;

@end
