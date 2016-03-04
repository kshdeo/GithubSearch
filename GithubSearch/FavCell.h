//
//  FavCell.h
//  Github Search
//
//  Created by Kshitij-Deo on 24/01/16.
//

#import <UIKit/UIKit.h>

@interface FavCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
