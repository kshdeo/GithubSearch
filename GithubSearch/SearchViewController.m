//
//  SearchViewController.m
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "UserViewController.h"
#import "AppDelegate.h"
#import "FavoritesViewController.h"

#define GITHUB_SEARCH_URL @"https://api.github.com/search/users?q=%@"//+location:%@+language:%@+followers:%3E%i"

#define ClientID @"3ac307cc2acb07a4eb0a"
#define ClientSecret @"a4e335aeeab8abfe3e1c5d33dec60779d72daa5a"

@interface SearchViewController ()<UISearchResultsUpdating, UISearchBarDelegate>
{
    NSMutableArray *userList;
    int pagesCached;
    NSString *nextPage;
    int total;
    BOOL loading;
    NSMutableDictionary *favDictionary;;
}
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pagesCached = 0;
    self.clearsSelectionOnViewWillAppear = NO;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    self.title = @"Github Search";
    [(AppDelegate*)[UIApplication sharedApplication].delegate fetchFavoritesWithCompletionBlock:^(BOOL succeeded, NSMutableArray *array) {
        favDictionary = [NSMutableDictionary new];
        if (succeeded) {
            for (PFObject *obj in array) {
                [favDictionary setObject:obj forKey:[obj objectForKey:@"username"]];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    } else {
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchUrl = [NSString stringWithFormat:GITHUB_SEARCH_URL,[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS];
    if ([defaults objectForKey:SETTINGS_LANGUAGE] && [[defaults objectForKey:SETTINGS_LANGUAGE] length]>0) {
        searchUrl = [NSString stringWithFormat:@"%@+language:%@",searchUrl,[[defaults objectForKey:SETTINGS_LANGUAGE] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if ([defaults objectForKey:SETTINGS_LOCATION] && [[defaults objectForKey:SETTINGS_LOCATION] length]>0) {
        searchUrl = [NSString stringWithFormat:@"%@+location:%@",searchUrl,[[defaults objectForKey:SETTINGS_LOCATION] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if ([defaults objectForKey:SETTINGS_FOLLOWERS] && [[defaults objectForKey:SETTINGS_FOLLOWERS] intValue]>0) {
        searchUrl = [NSString stringWithFormat:@"%@+followers:%%3E%@",searchUrl,[defaults objectForKey:SETTINGS_FOLLOWERS]];
    }
    total = 0;
    pagesCached = 0;
    userList = [NSMutableArray new];
    nextPage = nil;
    [self fetchResultsFor:searchUrl];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{

}

- (void)fetchResultsFor:(NSString*)queryString
{
    if ([queryString length]<3) {
        return;
    }
    
    loading = true;
    NSLog(@"API call %@",queryString);
    if (pagesCached==0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:queryString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        loading = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
        NSString *linkStr = [resp.allHeaderFields objectForKey:@"Link"];
        NSArray *arr = [linkStr componentsSeparatedByString:@","];
        if ([arr count]>0 && [arr[0] containsString:@"next"]) {
            NSRange ran = [arr[0] rangeOfString:@">;"];
            nextPage = [[arr[0] substringToIndex:ran.location] substringFromIndex:1];
        } else if ([arr count]>1 && [arr[1] containsString:@"next"]){
            NSRange ran = [arr[1] rangeOfString:@">;"];
            nextPage = [[arr[1] substringToIndex:ran.location] substringFromIndex:1];
        }
        
        NSDictionary *results;
        NSError *jsonError;
        if (data) {
            results = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                               options:kNilOptions
                                                                                                 error:&jsonError]];
        }
        
        if (!error && !jsonError && [results objectForKey:@"items"]) {
            pagesCached++;
            [userList addObjectsFromArray:[results objectForKey:@"items"]];
            total = [[results objectForKey:@"total_count"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = [NSString stringWithFormat:@"Showing %i of %i",pagesCached*30<total?pagesCached*30:total,total];
                [self.tableView reloadData];
            });
            NSLog(@"Results %@",results);
        } else {
            if (pagesCached == 0 && error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                });
            }
            NSLog(@"Error fetching results %@",error);
        }
    }];
    [task resume];
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
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    NSDictionary *user = userList[indexPath.row];
    cell.usenameLabel.text = user[@"login"];
    cell.detailLabel.text = user[@"html_url"];
    cell.favButton.tag = indexPath.row;
    
    if ([favDictionary objectForKey:user[@"login"]]) {
        [cell.favButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        [cell.favButton setUserInteractionEnabled:NO];
        [cell.favButton removeTarget:self action:@selector(favClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.favButton setImage:[UIImage imageNamed:@"addfavorite"] forState:UIControlStateNormal];
        [cell.favButton setUserInteractionEnabled:YES];
        [cell.favButton addTarget:self action:@selector(favClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"profile"];
    [(AppDelegate*)[UIApplication sharedApplication].delegate downloadImageWithURL:[NSURL URLWithString:user[@"avatar_url"]] completionBlock:^(BOOL succeeded, BOOL isNew, UIImage *image) {
        if (succeeded && image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatarView.image = image;
            });
        }
    }];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.view.frame.size.width-40, 50)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    UIView *view = [UIView new];
    if (!userList) {
        label.text = @"Start by typing at least 3 characters of name";
        [view addSubview:label];
    } else if ([userList count] == 0) {
        label.text = @"Sorry, your search returned 0 results. Try changing filter settings.";
        [view addSubview:label];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>(pagesCached*30-10) && (pagesCached*30<total) && !loading && nextPage) {
        [self fetchResultsFor:nextPage];
    }
}

- (void)favClicked:(UIButton*)sender
{
    NSDictionary *user = userList[sender.tag];
    PFObject *fav = [PFObject objectWithClassName:@"Favorites"];
    [fav setObject:user[@"login"] forKey:@"username"];
    [fav setObject:user[@"avatar_url"] forKey:@"imageUrl"];
    [fav setObject:[PFUser currentUser] forKey:@"user"];
    [fav pinInBackground];
    [((AppDelegate*)[UIApplication sharedApplication].delegate).favUsers addObject:fav];
    [fav saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [favDictionary setObject:fav forKey:user[@"login"]];
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if ([segue.identifier isEqualToString:@"userSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        NSDictionary *user = userList[indexPath.row];
        UserViewController *userVC = segue.destinationViewController;
        userVC.login = user[@"login"];
        if ([favDictionary objectForKey:user[@"login"]]) {
            userVC.pObject = [favDictionary objectForKey:user[@"login"]];
        }
    } else if ([segue.identifier isEqualToString:@"favSegue"]) {
        FavoritesViewController *favVC = segue.destinationViewController;
        favVC.favDict = favDictionary;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
