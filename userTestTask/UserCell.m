//
//  UserCell.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "UserCell.h"

@interface UserCell()

@property (weak, nonatomic) IBOutlet UIImageView *cellBackground;

@end

@implementation UserCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.name.font = self.userName.font = self.userPhone.font = SYSTEM_FONT;
    
    self.backgroundView.opaque = YES;
    self.cellBackground.image = [[UIImage imageNamed:@"cell_bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
}

- (void) configureCellWithObject:(UserData *)currentUser
{
    self.name.text = currentUser.name;
    self.userName.text = currentUser.userName;
    self.userPhone.text = currentUser.phone;
}

@end
