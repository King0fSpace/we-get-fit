//
//  WorldChallengesViewController.m
//  We Get Fit
//
//  Created by Long Le on 12/12/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "WorldChallengesViewController.h"

@interface WorldChallengesViewController ()

@end

@implementation WorldChallengesViewController


@synthesize worldChallengeWinnersArray;


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    
    worldChallengeWinnersArray = [[NSMutableArray alloc] init];
    
    //Add title to the top of the screen (navigational controller)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    label.text = [NSString stringWithFormat:@"World"];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Rules" style:UIBarButtonItemStylePlain target:self action:@selector(showRulesView:)];
    
    NSInteger viewOffset = [[UIScreen mainScreen] bounds].size.width/3 + 2*HEADER_THICKNESS;
    
    //Moves the tableView down so that the NavigationBar does not overlap it
    UIEdgeInsets inset = UIEdgeInsetsMake(viewOffset, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    //Add Friends > right bar button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Friends>" style:UIBarButtonItemStyleBordered target:self action:@selector(showFriendsChallengeView:)];
    
    [self addLastWeeksWinnersToTopOfView];
    [self addGrayLastWeeksWinnersBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSLog (@"WorldChallengesViewController viewDidAppear");
    
    [self loadObjects];
    
    [self addLastWeeksWinnersToTopOfView];
    [self addGrayLastWeeksWinnersBar];
}

-(void)showFriendsChallengeView: (UIButton*)sender
{
    FriendsChallengesViewController *viewController = [[FriendsChallengesViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)addGrayLastWeeksWinnersBar
{
    //Add 'Last Week's Winners' header above the photos of the winners
    UILabel *lastWeeksWinnersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -[[UIScreen mainScreen] bounds].size.width/3 - 2*HEADER_THICKNESS, [[UIScreen mainScreen] bounds].size.width, HEADER_THICKNESS - 5)];
    lastWeeksWinnersLabel.textAlignment =  UITextAlignmentCenter;
    lastWeeksWinnersLabel.textColor = [UIColor whiteColor];
    lastWeeksWinnersLabel.backgroundColor = [UIColor lightGrayColor];
    lastWeeksWinnersLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    lastWeeksWinnersLabel.text = [NSString stringWithFormat: @"All Hail Last Week's Winners"];
    [self.view addSubview:lastWeeksWinnersLabel];
}

- (void)didTapWinnerPhotoAction:(UIGestureRecognizer*)gestureView
{
    NSLog (@"WorldChllangesViewController didTapWinnerPhotoAction method called!");
    
    PFObject *generalChallengeWinnerUser = [worldChallengeWinnersArray objectAtIndex:gestureView.view.tag];
    NSString *winnerObjectId = generalChallengeWinnerUser[@"userObjectId"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:winnerObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if ([objects lastObject])
        {
            
             NSLog (@"user = %@", [objects lastObject]);
            
            MeViewController *viewController = [[MeViewController alloc] init];
            viewController.userObject = [objects lastObject];
            viewController.viewOffset = 460;
            viewController.currentViewIsNonRootView = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

-(void)queryForTop3Winners: (void (^)(double, NSError *))completionHandler
{
    for (UIView *subview in [self.view subviews])
    {
        if ([subview isKindOfClass:[UIImage class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    //Make sure the user's updatedAt time is greater than this number
    PFQuery *query = [PFQuery queryWithClassName:@"GeneralChallengeWinners"];
    [query orderByDescending:@"ChallengeDay6ListRankingScore"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *winnersArray, NSError *error)
     {
         if (!error)
         {
             [worldChallengeWinnersArray addObjectsFromArray:winnersArray];
             
             for (PFObject *winnerObject in winnersArray)
             {
                 NSString *winnerObjectId = winnerObject[@"userObjectId"];
                 
                 NSLog (@"winnerObjectId = %@", winnerObjectId);
                 
                 PFQuery *query = [PFUser query];
                 [query whereKey:@"objectId" equalTo:winnerObjectId];
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                  {
                      if (!error)
                      {
                          for (PFObject *object in objects)
                          {
                              [object[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                               {
                                   UIImage *image = [UIImage imageWithData:data];
                                   UIImageView *uploaderPhoto = [[UIImageView alloc] initWithImage:image];
                                   uploaderPhoto.frame = CGRectMake([winnersArray indexOfObject:winnerObject]*[[UIScreen mainScreen] bounds].size.width/3, -[[UIScreen mainScreen] bounds].size.width/3 - HEADER_THICKNESS -5, [[UIScreen mainScreen] bounds].size.width/3, [[UIScreen mainScreen] bounds].size.width/3);
                                   uploaderPhoto.tag = [winnersArray indexOfObject:winnerObject];
                                   [self.view addSubview:uploaderPhoto];
                                   
                                   //Add gesture recognizer to image that will allow user to tap ont he photo and navigate to the winner's page
                                   UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWinnerPhotoAction:)];
                                   singleTap.numberOfTapsRequired = 1;
                                   [uploaderPhoto setUserInteractionEnabled:YES];
                                   [uploaderPhoto addGestureRecognizer:singleTap];
                                   
                                   /*
                                    //Add 'footer' to bottom of image
                                    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(uploaderPhoto.frame.origin.x, -2*HEADER_THICKNESS + 9, uploaderPhoto.frame.size.width, HEADER_THICKNESS - 9)];
                                    footerLabel.textAlignment =  UITextAlignmentCenter;
                                    footerLabel.textColor = [UIColor lightGrayColor];
                                    footerLabel.font = [UIFont fontWithName:@"San Francisco" size:(14.0)];
                                    footerLabel.text = object[@"username"];
                                    footerLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
                                    [self.view addSubview:footerLabel];
                                    */
                               }];
                          }
                      }
                  }];
             }
             
             completionHandler(YES, nil);
         }
     }];
}

-(void) addLastWeeksWinnersToTopOfView
{
    //Get the array of the 3 winners
    [self queryForTop3Winners:^(double done, NSError *error)
     {
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    NSLog (@"ChallengesViewController queryForTable called!");
    
    
    if (![PFUser currentUser])
    {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:25];
        return query;
    }
    
    PFQuery *query;
    
    //Show friends only since we're removing the segment control
    query = [PFUser query];
    [query whereKeyExists:@"NumberOfStepsToday"];

    
     //Used to help NSDates at midnight
     NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
     NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
     //today at midnight
     NSDate *todayAtMidnight = [NSDate date];
     todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
     
     //get NSDate for two days ago at midnight
     NSCalendar *cal = [NSCalendar currentCalendar];
     NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
     [components setHour:-48];
     [components setMinute:0];
     [components setSecond:0];
     NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
     twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    //Make sure the user's updatedAt time is greater than this number
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:twoDaysAgoAtMidnight];
    
    if ([self dayOfTheWeek] == 1)
        [query orderByDescending:@"ChallengeDay1ListRankingScore"];
    else if ([self dayOfTheWeek] == 2)
        [query orderByDescending:@"ChallengeDay2ListRankingScore"];
    else if ([self dayOfTheWeek] == 3)
        [query orderByDescending:@"ChallengeDay3ListRankingScore"];
    else if ([self dayOfTheWeek] == 4)
        [query orderByDescending:@"ChallengeDay4ListRankingScore"];
    else if ([self dayOfTheWeek] == 5)
        [query orderByDescending:@"ChallengeDay5ListRankingScore"];
    else
        [query orderByDescending:@"ChallengeDay6ListRankingScore"];
    
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

- (PersonHealthStatsQuickViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"Cell";
    
    if ([object.objectId isEqualToString:[PFUser currentUser].objectId])
    {
        NSLog (@"userAlreadyShownInList!");
        super.userAlreadyShownInList = YES;
    }
    
    if (indexPath.row == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        PersonHealthStatsQuickViewCell *cell = (PersonHealthStatsQuickViewCell *)[self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
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
        
    }
    else
    {
        if (super.userAlreadyShownInList == NO)
        {
            if (indexPath.row == self.objects.count - 1 && self.paginationEnabled)
            {
                object = [PFUser currentUser];
            }
        }
        
        PersonHealthStatsQuickViewCell *cell = (PersonHealthStatsQuickViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[PersonHealthStatsQuickViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            //Add gray square to the left of profile photo with the number of the row its located in
            cell.squareNumberView = [[UIView alloc] initWithFrame:CGRectMake(0,0,27,cell.frame.size.height + 15)];
            [cell addSubview: cell.squareNumberView];
            
            //Add text label to gray square that states the number of the row its in
            cell.squareNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.squareNumberView.center.x, cell.squareNumberView.center.y - cell.squareNumberLabel.frame.size.height, 0, 0)];
            [cell addSubview:cell.squareNumberLabel];
            
            //Add blueCircleView
            cell.blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
            [cell addSubview: cell.blueCircleView];
            
            //Add blue circle small steps label
            cell.blueCircleSmallStepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y - cell.blueCircleView.frame.size.height, 0, 0)];
            [cell addSubview: cell.blueCircleSmallStepsLabel];
            
            //Add blueCircle numberOfStepsToday label
            cell.blueCircleNumOfStepsTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.blueCircleNumOfStepsTodayLabel];
            
            //Add redCircleView
            cell.redCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.redCircleView];
            
            //Add small 'min' label under the distance run label
            cell.redCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.redCircleView.center.x, cell.redCircleView.center.y - cell.redCircleView.frame.size.height, 0, 0)];
            [cell addSubview:cell.redCircleSmallMinLabel];
            
            //Add number of steps inside the red circle
            cell.redCircleMinOfExerciseTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
            [cell addSubview:cell.redCircleMinOfExerciseTodayLabel];
            
            //Add orangeCircleView
            cell.orangeCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.orangeCircleView];
            
            //Add small 'cal' label under the distance run label
            cell.orangeCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y - cell.orangeCircleView.frame.size.height, 0, 0)];
            [cell addSubview:cell.orangeCircleSmallMinLabel];
            
            //Add calories burned inside the orange circle
            cell.orangeCircleNumOfCaloriesTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
            [cell addSubview:cell.orangeCircleNumOfCaloriesTodayLabel];
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
        
        //Change color of every other cell
        if (indexPath.row % 2) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
        }
        //Highlight cell yellow if the cell belongs to the user
        if ([object.objectId isEqualToString:[PFUser currentUser].objectId])
        {
            cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:238.0/255.0 green:221.0/255.0 blue:130.0/255.0 alpha:1];
        }
        
        PFObject *userFetched = object;
        [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
         {
             NSLog (@"Populating HomeView cell in list");
             
             PFObject *user = userFetched;
             // NSLog (@"user2 = %@", user);
             
             NSString *firstName = [user objectForKey:@"first_name"];
             NSLog (@"first_name4 = %@", firstName);
             
             NSString *gender = [user objectForKey:@"gender"];
             NSLog (@"gender4 = %@", gender);
             
             NSNumber *age = [user objectForKey:@"age"];
             //NSLog(@"age = %@", user);
             
             NSString *threeLetterCountryCodeString = [user objectForKey:@"threeLetterCountryCode"];
             
             NSNumber *moveGoalNSNum = [user objectForKey:@"moveGoal"];
             double moveGoal = [moveGoalNSNum doubleValue];
             NSLog (@"HomeView moveGoal = %f", moveGoal);
             if (moveGoal== 0)
                 moveGoal = 500;
             
             //Add user photo to cell
             cell.imageView.file = [user objectForKey:@"profile_photo"];
             //Add user photo to cell
             [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                 
                 if (!error)
                 {
                     //Image rounding, resizing, and positioning is done in FriendsViewPhotoCell
                     
                     //Add photo footer
                     //[super addPhotoFooter:cell threeLetterCountryCode: threeLetterCountryCodeString];
                 }
             }];
             
             //Add photoButton that brings up user profile when tapped
             [cell.photoButton addTarget:self action:@selector(didTapOnCellPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
             cell.photoButton.tag = indexPath.row;
             
             //Remove friendRequestLabel, accept button, and reject buttons if they're still there
             if (cell.friendRequestLabel)
                 [cell.friendRequestLabel removeFromSuperview];
             if (cell.acceptButton)
                 [cell.acceptButton removeFromSuperview];
             if (cell.rejectButton)
                 [cell.rejectButton removeFromSuperview];
             
             //Configure sqauare number view
             cell.squareNumberView.center = CGPointMake(15, 30);
             cell.squareNumberView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
             cell.squareNumberView.tag = 2;
             [cell.squareNumberView sizeToFit];
             
             //Configure square number label
             cell.squareNumberLabel.text = [NSString stringWithFormat: @"%li", (long)indexPath.row + 1];
             cell.squareNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
             cell.squareNumberLabel.textColor = [UIColor grayColor];
             cell.squareNumberLabel.tag = 2;
             //Resize the frame of the UILabel to fit the text
             [cell.squareNumberLabel sizeToFit];
             cell.squareNumberLabel.center = CGPointMake(cell.squareNumberView.center.x, cell.squareNumberView.center.y);
             
             if ([object.objectId isEqualToString:[PFUser currentUser].objectId])
             {
                 cell.squareNumberLabel.text = [NSString stringWithFormat: @"--"];
                 
                 HealthMethods *healthMethodsSubClass = [[HealthMethods alloc] init];
                 [healthMethodsSubClass queryTotalNumberOfWorldChallengers:^(double done, int yourRank, int totalChallengers, NSError *error)
                  {
                      cell.squareNumberLabel.text = [NSString stringWithFormat: @"%i", yourRank];
                  }];
             }
             
             //Add exercise metrics to the right of picture
             //Determine blueCircle size
             float blueCircleHeightAndWidth = 0.0;
             if ([self numOfSteps:user] < 10)
             {
                 blueCircleHeightAndWidth = 15*2.3;
             }
             else if ([self numOfSteps:user] >= 10 && [self numOfSteps:user] < 999)
             {
                 blueCircleHeightAndWidth = 15*2.3;
             }
             else if ([self numOfSteps:user] >= 999 && [self numOfSteps:user] < 5000)
             {
                 blueCircleHeightAndWidth = 15*3.0;
             }
             else if ([self numOfSteps:user] >= 5000 && [self numOfSteps:user] < 10000)
             {
                 blueCircleHeightAndWidth = 15*3.7;
             }
             else if ([self numOfSteps:user] >= 10000)
             {
                 blueCircleHeightAndWidth = 15*5.0;
             }
             
             //configure blue colored circle
             cell.blueCircleView.frame = CGRectMake(0, 0, blueCircleHeightAndWidth, blueCircleHeightAndWidth);
             cell.blueCircleView.center = CGPointMake(140, 30);
             cell.blueCircleView.alpha = 0.9;
             cell.blueCircleView.layer.cornerRadius = blueCircleHeightAndWidth/2;
             cell.blueCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:164/255.0 alpha:0.9];
             cell.blueCircleView.tag = 2;
             [cell.blueCircleView sizeToFit];
             
             //configure small blue 'Steps' label under the number of steps
             cell.blueCircleSmallStepsLabel.text = @"steps";
             cell.blueCircleSmallStepsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
             cell.blueCircleSmallStepsLabel.textColor = [UIColor whiteColor];
             cell.blueCircleSmallStepsLabel.tag = 2;
             //Resize the frame of the UILabel to fit the text
             [cell.blueCircleSmallStepsLabel sizeToFit];
             cell.blueCircleSmallStepsLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y + 10);
             
             //configure number of steps inside the blue circle
             cell.blueCircleNumOfStepsTodayLabel.text = [NSString stringWithFormat: @"%i", [self numOfSteps:user]];
             cell.blueCircleNumOfStepsTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
             cell.blueCircleNumOfStepsTodayLabel.textColor = [UIColor whiteColor];
             cell.blueCircleNumOfStepsTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
             cell.blueCircleNumOfStepsTodayLabel.tag = 2;
             [cell.blueCircleNumOfStepsTodayLabel sizeToFit];
             cell.blueCircleNumOfStepsTodayLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y);
             
             
             //Determine redCircle size
             float redCircleHeightAndWidth = 0.0;
             if ([self minutesOfExercise:user] < 1)
             {
                 redCircleHeightAndWidth = 15*2.3;
             }
             else if ([self minutesOfExercise:user] >= 1 && [self minutesOfExercise:user] < 20)
             {
                 redCircleHeightAndWidth = 15*2.3;
             }
             else if ([self minutesOfExercise:user] >= 20 && [self minutesOfExercise:user] < 40)
             {
                 redCircleHeightAndWidth = 15*3.0;
             }
             else if ([self minutesOfExercise:user] >= 40 && [self minutesOfExercise:user] < 60)
             {
                 redCircleHeightAndWidth = 15*3.7;
             }
             else if ([self minutesOfExercise:user] >= 60)
             {
                 redCircleHeightAndWidth = 15*5.0;
             }
             
             
             //configure red colored circle
             cell.redCircleView.frame = CGRectMake(0, 0, redCircleHeightAndWidth,redCircleHeightAndWidth);
             cell.redCircleView.center = CGPointMake(208, 30);
             cell.redCircleView.alpha = 0.9;
             cell.redCircleView.layer.cornerRadius = redCircleHeightAndWidth/2;
             cell.redCircleView.backgroundColor = [UIColor colorWithRed:140/255.0 green:198/255.0 blue:62/255.0 alpha:0.9];
             cell.redCircleView.tag = 2;
             [cell.redCircleView sizeToFit];
             
             //configure small 'min' label under the distance run label
             cell.redCircleSmallMinLabel.text = @"min";
             cell.redCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
             cell.redCircleSmallMinLabel.textColor = [UIColor whiteColor];
             cell.redCircleSmallMinLabel.tag = 2;
             //Resize the frame of the UILabel to fit the text
             [cell.redCircleSmallMinLabel sizeToFit];
             cell.redCircleSmallMinLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y + 10);
             
             //configure number of steps inside the red circle
             cell.redCircleMinOfExerciseTodayLabel.text = [NSString stringWithFormat: @"%i", [self minutesOfExercise:user]];
             cell.redCircleMinOfExerciseTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
             cell.redCircleMinOfExerciseTodayLabel.textColor = [UIColor whiteColor];
             cell.redCircleMinOfExerciseTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
             cell.redCircleMinOfExerciseTodayLabel.tag = 2;
             [cell.redCircleMinOfExerciseTodayLabel sizeToFit];
             cell.redCircleMinOfExerciseTodayLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y);
             
             
             //Determine orangeCircle size
             float orangeCircleHeightAndWidth = 0.0;
             if ([self caloriesBurned:user] < moveGoal*0.25)
             {
                 orangeCircleHeightAndWidth = 15*2.3;
             }
             else if ([self caloriesBurned:user] >= moveGoal*0.25 && [self caloriesBurned:user] < moveGoal*0.5)
             {
                 orangeCircleHeightAndWidth = 15*2.3;
             }
             else if ([self caloriesBurned:user] >= moveGoal*0.5 && [self caloriesBurned:user] < moveGoal*0.75)
             {
                 orangeCircleHeightAndWidth = 15*3.0;
             }
             else if ([self caloriesBurned:user] >= moveGoal*0.75 && [self caloriesBurned:user] < moveGoal)
             {
                 orangeCircleHeightAndWidth = 15*3.7;
             }
             else if ([self caloriesBurned:user] >= moveGoal)
             {
                 orangeCircleHeightAndWidth = 15*5.0;
             }
             
             
             //configure orange colored circle
             cell.orangeCircleView.frame = CGRectMake(0, 0,orangeCircleHeightAndWidth,orangeCircleHeightAndWidth);
             cell.orangeCircleView.center = CGPointMake(276, 30);
             cell.orangeCircleView.alpha = 0.9;
             cell.orangeCircleView.layer.cornerRadius = orangeCircleHeightAndWidth/2;
             cell.orangeCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:173/255.0 blue:239/255.0 alpha:0.9];
             cell.orangeCircleView.tag = 2;
             [cell.orangeCircleView sizeToFit];
             
             
             //configure small 'cal' label under the distance run label
             cell.orangeCircleSmallMinLabel.text = @"cal";
             cell.orangeCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
             cell.orangeCircleSmallMinLabel.textColor = [UIColor whiteColor];
             cell.redCircleSmallMinLabel.tag = 2;
             //Resize the frame of the UILabel to fit the text
             [cell.orangeCircleSmallMinLabel sizeToFit];
             cell.orangeCircleSmallMinLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y + 10);
             
             //configure calories burned inside the orange circle
             cell.orangeCircleNumOfCaloriesTodayLabel.text = [NSString stringWithFormat: @"%i", [self caloriesBurned:user]];
             cell.orangeCircleNumOfCaloriesTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
             cell.orangeCircleNumOfCaloriesTodayLabel.textColor = [UIColor whiteColor];
             cell.orangeCircleNumOfCaloriesTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
             cell.orangeCircleNumOfCaloriesTodayLabel.tag = 2;
             [cell.orangeCircleNumOfCaloriesTodayLabel sizeToFit];
             cell.orangeCircleNumOfCaloriesTodayLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y);
             
             cell.blueCircleNumOfStepsTodayLabel.textAlignment = NSTextAlignmentCenter;
             cell.redCircleMinOfExerciseTodayLabel.textAlignment = NSTextAlignmentCenter;
             cell.orangeCircleNumOfCaloriesTodayLabel.textAlignment = NSTextAlignmentCenter;
             
             [cell.blueCircleNumOfStepsTodayLabel sizeToFit];
             [cell.redCircleMinOfExerciseTodayLabel sizeToFit];
             [cell.orangeCircleNumOfCaloriesTodayLabel sizeToFit];
             
             cell.blueCircleNumOfStepsTodayLabel.center = cell.blueCircleView.center;
             cell.redCircleMinOfExerciseTodayLabel.center = cell.redCircleView.center;
             cell.orangeCircleNumOfCaloriesTodayLabel.center = cell.orangeCircleView.center;
         }];
        
        cell.clipsToBounds = YES;
        
        return cell;
    }
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
