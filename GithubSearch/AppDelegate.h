//
//  AppDelegate.h
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *favUsers;

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, BOOL isNew, UIImage *image))completionBlock;
- (void)fetchFavoritesWithCompletionBlock:(void (^)(BOOL succeeded, NSMutableArray *array))completionBlock;

@end

