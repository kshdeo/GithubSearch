//
//  UserViewController.m
//  Github Search
//
//  Created by Kshitij-Deo on 24/01/16.
//

#import "UserViewController.h"

#define GITHUB_USER_URL @"https://api.github.com/users/%@"

@interface UserViewController ()
{
    NSDictionary *userDict;
}
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerslabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *reposLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation UserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 5.0;
    self.navigationItem.title = self.login;
}

- (void)reloadData
{
    if (!userDict) {
        return;
    }
    if ([userDict objectForKey:@"name"] != [NSNull null]) {
        self.fullName.text = [userDict objectForKey:@"name"];
    }
    self.emailLabel.text = [NSString stringWithFormat:@"Email: %@",[userDict objectForKey:@"email"]];
    self.username.text = self.login;
    
    if ([userDict objectForKey:@"email"] && ([userDict objectForKey:@"email"] != [NSNull null])) {
        self.emailLabel.text = [NSString stringWithFormat:@"Email: %@",[userDict objectForKey:@"email"]];
    } else {
        self.emailLabel.text = @"";
    }

    if ([userDict objectForKey:@"location"] && ([userDict objectForKey:@"location"] != [NSNull null])) {
        self.locationLabel.text = [NSString stringWithFormat:@"Located in: %@",[userDict objectForKey:@"location"]];
    } else {
        self.locationLabel.text = @"";
    }
    
    self.urlLabel.text = [userDict objectForKey:@"html_url"];
    self.reposLabel.text = [NSString stringWithFormat:@"Public repos: %@",[userDict objectForKey:@"public_repos"]];
    self.followerslabel.text = [NSString stringWithFormat:@"Followers: %@  | Following: %@",[userDict objectForKey:@"followers"],[userDict objectForKey:@"following"]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:[userDict objectForKey:@"avatar_url"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error ) {
            UIImage *fetchedImage = [UIImage imageWithData:data];
            if (fetchedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarView.image = fetchedImage;
                });
            }
        }
    }];
    [task resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.pObject objectForKey:@"userDict"]) {
        userDict = [self.pObject objectForKey:@"userDict"];
        [self reloadData];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *userUrl = [NSString stringWithFormat:GITHUB_USER_URL,self.login];
    NSLog(@"API call %@",userUrl);
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:userUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (!error ) {
            userDict = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                           options:kNilOptions
                                                                                                             error:nil]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
            [self.pObject setObject:userDict forKey:@"userDict"];
            [self.pObject saveInBackground];
            [self.pObject pinInBackground];
            NSLog(@"Results %@",userDict);
        } else {
            NSLog(@"Error fetching results %@",error);
            if (![self.pObject objectForKey:@"userDict"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
        }
    }];
    [task resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:userDict[@"html_url"]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
