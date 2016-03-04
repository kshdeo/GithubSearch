//
//  SearchCell.m
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setNeedsLayout
{
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 5.0;
}

@end
