//
//  NyAnnotation.h
//  userTestTask
//
//  Created by Mobindustry on 2/12/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle coordinate:(CLLocationCoordinate2D)coordinates;
@end
