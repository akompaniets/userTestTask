//
//  LoginViewController.m
//  userTestTask
//
//  Created by Mobindustry on 6/16/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginModel.h"
#import <RKDropdownAlert/RKDropdownAlert.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *password2Field;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (strong, nonatomic) LoginModel *loginModel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pass2FieldVerticalConstraint;

@end

@implementation LoginViewController
{
    BOOL registeringNewUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelButton.alpha = 0.0f;
    self.loginModel = [LoginModel new];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginOrRegisterUser:(UIButton *)sender {
    if (!registeringNewUser) {
        
    }else if (!self.loginField.text.length || !self.passwordField.text.length || !self.password2Field.text.length) {
        [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"fill_all_fields", nil)
               backgroundColor:[UIColor yellowColor]
                     textColor:[UIColor blackColor]];
        return;
        
    } else if (![self.passwordField.text isEqualToString:self.password2Field.text]) {
        [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                       message:NSLocalizedString(@"The entered passwords don't match. Please try again.", nil)
               backgroundColor:[UIColor yellowColor]
                     textColor:[UIColor blackColor]];
        self.passwordField.text = self.password2Field.text = @"";
        return;
    } else {
        __block typeof(self) weakSelf = self;
        [self.loginModel saveUserLogin:self.loginField.text password:self.passwordField.text withCallback:^(BOOL success) {
            [RKDropdownAlert title:NSLocalizedString(@"Success!", nil)
                           message:NSLocalizedString(@"New user created successfully.", nil)
                   backgroundColor:[UIColor greenColor]
                         textColor:[UIColor blackColor]];
            weakSelf.loginField.text = weakSelf.passwordField.text = weakSelf.password2Field.text = @"";
            registeringNewUser = NO;
            [weakSelf.password2Field resignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showRegistrationForm:NO];
                [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
                
            });

        }];
    }
}

- (IBAction)registerNewUser:(UIButton *)sender {
    registeringNewUser = YES;
    [self showRegistrationForm:YES];
    self.cancelButton.alpha = 1.0f;
    [self.loginButton setTitle:@"Register" forState:UIControlStateNormal];
    self.registrationButton.enabled = NO;
    self.registrationButton.alpha = 0.5f;
    
}

- (IBAction)cancelRegistration:(UIButton *)sender {
    [self showRegistrationForm:NO];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    self.cancelButton.alpha = 0.0f;
    self.registrationButton.enabled = YES;
    self.registrationButton.alpha = 1.0f;
}

- (void)showRegistrationForm:(BOOL)show {
    if (show) {
        self.pass2FieldVerticalConstraint.constant +=60;
    } else {
        self.pass2FieldVerticalConstraint.constant -=60;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showAlertWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
