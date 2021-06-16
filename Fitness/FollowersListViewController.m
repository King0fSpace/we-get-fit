//
//  FollowersListViewController.m
//  We Get Fit
//
//  Created by Long Le on 7/19/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "FollowersListViewController.h"

@interface FollowersListViewController ()

@end

@implementation FollowersListViewController

@synthesize followButton;
@synthesize listsArray;
@synthesize userObject;

- (void)viewDidLoad {
    
    NSLog (@"FollowersListViewController viewDidLoad called!");
    
    [super viewDidLoad];
    
    listsArray = [[NSMutableArray alloc] init];
    [listsArray addObject:@"Following"];
    [listsArray addObject:@"Friends"];
    [listsArray addObject:@"Top Rated"];
    
    if (userObject == nil)
        if ([PFUser currentUser])
            userObject = [PFUser currentUser];
}

- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:@"toUser" equalTo:userObject];
    [query whereKey:@"fromUser" notEqualTo:userObject];
    [query whereKey:@"saved_to_list" equalTo:@"Following"];

    
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

-(void)userObjectSavedToList:(NSInteger)row
{
    NSLog (@"userObjectSavedToList called!");
    
    PFObject *userObject = [self.objects objectAtIndex:row];
    
    if ([PFUser currentUser])
    {
        //Delete any activity which equates the userObject to any sort of list before you add them to a new one
        PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [query whereKey:kPAPActivityToUserKey equalTo:userObject];
        [query whereKeyExists:@"saved_to_list"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *friendActivities, NSError *error) {
            
            // While normally there should only be one saved_to_list activity returned, we can't guarantee that.
            for (PFObject *friendActivity in friendActivities) {
                [friendActivity delete];
            }
            
            //Now save the new list name to the save_to_list key
            NSString *listNameString = [listsArray objectAtIndex:row];
            NSLog (@"string being saved to saved_to_list = %@", [listsArray objectAtIndex:row]);
            
            PFObject *setUserToListActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
            [setUserToListActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
            [setUserToListActivity setObject:userObject forKey:kPAPActivityToUserKey];
            [setUserToListActivity setObject:listNameString forKey:@"saved_to_list"];
            
            PFACL *savedToListACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [savedToListACL setPublicReadAccess:YES];
            [savedToListACL setPublicWriteAccess:YES];
            setUserToListActivity.ACL = savedToListACL;
            
            [setUserToListActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog (@"User Saved to List Successful!");
                }
                else
                {
                    NSLog (@"User Saved to List NOT Successful");
                }
            }];
            [[Cache sharedCache] setSavedToList:listNameString user:[PFUser currentUser]];
        }];
    }
}

/*
-(void)addFollowButton:(PFUser*)userObjectArg cell:(FriendsListCell*)cellArg
{
    NSLog (@"addFollowButton in FollowersListViewController called!");
    
    followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [followButton addTarget:self action:@selector(addFriendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [followButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    followButton.frame = CGRectMake(cellArg.frame.size.width/2 + cellArg.frame.size.width/4 - 10, cellArg.frame.size.height/3 - 5, 75, 50);
    [followButton sizeToFit];
    followButton.selected = YES;
    [cellArg addSubview:followButton];
}
 */

-(void)addFriendButtonTapped:(UIButton*)sender
{
    //Get reference to button
    UIButton *button = (UIButton*)sender;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSInteger row = indexPath.row;
    
    //Get other user by getting the activityObject in the cell's row first
    PFObject *object = [self.objects objectAtIndex:row];
    
    PFUser *userFetched = object[@"fromUser"];
    [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
     {
         if (![button isSelected]) {
             // Unfollow
             NSLog (@"Unfollowing user");
             [button setTitle:@"Add Friend" forState:UIControlStateSelected];
             button.selected = YES;
             [Utility unfollowUserEventually:userFetched];
         }
         else
         {
            // Follow
            NSLog (@"Following user");
            [button setTitle:@"Unfriend" forState:UIControlStateNormal];
            button.selected = NO;
            [Utility followUserEventually:userFetched block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                } else {
                    button.selected = NO;
                }
                NSInteger number = 0;
                //Add user to the 'following' list by default. The argument '0' refers to the 'following' string object in listsArray
                [self userObjectSavedToList:number];
            }];
         }
    }];
}

//This method overrides 'FrinedsListViewController's' method to grab the 'fromUser' field instead of the 'toUser'
- (FriendsListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog (@"indexPath = %@", indexPath);
    NSLog (@"cellForRowAtIndexPath in FollowerslistViewController");
    
    NSLog (@"[self objects] = %lu", (unsigned long)[[self objects] count]);
    
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.row == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        FriendsListCell *cell = (FriendsListCell *)[self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        cell.clipsToBounds = YES;
        
        return cell;
        
    } else {
        
        FriendsListCell *cell = (FriendsListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            
            cell = [[FriendsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        //Remove stuff before you reuse them here
        //Remove 'Friend Request!' label before reuse
        [cell.fullNameLabel removeFromSuperview];
        [cell.usernameLabel removeFromSuperview];
        
        //Fetch the user corresponding with the object (activity) in the fromUser field
        PFUser *userFetch = object[@"fromUser"];
        [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
            PFObject *user = userFetched;
            //NSLog (@"user2 = %@", user);
            
            NSString *fullName = [user objectForKey:@"first_name"];
            NSLog (@"fullName = %@", fullName);
            
            NSString *username = [user objectForKey:@"username"];
            NSLog (@"username = %@", username);
            
            //Add user photo to cell
            cell.imageView.file = [user objectForKey:@"profile_photo"];
            //Add user photo to cell
            [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                
                if (!error) {
                    
                    //Image rounding, resizing, and positioning is done in FriendsListCell
                    
                }
            }];
            
            /*
            //Configure 'followButton'
            if (cell.followButton == nil && userObject == [PFUser currentUser])
            {
                cell.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [cell.followButton setTitle:@"Add Friend" forState:UIControlStateNormal];
                [cell.followButton addTarget:self action:@selector(addFriendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                cell.followButton.frame = CGRectMake(cell.frame.size.width/2 + cell.frame.size.width/4 - 10, cell.frame.size.height/3 - 5, 75, 50);
                [cell.followButton sizeToFit];
                cell.followButton.selected = YES;
                [cell.contentView addSubview:cell.followButton];
            }
            */
            //Set the full name Label
            cell.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 - 90, cell.frame.size.height/2 - 23, 300, 20)];
            cell.usernameLabel.text = [NSString stringWithFormat:@"%@", username];
            [cell.usernameLabel setTextColor:[UIColor blackColor]];
            [cell.usernameLabel setBackgroundColor:[UIColor clearColor]];
            [cell.usernameLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
            [cell addSubview:cell.usernameLabel];
            
            //Set the username Label
            cell.fullNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.usernameLabel.frame.origin.x, cell.usernameLabel.frame.origin.y + 20, 300, 20)];
            cell.fullNameLabel.text = [NSString stringWithFormat:@"%@", fullName];
            [cell.fullNameLabel setTextColor:[UIColor grayColor]];
            [cell.fullNameLabel setBackgroundColor:[UIColor clearColor]];
            [cell.fullNameLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 12.0f]];
            [cell addSubview:cell.fullNameLabel];
            
            //Add 'Add Friend' button to the right of the cell
        }];
        
        return cell;
    }
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSLog (@"HomeView didSelectRowAtIndexPath called!");
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    PFUser *userFetch = object[@"fromUser"];
    [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
        PFObject *user = userFetched;
        // NSLog (@"user2 = %@", user);
        
        if (user) {
            
            MeViewController *viewController = [[MeViewController alloc] init];
            viewController.userObject = user;
            viewController.viewOffset = 460;
            viewController.currentViewIsNonRootView = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
