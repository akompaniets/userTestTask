//
//  LoginModel.h
//  userTestTask
//
//  Created by Mobindustry on 6/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject

- (void)saveUserLogin:(NSString *)login password:(NSString *)password withCallback:(void(^)(BOOL success))callback;
@end
