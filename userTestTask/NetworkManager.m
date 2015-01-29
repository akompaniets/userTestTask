//
//  NetworkManager.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "NetworkManager.h"
#import "CoreDataManager.h"

@interface NetworkManager()

@end

@implementation NetworkManager

- (void)fetchUserDataWithCompletion:(void (^)(NSArray *, NSError *))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self GET:kBaseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(queue, ^{
            
            if (responseObject && block) {
                block(responseObject, nil);
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(queue, ^{
            
            if (error && block) {
                block(nil, error);
            }
        });
        
    }];
}
@end
