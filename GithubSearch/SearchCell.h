//
//  SearchCell.h
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *usenameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end