//
//  AppDelegate.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Application State

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
//    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HasLaunchedForVersion"] < currentVersion) {
//        
//        [[NSUserDefaults standardUserDefaults] setInteger:currentVersion forKey:@"HasLaunchedForVersion"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        // This is the first launch for this version
//        
//    }
    CGFloat appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
//    [NSUserDefaults standardUserDefaults]
    NSLog(@"Info %@",[[NSBundle mainBundle] infoDictionary] );
    return YES;
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[CoreDataManager sharedManager] saveContext];
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           CUSTOM_FONT, NSFontAttributeName, nil]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];


}


@end
