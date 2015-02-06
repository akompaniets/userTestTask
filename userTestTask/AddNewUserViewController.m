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
#import "MainModel.h"

@interface AddNewUserViewController () <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *regViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *registrationView;
@property (weak, nonatomic) IBOutlet UIImageView *regViewBackground;
@property (weak, nonatomic) IBOutlet UIButton *companyButton;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *regFormTitle;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) NSMutableDictionary *userData;
@property (strong, nonatomic) MainModel *model;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) NSArray *companies;

@end

@implementation AddNewUserViewController
{
    NSArray *companyNames;
    NSInteger selectedRow;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regViewBackground.image = [[UIImage imageNamed:@"cell_bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
    self.pickerBottomConstraint.constant = -204.0f;
    self.model = [MainModel new];
    [self.model fetchAllCompaniesWithCompletitionBlock:^(NSArray *result) {
        if (result)
        {
            companyNames = result;
        }
    }];
    
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
    self.regViewTopConstraint.constant = 75.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.registrationView.alpha = 1.0f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.nameField becomeFirstResponder];
    }];
   
}

- (void)hideRegistrationView
{
    self.regViewTopConstraint.constant = -160.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.registrationView.alpha = 0.0f;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    if (selectedRow)
    {
        if (!self.userData)
        {
            _userData = [[NSMutableDictionary alloc] init];
        }
        NSString *name = companyNames[selectedRow];
        [self setTitleForCompanyButton:[NSString stringWithFormat:@"Company: %@", name]];
        [self.userData setObject:name forKey:@"company"];
        [self hidePicker];
    }
}


- (IBAction)dismissPickerView:(UIBarButtonItem *)sender
{
    [self hidePicker];
}

- (void) hidePicker
{
    self.pickerBottomConstraint.constant = -204.0f;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self hideRegistrationView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (!self.nameField.text.length || !self.userNameField.text.length || !self.phoneNumberField.text.length || ![self.userData objectForKey:@"company"])
    {
        [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"fill_all_fields", nil)
               backgroundColor:[UIColor yellowColor]
                     textColor:[UIColor blackColor]];
        return;
    }
    else
    {
        MainModel *model = [MainModel new];
        if (!self.userData) {
            _userData = [[NSMutableDictionary alloc] init];
        }
        
        NSDictionary *newUser = @{@"name" : self.nameField.text,
                                  @"userName" : self.userNameField.text,
                                  @"phone" : self.phoneNumberField.text,
                                  @"lat" : self.lat,
                                  @"lng" : self.lng};
        
    
        [self.userData addEntriesFromDictionary:newUser];
        
        if ([model createNewUserWithDictionary:self.userData]) {
            self.nameField.text = self.userNameField.text = self.phoneNumberField.text = @"";
            [self setTitleForCompanyButton:@"Company:"];
            [self showSuccessAlert];
            [self.nameField resignFirstResponder];
            [self.userNameField resignFirstResponder];
            [self.phoneNumberField resignFirstResponder];
        }
    }
}

- (IBAction)chooseCompany:(UIButton *)sender
{
    [self.nameField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];

    
    self.pickerBottomConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UIPickerViewDataSource\UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return companyNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return companyNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedRow = row;
}

- (void) setTitleForCompanyButton:(NSString *)title
{
    [self.companyButton setTitle:title forState:UIControlStateNormal];
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
#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
