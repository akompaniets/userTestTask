//
//  CompanyCell.m
//  userTestTask
//
//  Created by Mobindustry on 2/6/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "CompanyCell.h"
#import "Company.h"

@interface CompanyCell()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *bs;
@property (weak, nonatomic) IBOutlet UILabel *catchPhrase;
@property (weak, nonatomic) IBOutlet UIImageView *background;



@end

@implementation CompanyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithObject:(Company *)company
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.background.image = [[UIImage imageNamed:@"cell_bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    self.name.text = company.name;
//    self.bs.text = company.bs;
//    self.catchPhrase.text = company.catchPhrase;
}

@end
