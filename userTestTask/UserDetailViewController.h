//
//  UserDetailViewController.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface UserDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPhoneField;
@property (weak, nonatomic) IBOutlet UILabel *userCompany;


@property (strong, nonatomic) UserData *currentUser;

@end
