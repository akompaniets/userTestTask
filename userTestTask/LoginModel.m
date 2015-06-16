//
//  LoginModel.m
//  userTestTask
//
//  Created by Mobindustry on 6/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "LoginModel.h"
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>

static NSString *ServiceName = @"user_test_task";

@implementation LoginModel

- (void)saveUserLogin:(NSString *)login password:(NSString *)password withCallback:(void(^)(BOOL success))callback {
    
    SSKeychain setPassword:password forService:ServiceName account:<#(NSString *)#>
    callback(YES);
}

@end
