//
//  UserData.h
//  userTestTask
//
//  Created by Mobindustry on 1/28/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserData : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userID;

@end
