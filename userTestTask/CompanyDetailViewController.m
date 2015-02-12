//
//  CompanyDetailViewController.m
//  userTestTask
//
//  Created by Mobindustry on 2/6/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import "Company.h"
#import "UserData.h"

@interface CompanyDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *companyName;

@end

@implementation CompanyDetailViewController
{
    NSArray *users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    users = [self.company.users allObjects];
    self.companyName.text = self.company.name;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSLog(@"Company Detail! Name - %@, User - %@", self.company.name, users);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * const cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    [self configureCell:cell forIndexPah:indexPath];
    return cell;
}

- (void) configureCell:(UITableViewCell *)cell forIndexPah:(NSIndexPath *)indexPath
{
    UserData *user = users[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = user.name;
}

@end
