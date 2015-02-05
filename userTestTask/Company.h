//
//  Company.h
//  userTestTask
//
//  Created by Mobindustry on 2/5/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * bs;
@property (nonatomic, retain) NSString * catchPhrase;
@property (nonatomic, retain) NSString * name;

@end
