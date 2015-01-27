//
//  Defines.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#define SYSTEM_FONT [UIFont systemFontOfSize:17.0f]
#define CUSTOM_FONT [UIFont fontWithName:@"RegencieLight" size:17.0f]

#define kFirstRun @"firstRun"
#define isFirstRun ![[NSUserDefaults standardUserDefaults] boolForKey:kFirstRun]
