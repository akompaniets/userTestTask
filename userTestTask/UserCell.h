//
//  UserCell.h
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userPhone;

- (void) configureCellWithObject:(UserData *)currentUser;

@end
