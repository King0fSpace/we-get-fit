//
//  FollowingListViewController.m
//  We Get Fit
//
//  Created by Long Le on 7/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "FollowingListViewController.h"

@implementation FollowingListViewController

@synthesize userObject;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (userObject == nil)
        if ([PFUser currentUser])
            userObject = [PFUser currentUser];
}

- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:@"fromUser" equalTo:userObject];
    [query whereKey:@"toUser" notEqualTo:userObject];
    [query whereKey:@"saved_to_list" equalTo:@"Following"];
    [query whereKey:@"FriendStatus" notEqualTo: @"Friends"];
    
    
    // A pull-to-refresh should always trigger a network request.
    //[query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Photo"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */
    
    return query;
}


@end
