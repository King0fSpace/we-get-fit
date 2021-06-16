//
//  NotificationsView.m
//  We Get Fit
//
//  Created by Long Le on 4/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "NotificationsView.h"

@implementation NotificationsView

@synthesize friendsArray;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    friendsArray = [[NSMutableArray alloc] init];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    //Set title for navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"Workouts";
    [label sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count)
    {
        return 80;
        
    }
    else
    {
        return 44.0f;
    }
}

- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:20];
        return query;
    }
    
    //Query returns all activities where you are the receiver
    PFQuery *query = [PFQuery queryWithClassName:@"Workouts"];
    [query orderByDescending:@"WorkoutDate"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyNetworkElseCache];
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

- (NotificationsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog (@"indexPath = %@", indexPath);
    NSLog (@"cellForRowAtIndexPath in NotificationsView");
    
    static NSString *CellIdentifier = @"Cell";
    
    NSLog (@"notificationsView objects count = %li", [[self objects] count]);
    
    if (indexPath.row == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        NotificationsCell *cell = (NotificationsCell *)[self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
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
        
        NotificationsCell *cell = (NotificationsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[NotificationsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            //Add a label stating what workout this person did and for how long
            cell.notificationTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 - 65, cell.frame.size.height/2 - 10, 225, 35)];
            cell.notificationTextLabel.numberOfLines = 0;
            [cell.notificationTextLabel setTextColor:[UIColor darkGrayColor]];
            [cell.notificationTextLabel setBackgroundColor:[UIColor clearColor]];
            [cell.notificationTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
            [cell addSubview:cell.notificationTextLabel];

            //Add elapsed time since occurance
            cell.elapsedTimeSincePost = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 + 56, cell.frame.size.height/2 + 39, 100, 20)];
            [cell.elapsedTimeSincePost setTextColor:[UIColor lightGrayColor]];
            [cell.elapsedTimeSincePost setBackgroundColor:[UIColor clearColor]];
            [cell.elapsedTimeSincePost setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
            [cell addSubview:cell.elapsedTimeSincePost];
            cell.elapsedTimeSincePost.textAlignment = NSTextAlignmentRight;
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

        /*
        if ([PFUser currentUser])
        {
            NSLog (@"workout query!!!!!");
            
            //Query all your friends and following and save them to a local array for reference for when the Notifications view decides which peoples workouts to display
            
            PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [query whereKey:@"saved_to_list" equalTo:@"Following"];
            [query whereKey:@"toUser" notEqualTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *friendActivities, NSError *error)
            {
                if (!error)
                {
                    [friendsArray removeAllObjects];
                    
                    for (PFObject *object in friendActivities)
                    {
                        [friendsArray addObject:object[@"toUser"]];
                    }
                    
                    //Add yourself to the friends array
                    [friendsArray addObject: [PFUser currentUser]];
                    
                    for (PFObject *user in friendsArray)
                    {
                        NSLog (@"friendsArray user = %@", user);
                        NSLog (@"friendsArray count = %li", (unsigned long)[friendsArray count]);
                    }
                }
                
                //Fetch the user corresponding with the object (activity) in the fromUser field
                PFUser *userFetch = object[@"user"];
                [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
                    PFObject *user = userFetched;
                   // NSLog (@"user2 = %@", user);
                    
                    for (PFUser *friendsArrayUser in friendsArray)
                    {
                        NSLog (@"user.objectId = %@", user.objectId);
                        NSLog (@"friendsArrayUser.objectId = %@", friendsArrayUser.objectId);

                        if ([friendsArrayUser.objectId isEqualToString:user.objectId])
                        {
                            NSLog (@"A match!");

                            NSString *firstName = [user objectForKey:@"first_name"];
                            NSLog (@"first_name4 = %@", firstName);
                            
                            NSString *gender = [user objectForKey:@"gender"];
                            NSLog (@"gender4 = %@", gender);
                            
                            NSNumber *age = [user objectForKey:@"age"];
                            //NSLog(@"age = %@", user);
                            
                            NSString *workoutType = [object objectForKey:@"type"];
                            float workoutDurationInMinutes = [[object objectForKey:@"Duration"] floatValue]/60;
                            long int caloriesBurnedInt = [[object objectForKey:@"CaloriesBurned"] integerValue];
                            
                            
                            //Add user photo to cell
                            cell.imageView.file = [user objectForKey:@"profile_photo"];
                            //Add user photo to cell
                            [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                                
                                if (!error)
                                {
                                    //Image rounding, resizing, and positioning is done in NotificationsCell
                                    
                                }
                            }];
                            
                            //Configure notification text label
                            cell.notificationTextLabel.text = [NSString stringWithFormat:@"%@ workout for %.0f minutes burning %ld calories", workoutType, workoutDurationInMinutes, caloriesBurnedInt];
                            
                            //Configure elapsedTimeSincePost text label
                            NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:object[@"WorkoutDate"]];
                            cell.elapsedTimeSincePost.text = TimeElapsed(seconds);
                            cell.elapsedTimeSincePost.textAlignment = NSTextAlignmentRight;
                        }
                    }
                }];
            }];
        }
        */
        
        PFUser *userFetch = object[@"user"];
        [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
            PFObject *user = userFetched;
            // NSLog (@"user2 = %@", user);
            
            NSString *firstName = [user objectForKey:@"first_name"];
            NSLog (@"first_name4 = %@", firstName);
            
            NSString *gender = [user objectForKey:@"gender"];
            NSLog (@"gender4 = %@", gender);
            
            NSNumber *age = [user objectForKey:@"age"];
            //NSLog(@"age = %@", user);
            
            NSString *workoutType = [object objectForKey:@"type"];
            float workoutDurationInMinutes = [[object objectForKey:@"Duration"] floatValue]/60;
            long int caloriesBurnedInt = [[object objectForKey:@"CaloriesBurned"] integerValue];
            
            
            //Add user photo to cell
            cell.imageView.file = [user objectForKey:@"profile_photo"];
            //Add user photo to cell
            [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                
                if (!error)
                {
                    //Image rounding, resizing, and positioning is done in NotificationsCell
                    
                }
            }];
            
            //Configure notification text label
            cell.notificationTextLabel.text = [NSString stringWithFormat:@"%@ workout for %.0f minutes burning %ld calories", workoutType, workoutDurationInMinutes, caloriesBurnedInt];
            
            //Configure elapsedTimeSincePost text label
            NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:object[@"WorkoutDate"]];
            cell.elapsedTimeSincePost.text = TimeElapsed(seconds);
            cell.elapsedTimeSincePost.textAlignment = NSTextAlignmentRight;
        }];
        
        return cell;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
