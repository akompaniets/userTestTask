//
//  MainModel.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface MainModel : NSObject

- (void)fetchUsersWithCompletion:(void(^)(BOOL success))block;

@end
