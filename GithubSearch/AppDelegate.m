//
//  AppDelegate.m
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSCache *imageCache;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"8RirYr1sKN9oDoVqv7gXgDmaPzDeDzthTjWhW0TM"
                  clientKey:@"U9sHq6gJXFCm12YM9E7VTyBc0AkdVNSSnxLWxsVK"];
    return YES;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, BOOL isNew, UIImage *image))completionBlock
{
    if (!imageCache) imageCache = [[NSCache alloc] init];
    UIImage *parseImg = [imageCache objectForKey:url];
    if (!parseImg) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error ) {
                UIImage *fetchedImage = [UIImage imageWithData:data];
                if (fetchedImage) {
                    [imageCache setObject:fetchedImage forKey:url];
                    completionBlock(YES,YES,fetchedImage);
                }
            } else {
                completionBlock(NO,YES,nil);
            }
        }];
        [task resume];
    } else {
        completionBlock(YES,NO,parseImg);
    }
}

- (void)fetchFavoritesWithCompletionBlock:(void (^)(BOOL succeeded, NSMutableArray *array))completionBlock
{
    if (![PFUser currentUser]) {
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            self.favUsers = [objects mutableCopy];
            [PFObject pinAllInBackground:self.favUsers];
            completionBlock(YES,self.favUsers);
        } else {
            [self fetchFavoritesLocallyWithCompletionBlock:^(BOOL succeeded, NSMutableArray *array) {
                completionBlock(YES,array);
            }];
        }
    }];
}

- (void)fetchFavoritesLocallyWithCompletionBlock:(void (^)(BOOL succeeded, NSMutableArray *array))completionBlock
{
    if (![PFUser currentUser]) return;

    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            self.favUsers = [objects mutableCopy];
            completionBlock(YES,self.favUsers);
        } else {
            completionBlock(NO,nil);
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
