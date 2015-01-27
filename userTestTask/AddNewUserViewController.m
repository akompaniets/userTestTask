//
//  AddNewUserViewController.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "AddNewUserViewController.h"
#import "CoreDataManager.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import <RKDropdownAlert/RKDropdownAlert.h>

@interface AddNewUserViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *regViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *registrationView;
@property (weak, nonatomic) IBOutlet UIImageView *regViewBackground;

@property (weak, nonatomic) IBOutlet UILabel *regFormTitle;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;


@end

@implementation AddNewUserViewController

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regViewBackground.image = [[UIImage imageNamed:@"cell_bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
    self.regFormTitle.text = NSLocalizedString(@"reg_form_title", nil);
    self.regFormTitle.font = CUSTOM_FONT;
    [self getCurrentLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showRegistrationView];
}

#pragma mark - Registration View

- (void)showRegistrationView
{
    self.regViewTopConstraint.constant = 100.0f;
    [UIView animateWithDuration:0.5 animations:^{
        self.registrationView.alpha = 1.0f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.nameField becomeFirstResponder];
    }];
   
}

- (void)hideRegistrationView
{
    self.regViewTopConstraint.constant = -180.0f;
    [UIView animateWithDuration:0.5 animations:^{
        self.registrationView.alpha = 0.0f;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self hideRegistrationView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (!self.nameField.text.length || !self.userNameField.text.length || !self.phoneNumberField.text.length)
    {
        [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"fill_all_fields", nil)
               backgroundColor:[UIColor yellowColor]
                     textColor:[UIColor blackColor]];
        return;
    }
    else
    {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        moc.parentContext = [[CoreDataManager sharedManager] mainContext];
        
        UserData *user = [NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:moc];
        user.name = self.nameField.text;
        user.userName = self.userNameField.text;
        user.phone = self.phoneNumberField.text;
        user.lat = self.lat;
        user.lng = self.lng;
        
        [moc performBlockAndWait:^{
            NSError *error;
            [moc save:&error];
            if (error)
            {
#if DEBUG
                NSLog(@"Saving error - %@", [error userInfo]);
#endif
            }
        }];
       
        if ([[CoreDataManager sharedManager].mainContext hasChanges])
        {
            [[CoreDataManager sharedManager] saveContext];
            self.nameField.text = self.userNameField.text = self.phoneNumberField.text = @"";
            [self showSuccessAlert];
            [self.nameField resignFirstResponder];
            [self.userNameField resignFirstResponder];
            [self.phoneNumberField resignFirstResponder];
        };
    }
}

#pragma mark - 

- (void)showSuccessAlert
{
  [UIView transitionWithView:self.regFormTitle duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
      self.regFormTitle.text = NSLocalizedString(@"registration_successful", nil) ;
      self.regFormTitle.textColor = [UIColor greenColor];
  } completion:^(BOOL finished) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [UIView transitionWithView:self.regFormTitle duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
              self.regFormTitle.text = NSLocalizedString(@"reg_form_title", nil) ;
              self.regFormTitle.textColor = [UIColor whiteColor];
          } completion:nil];
      });
  }];
}

- (void)getCurrentLocation
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
#if DEBUG
    NSLog(@"Current location: %@", newLocation);
#endif
   
    self.lat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
    self.lng = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                   message:NSLocalizedString(@"error_getting_current_location", nil)
           backgroundColor:[UIColor yellowColor]
                 textColor:[UIColor blackColor]];
}

@end
