//
//  MainModel.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class UserData;

@interface MainModel : NSObject

- (void)fetchUsersWithCompletion:(void(^)(BOOL success))block;
- (BOOL)createNewUserWithDictionary:(NSDictionary *)user;
- (BOOL)commitChangesForUser:(UserData *)user;
- (BOOL)deleteUser:(UserData *)user;

@end
