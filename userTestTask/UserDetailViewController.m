//
//  UserDetailViewController.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "UserDetailViewController.h"
#import <MapKit/MapKit.h>
#import "CoreDataManager.h"
#import "UserAnnotation.h"
#import <RKDropdownAlert/RKDropdownAlert.h>
#import "MainModel.h"


@interface UserDetailViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *userDetailView;
@property (weak, nonatomic) IBOutlet UIImageView *userViewBackground;
@property (weak, nonatomic) IBOutlet UIButton *editSaveButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSString *tempName;
@property (strong, nonatomic) NSString *tempUserName;
@property (strong, nonatomic) NSString *tempPhone;
@property (strong, nonatomic) MainModel *model;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewTopConstraint;


@end

@implementation UserDetailViewController

{
    BOOL isEditing;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userViewBackground.image = [[UIImage imageNamed:@"cell_bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    self.mapView.layer.cornerRadius = 5.0f;
    
    self.model = [MainModel new];
    
    self.nameField.text = self.currentUser.name;
    self.userNameField.text = self.currentUser.userName;
    self.userPhoneField.text = self.currentUser.phone;
    self.userCompany.text = [NSString stringWithFormat:@"Company: %@", self.currentUser.company];
    
    self.cancelButton.hidden = YES;
    
    [self addTargetForTextField:self.nameField];
    [self addTargetForTextField:self.userNameField];
    [self addTargetForTextField:self.userPhoneField];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:button];

    self.navigationItem.rightBarButtonItem = rightButton;

    UserAnnotation *userAnnotation = [[UserAnnotation alloc] init];
    CLLocationCoordinate2D coord;
    coord.latitude = (CLLocationDegrees)[self.currentUser.lat doubleValue];
    coord.longitude = (CLLocationDegrees)[self.currentUser.lng doubleValue];
    userAnnotation.coordinate = coord;
    userAnnotation.title = self.currentUser.name;
    
    if (CLLocationCoordinate2DIsValid(coord)) {
        [self.mapView addAnnotation:userAnnotation];
        [self.mapView setCenterCoordinate:coord animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addTargetForTextField:(UITextField *)textField
{
    if (textField)
    {
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
}

#pragma mark - Share

- (void)shareButtonDidPress:(UIBarButtonItem *)sender
{
    NSString *shareString = [NSString stringWithFormat:@"Name: %@,\n Username: %@,\n Phone: %@,\n Location: %@ %@", self.currentUser.name,
                            self.currentUser.userName,
                            self.currentUser.phone,
                            self.currentUser.lat,
                            self.currentUser.lng];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareString]
                                                                             applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypeMail,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Edit\Delete user

- (IBAction)editUser:(UIButton *)sender
{
    if (!isEditing) {
        [self.editSaveButton setTitle:@"Save" forState:UIControlStateNormal];
        isEditing = YES;
        self.cancelButton.hidden = NO;
        [self.nameField becomeFirstResponder];
    }else
    {
        [self.editSaveButton setTitle:@"Edit User" forState:UIControlStateNormal];
        isEditing = NO;
        
        if (self.tempName) {
            self.currentUser.name = self.tempName;
        }
        
        if (self.tempUserName) {
            self.currentUser.userName = self.tempUserName;
        }
        
        if (self.tempPhone) {
            self.currentUser.phone = self.tempPhone;
        }
        
        [self cancellationAction];
        
        if ([self.model commitChangesForUser:self.currentUser])
        {
            [RKDropdownAlert title:NSLocalizedString(@"success", nil)
                           message:NSLocalizedString(@"user_updated", nil)
                   backgroundColor:[UIColor greenColor]
                         textColor:[UIColor whiteColor]];
        }
    }
}

- (IBAction)cancelChanges:(UIButton *)sender
{
    [self.editSaveButton setTitle:@"Edit User" forState:UIControlStateNormal];
    self.tempName = self.tempUserName = self.tempPhone = nil;
    self.nameField.text = self.currentUser.name;
    self.userNameField.text = self.currentUser.userName;
    self.userPhoneField.text = self.currentUser.phone;
    isEditing = NO;
    [self cancellationAction];
}

- (void) cancellationAction
{
    self.cancelButton.hidden = YES;

    [self.nameField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.userPhoneField resignFirstResponder];

}


- (IBAction)deleteUser:(UIButton *)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                          message:@"Do you really want to delete the user?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
    [deleteAlert show];
}

- (void) textFieldDidChange:(UITextField *)textField
{
    if (!isEditing)
    {
        isEditing = YES;
        [self.editSaveButton setTitle:@"Save" forState:UIControlStateNormal];
        self.cancelButton.hidden = NO;
    }
    
    switch (textField.tag)
    {
        case 11:
            self.tempName = textField.text;
            break;
        case 22:
            self.tempUserName = textField.text;
            break;
        case 33:
            self.tempPhone = textField.text;
            break;
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            if ([self.model deleteUser:self.currentUser])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}


@end
