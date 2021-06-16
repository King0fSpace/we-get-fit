//
//  FollowersListViewController.h
//  We Get Fit
//
//  Created by Long Le on 7/19/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "FriendsListViewController.h"
#import "Utility.h"
#import "MeViewController.h"

@interface FollowersListViewController : FriendsListViewController

@property UIButton *followButton;
@property NSMutableArray *listsArray;
@property PFObject *userObject;

-(void)addFriendButtonTapped:(UIButton*)sender;


@end
