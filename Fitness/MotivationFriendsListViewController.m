//
//  MotivationFriendsListViewController.m
//  We Get Fit
//
//  Created by Long Le on 9/24/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "MotivationFriendsListViewController.h"

@interface MotivationFriendsListViewController ()

@end

@implementation MotivationFriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    super.todaysActivityLabel.text = [NSString stringWithFormat: @"Pick Someone"];
    
    //Add title that reads 'Pick Someone'
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    label.text = @"Pick Someone";
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    //Remove all UISegmentedControl and UIBarButtonItem from current UINavigationController
    for (UIView *view in self.navigationController.navigationBar.subviews)
    {
        if ([view isKindOfClass:[UISegmentedControl class]] || [view isKindOfClass:[UIBarButtonItem class]])
        {
            [view removeFromSuperview];
        }
    }
    
    //Make the inherited 'Search' button blank and useless
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Overloading 'queryForTable' method in 'UsersViewController' class in order to limit query
- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable in MotivationFriendsListViewController run");

    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:100];
        return query;
    }
    
    //This query returns all those who sent you a friend request
    /*
     PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
     [query whereKey:kPAPActivityTypeKey equalTo:@"friend"];
     [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
     query.cachePolicy = kPFCachePolicyNetworkOnly;
     query.limit = 1000;
     */
    
    //Pull text value from AppDelegate's member variable
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Set homeCurrentListSelectedString
    /*
     homeCurrentListSelectedString = [listsArray objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"listDisplayedTextField"]];
     if (homeCurrentListSelectedString == nil)
     homeCurrentListSelectedString = appDelegate.homeCurrentListSelectedString;
     
     NSLog (@"homeCurrentListSelectedString = %@", homeCurrentListSelectedString);
     */
    
    PFQuery *query;
    
    if ([PFUser currentUser])
    {
        query = [PFQuery queryWithClassName:@"Activity"];
        [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [query whereKey:@"saved_to_list" equalTo:@"Following"];
        [query whereKey:@"FriendStatus" equalTo: @"Friends"];
        [query whereKey:@"toUser" notEqualTo:[PFUser currentUser]];
    }
        
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

-(void)sendPushNotification: (long int)atIndexArg
{
    PFObject *activityObject = [[self objects] objectAtIndex:atIndexArg];
    PFUser *selectedUser = activityObject[@"toUser"];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:selectedUser];
    
    if ([PFUser currentUser])
    {
        NSString *notificationMessage = [NSString stringWithFormat:@"%@ just thanked you for motivating them to work out today!", [PFUser currentUser][@"username"]];
    
        // Send push notification to user
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              notificationMessage, @"alert",
                              @"Increment", @"badge",
                              @"default", @"sound",
                              nil];
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setData:data];
        [push sendPushInBackground];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSLog (@"MotivationFriendsListViewController didSelectRowAtIndexPath called!");
    long int indexPathInt = indexPath.row;
    NSLog (@"indexPathInt = %li", indexPathInt);
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Great!"
                                                                   message:@"Sending them a push notification now"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   
                                   [self sendPushNotification:indexPathInt];
                               }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapOnPhotoAction:(UIButton *)sender
{    
    NSLog (@"MotivationFriendsListView didTapOnPhotoAction called!");
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [super.tableView indexPathForCell:cell];
    long int indexPathInt = indexPath.row;

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Great!"
                                                                   message:@"Sending them a push notification now"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   
                                   [self sendPushNotification:indexPathInt];
                               }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
