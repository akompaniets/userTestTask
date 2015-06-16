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

@property (nonatomic, assign, getter=isMale) BOOL male;

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle gender:(BOOL)male coordinate:(CLLocationCoordinate2D)coordinates;
@end
