//
//  Student.m
//  userTestTask
//
//  Created by Mobindustry on 2/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//
#define fixedPoint CLLocationCoordinate2DMake(48.450115, 35.020692)

static NSString *names[] = {@"Truman", @"Colt",@"Frank",@"Olowson",@"Max",@"Luft",@"Sucks",@"Brent",@"Volf",@"Lumen",@"Eric",@"Kluga",@"Bart"};

static NSString *surnames[] = {@"Macak", @"Brauswein",@"Pulten",@"Brenson",@"Wang",@"Krossman",@"Waterman",@"Bruger",@"Piterson",@"Folaveit",@"Moloneht",@"Jameson",@"Marlinskih"};

#import "Student.h"
#import <MapKit/MapKit.h>

@implementation Student

- (instancetype)initWithRandomData {
    self = [super init];
    if (self) {
        
        self.gender = arc4random_uniform(2);
        self.name = names[arc4random_uniform(13)];
        self.surname = surnames[arc4random_uniform(13)];
        self.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:60 * 60 * 24 * 365 * arc4random_uniform(35)];
        self.coordinate = [self randomCoordinateForUser];
//        self.address = [self addressForCoordinate:self.coordinate];
    }
    
    return self;
}

- (MKMapRect)mapRectForUsersLocation {
    
    CGFloat pointsPerMeter = MKMapPointsPerMeterAtLatitude(fixedPoint.latitude);
    CGFloat distance = 1000 * pointsPerMeter;
    MKMapPoint myPoint = MKMapPointForCoordinate(fixedPoint);
    
    MKMapRect usersRect = MKMapRectMake(myPoint.x - distance, myPoint.y - distance, distance * 2, distance * 2);
    
    return usersRect;
}

- (CLLocationCoordinate2D)randomCoordinateForUser {
    
    MKMapRect rect = [self mapRectForUsersLocation];
    double minX = MKMapRectGetMinX(rect);
    double maxX = MKMapRectGetMaxX(rect);
    
    double minY = MKMapRectGetMinY(rect);
    double maxY = MKMapRectGetMaxY(rect);
    
    double latitudePoint = (((double)arc4random()/0x100000000)*(maxX - minX) + minX);
    double longitudePoint = (((double)arc4random()/0x100000000)*(maxY - minY) + minY);
    MKMapPoint coordinatePoint = MKMapPointMake(latitudePoint, longitudePoint);
    
    CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(coordinatePoint);
    
    return coordinate;
    
}

- (NSString *)addressForCoordinate:(CLLocationCoordinate2D)coordinate {
    CLGeocoder *coder = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    __block NSString *address;
    
    [coder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks firstObject];
            
            if (placemark) {
                
                address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                
                
            }
            else {
                NSLog(@"Could not locate");
            }
        }
     ];
    
    return address;
}



@end
