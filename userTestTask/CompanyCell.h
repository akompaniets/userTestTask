//
//  CompanyCell.h
//  userTestTask
//
//  Created by Mobindustry on 2/6/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Company;

@interface CompanyCell : UITableViewCell

-(void) configureCellWithObject:(Company* )company;

@end
