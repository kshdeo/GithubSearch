//
//  FavoritesViewController.m
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import "FavoritesViewController.h"
#import "FavCell.h"
#import "UserViewController.h"
#import "AppDelegate.h"

@interface FavoritesViewController ()
{
    NSMutableArray *userList;
}

@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Favorites";
}

- (void)viewWillAppear:(BOOL)animated
{
    userList = [(AppDelegate*)[UIApplication sharedApplication].delegate favUsers];
    if (!userList || [userList count]==0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [(AppDelegate*)[UIApplication sharedApplication].delegate fetchFavoritesWithCompletionBlock:^(BOOL succeeded, NSMutableArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (succeeded) {
                    userList = [(AppDelegate*)[UIApplication sharedApplication].delegate favUsers];
                    [self.tableView reloadData];
                }
            });
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavCell" forIndexPath:indexPath];
    PFObject *user = userList[indexPath.row];
    cell.usernameLabel.text = [user objectForKey:@"username"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSFormattingUnitStyleMedium;
    format.timeStyle = NSFormattingUnitStyleMedium;
    cell.detailLabel.text = [NSString stringWithFormat:@"Added on %@",[format stringFromDate:user.createdAt]];
    cell.avatarView.image = [UIImage imageNamed:@"profile"];
    cell.avatarView.layer.masksToBounds = YES;
    cell.avatarView.layer.cornerRadius = 5.0;
    [(AppDelegate*)[UIApplication sharedApplication].delegate downloadImageWithURL:[NSURL URLWithString:[user objectForKey:@"imageUrl"]] completionBlock:^(BOOL succeeded, BOOL isNew, UIImage *image) {
        if (succeeded && image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatarView.image = image;
            });
        }
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *user = userList[indexPath.row];
    [self.favDict removeObjectForKey:user[@"username"]];
    [user unpinInBackground];
    [user deleteInBackground];
    [userList removeObject:user];
    [tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if ([segue.identifier isEqualToString:@"userSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        PFObject *user = userList[indexPath.row];
        UserViewController *userVC = segue.destinationViewController;
        userVC.login = [user objectForKey:@"username"];
        userVC.pObject = user;
    }
}

@end
