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

FOUNDATION_EXPORT NSString * kBaseURL;
FOUNDATION_EXPORT NSInteger kDefaultUserID;