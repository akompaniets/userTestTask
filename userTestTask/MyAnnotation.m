//
//  NyAnnotation.m
//  userTestTask
//
//  Created by Mobindustry on 2/12/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (instancetype) initWithTitle:(NSString *)title subTitle:(NSString *)subTitle gender:(BOOL)male coordinate:(CLLocationCoordinate2D)coordinates
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
