//
//  LoginViewController.m
//  Github Search
//
//  Created by Kshitij-Deo on 23/01/16.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signup:(id)sender
{
    PFUser *user = [PFUser user];
    user.username = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text ?: @"";
    [self.view endEditing:YES];
    [self.activityIndicator startAnimating];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.activityIndicator stopAnimating];
        [self.view endEditing:NO];
        if (succeeded) {
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:[[[error userInfo] objectForKey:@"error"] capitalizedString] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)signin:(id)sender
{
    [self.view endEditing:YES];
    [self.activityIndicator startAnimating];
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        [self.view endEditing:NO];
        if (user) {
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = user;
            [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self dismissViewControllerAnimated:YES completion:nil];                
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Sign In Error" message:[[[error userInfo] objectForKey:@"error"] capitalizedString] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
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
