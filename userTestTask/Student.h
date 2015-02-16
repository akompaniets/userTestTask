//
//  Student.h
//  userTestTask
//
//  Created by Mobindustry on 2/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, Gender){
    Male    = 0,
    Female  = 1 };

@interface Student : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *surname;
@property (assign, nonatomic) NSDate *dateOfBirth;
@property (assign, nonatomic) Gender gender;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *adress;

+ (Student *)generateRandonStudent;
@end
