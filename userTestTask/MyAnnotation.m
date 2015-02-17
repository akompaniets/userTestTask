//
//  NyAnnotation.m
//  userTestTask
//
//  Created by Mobindustry on 2/12/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "MyAnnotation.h"
typedef NS_ENUM(NSInteger, Gender){
    Male    = 0,
    Female  = 1 };


@interface Student

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *surname;
@property (assign, nonatomic) NSDate *dateOfBirth;
@property (assign, nonatomic) Gender gender;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *adress;

@end
@implementation MyAnnotation

- (id) initWithTitle:(NSString *)title subTitle:(NSString *)subTitle gender:(BOOL)male coordinate:(CLLocationCoordinate2D)coordinates
{
    self = [super init];
    if (self) {
        self.title = title;
        self.subtitle = subTitle;
        self.coordinate = coordinates;
        self.male = male;
        
        return self;
    }
    
    return nil;
}

@end
