//
//  FriendsListViewController.m
//  We Get Fit
//
//  Created by Long Le on 7/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "FriendsListViewController.h"
#import "MeViewController.h"


@interface FriendsListViewController ()

@end

@implementation FriendsListViewController

@synthesize userObject;

- (void)viewDidLoad {
    
    NSLog (@"FriendsListViewController viewDidLoad called!");
    
    [super viewDidLoad];
    
    if (userObject == nil)
        if ([PFUser currentUser])
            userObject = [PFUser currentUser];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.contentInset = inset;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Set title for navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.tabBarController.navigationItem.titleView = label;
    label.text = @"Friends";
    [label sizeToFit];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count)
    {
        return 58;
        
    }
    else
    {
        return 44.0f;
    }
}

-(PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:@"fromUser" equalTo:userObject];
    [query whereKey:@"toUser" notEqualTo:userObject];
    [query whereKey:@"FriendStatus" equalTo: @"Friends"];
    [query whereKey:@"saved_to_list" equalTo:@"Following"];
    
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
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

- (FriendsListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog (@"indexPath = %@", indexPath);
    NSLog (@"cellForRowAtIndexPath in NotificationsView");
    
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
        PFUser *userFetch = object[@"toUser"];
        [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
            PFObject *user = userFetched;
            NSLog (@"user2 = %@", user);
            
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
            
            //Add photoButton that brings up user profile when tapped
            [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.photoButton.tag = indexPath.row;
            
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
        }];
        
        return cell;
    }
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSLog (@"HomeView didSelectRowAtIndexPath called!");
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    PFUser *userFetch = object[@"toUser"];
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

- (void)didTapOnPhotoAction:(UIButton *)sender {
    
    NSLog (@"User's photo tapped");
    
    PFObject *object = [self.objects objectAtIndex:sender.tag];
    
    PFUser *userFetch = object[@"toUser"];
    [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
        PFObject *user = userFetched;
        NSLog (@"user2 = %@", user);
        
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
