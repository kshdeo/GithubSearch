//
//  UserViewController.h
//  Github Search
//
//  Created by Kshitij-Deo on 24/01/16.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UITableViewController

@property (nonatomic, weak) NSString *login;
@property (nonatomic, strong) PFObject *pObject;

@end
