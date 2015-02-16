//
//  Student.m
//  userTestTask
//
//  Created by Mobindustry on 2/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

static NSString *names[] = {@"Truman", @"Colt",@"Frank",@"Olowson",@"Max",@"Luft",@"Sucks",@"Brent",@"Volf",@"Lumen",@"Eric",@"Kluga",@"Bart"};
static NSString *surnames[] = {@"Macak", @"Brauswein",@"Pulten",@"Brenson",@"Wang",@"Krossman",@"Waterman",@"Bruger",@"Piterson",@"Folaveit",@"Moloneht",@"Jameson",@"Marlinskih"};

#import "Student.h"

@implementation Student

+(Student *)generateRandonStudent {
    
    Student *student = [[self alloc] init];
    
    student.gender = arc4random_uniform(2);
    student.name = names[arc4random_uniform(13)];
    student.surname = surnames[arc4random_uniform(13)];
    student.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:60 * 60 * 24 * 365 * arc4random_uniform(35)];
    student.coordinate = CLLocationCoordinate2DMake(48.464246, 35.045945);
    
    
    return student;
    
}

@end
