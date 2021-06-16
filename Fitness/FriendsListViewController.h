//
//  FriendsListViewController.h
//  We Get Fit
//
//  Created by Long Le on 7/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"
#import "friendsListCell.h"

@interface FriendsListViewController : PFQueryTableViewController

@property PFObject *userObject;


@end
