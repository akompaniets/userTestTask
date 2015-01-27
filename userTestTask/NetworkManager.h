//
//  NetworkManager.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface NetworkManager : AFHTTPRequestOperationManager

- (void)fetchUserDataWithCompletion:(void(^)(NSArray *array, NSError *error))block;

@end
