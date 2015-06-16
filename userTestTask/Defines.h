//
//  Defines.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_FONT [UIFont systemFontOfSize:17.0f]
#define CUSTOM_FONT [UIFont fontWithName:@"RegencieLight" size:17.0f]

#define kFirstRun @"firstRun"
#define isFirstRun ![[NSUserDefaults standardUserDefaults] boolForKey:kFirstRun]

#define kSyncDB @"syncDB"
#define isSynchronizedDB [[NSUserDefaults standardUserDefaults] boolForKey:kSyncDB]


#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)


FOUNDATION_EXPORT NSString * BaseURL;
FOUNDATION_EXPORT NSInteger DefaultUserID;
FOUNDATION_EXPORT NSString * CurrentLocationDidUpdateNotification;