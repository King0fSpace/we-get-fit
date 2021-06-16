//
//  FriendsListCell.h
//  We Get Fit
//
//  Created by Long Le on 7/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface FriendsListCell : PFTableViewCell

@property UILabel *fullNameLabel;
@property UILabel *usernameLabel;
@property UIButton *followButton;
@property (nonatomic, strong) UIButton *photoButton;

@end
