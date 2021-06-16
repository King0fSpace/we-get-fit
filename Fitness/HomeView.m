//
//  FriendsView.m
//  Fitness
//
//  Created by Long Le on 4/7/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "HomeView.h"
#import "ActivityCell.h"


@interface HomeView ()
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation HomeView
@synthesize firstLaunch;
@synthesize blankTimelineView;
@synthesize listDisplayedTextField;
@synthesize myPickerView;
@synthesize listsArray;
@synthesize pickerToolBarView;
@synthesize homeCurrentListSelectedString;
@synthesize todaysActivityLabel;

- (void)viewDidLoad {
    
    NSLog (@"HomeView viewDidLoad");
    
    [super viewDidLoad];
        
    UIEdgeInsets inset = UIEdgeInsetsMake(25, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    //Add label under 'Friends | Following' buttons but above the tableView that reads 'Today's Activity'
    todaysActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -25, [[UIScreen mainScreen] bounds].size.width, 25)];
    todaysActivityLabel.textAlignment =  UITextAlignmentCenter;
    todaysActivityLabel.textColor = [UIColor whiteColor];
    todaysActivityLabel.backgroundColor = [UIColor lightGrayColor];
    todaysActivityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    [self.view addSubview:todaysActivityLabel];
    
  /*
    UISegmentedControl *quicklookOrActivitySegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Yesterday", @"Today", nil]];
    [quicklookOrActivitySegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [quicklookOrActivitySegmentedControl addTarget:self action:@selector(mySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    [quicklookOrActivitySegmentedControl sizeToFit];
    self.navigationItem.titleView = quicklookOrActivitySegmentedControl;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"friendsOrFollowingSwitchSelected"] == 0)
    {
        todaysActivityLabel.text = [NSString stringWithFormat: @"Yesterday's Friends and Following Activity"];
        quicklookOrActivitySegmentedControl.selectedSegmentIndex = 0;
    }
    else if ([prefs boolForKey:@"friendsOrFollowingSwitchSelected"] == 1)
    {
        todaysActivityLabel.text = [NSString stringWithFormat: @"Today's Friends Activity"];
        quicklookOrActivitySegmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        todaysActivityLabel.text = [NSString stringWithFormat: @"Today's Friends Activity"];
        quicklookOrActivitySegmentedControl.selectedSegmentIndex = 1;
    }
    */
    
    
    
    //Add search button if you're on the 'Me' tab.  If you're on any other tab do not add it since those pages will have their own nav bar buttons
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchAction:)];
    
    //Add title to the top of the screen (navigational controller)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    label.text = [NSString stringWithFormat:@"Facebook Friends"];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
  //  [self loadObjects];
}
/*
-(void) addListDisplayedTextField
{
    listsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"listsArray"];
    
    //Add text field under nav bar that shows which list you're looking at
    listDisplayedTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, -31, 300, 30)];
    listDisplayedTextField.borderStyle = UITextBorderStyleRoundedRect;
    listDisplayedTextField.font = [UIFont systemFontOfSize:15];
    
    //Set default list contents
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    listDisplayedTextField.text = appDelegate.homeCurrentListSelectedString;
    
    listDisplayedTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    listDisplayedTextField.keyboardType = UIKeyboardTypeDefault;
    listDisplayedTextField.returnKeyType = UIReturnKeyDone;
    listDisplayedTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    listDisplayedTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    listDisplayedTextField.textAlignment = UITextAlignmentCenter;
    listDisplayedTextField.delegate = self;
    [self.view addSubview:listDisplayedTextField];
}
*/
-(void)searchAction:(UIBarButtonItem *)sender{
    
    //perform your action
    UsersViewController *viewController = [[UsersViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect fixedFrame = listDisplayedTextField.frame;
    fixedFrame.origin.y = 64 + scrollView.contentOffset.y;
    listDisplayedTextField.frame = fixedFrame;
}

-(void)createPickerView
{
    //Contents for Picker
    listsArray = [[NSMutableArray alloc] init];
    [listsArray addObject:@"Following"];
    [listsArray addObject:@"Friends"];
    [listsArray addObject:@"Top Rated"];
    
    pickerToolBarView = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height/2 - 60, self.view.frame.size.width,400)];
    [pickerToolBarView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,pickerToolBarView.frame.size.width,35)];
    toolBar.barStyle = UIBarStyleDefault;
    //toolBar.backgroundColor = [UIColor lightGrayColor];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    [toolBar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,toolBar.frame.size.height,toolBar.frame.size.width,50)];
    [myPickerView setDataSource: self];
    [myPickerView setDelegate: self];
    myPickerView.showsSelectionIndicator = YES;
    [myPickerView setBackgroundColor:[UIColor whiteColor]];
    
    [pickerToolBarView addSubview:toolBar];
    [pickerToolBarView addSubview:myPickerView];
    [self.view addSubview:pickerToolBarView];
    [self.view bringSubviewToFront:pickerToolBarView];
    
    [myPickerView selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"listDisplayedTextField"] inComponent:0 animated:NO];
}

-(void)doneTouched:(id)sender
{
    [pickerToolBarView removeFromSuperview];
    [listDisplayedTextField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self createPickerView];
    
    return NO;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
   
    // Handle the selection
    listDisplayedTextField.text = [listsArray objectAtIndex:row];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:(int)row forKey:@"listDisplayedTextField"];
    [prefs synchronize];
    
    [self loadObjects];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 3;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [listsArray objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void)mySegmentControlAction:(UISegmentedControl *)segment
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if(segment.selectedSegmentIndex == 0)
    {
        // Convert your value to IntegerValue and Save it
        [prefs setBool:0 forKey:@"friendsOrFollowingSwitchSelected"];
    }
    else
    {
        [prefs setBool:1 forKey:@"friendsOrFollowingSwitchSelected"];
    }
    
    [prefs synchronize];
    [self loadObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.objects.count)
    {
        return 60;
        
    }
    else
    {
        return 44.0f;
    }
    
    /*
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"friendsOrFollowingSwitchSelected"] == 1)
    {
        if (indexPath.row == 0)
        {
            return 495;
            
        }
        else
        {
            return 475.0f;
        }
    }
    else
    {
        if (indexPath.row < self.objects.count)
        {
            return 60;
            
        }
        else
        {
            return 44.0f;
        }
    }
     */
}

-(BFTask *) loadObjects
{
    NSLog (@"HomeView loadObjects");
    return [super loadObjects];
}

-(NSString*) convertToLocalTime: (NSDate*)dateArg
{
    NSDateFormatter *localFormat = [[NSDateFormatter alloc] init];
    [localFormat setTimeStyle:NSDateFormatterLongStyle];
    [localFormat setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
    NSString *localTime = [localFormat stringFromDate:dateArg];
    
    return localTime;
}

//Overloading 'queryForTable' method in 'UsersViewController' class in order to limit query
- (PFQuery *)queryForTable
{
    NSLog (@"queryForTable in HomeView run");

    NSLog (@"Current Time = %@", [self convertToLocalTime:[NSDate date]]);
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:25];
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
        /*
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"friendsOrFollowingSwitchSelected"] == 0)
        {
            todaysActivityLabel.text = [NSString stringWithFormat: @"Yesterday's Activity - Friends and Following"];
            
            query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [query whereKey:@"saved_to_list" equalTo:@"Following"];
            //[query whereKey:@"FriendStatus" equalTo:@"Friends"];
            [query whereKey:@"fromUserToUserSame" notEqualTo:@"YES"];
            [query orderByDescending:@"toUserYesterdaysListRankingScore"];
        }
        else
        {
            todaysActivityLabel.text = [NSString stringWithFormat: @"Today's Activity - Friends Only"];

            query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [query whereKey:@"saved_to_list" equalTo:@"Following"];
            [query whereKey:@"FriendStatus" equalTo: @"Friends"];
            [query orderByDescending:@"timeRelativeToUserListRankingScore"];
        }
         */
        
        //Show friends only since we're removing the segment control
        query = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [query whereKey:@"saved_to_list" equalTo:@"Following"];
        [query whereKey:@"FriendStatus" equalTo: @"Friends"];
        [query orderByDescending:@"timeRelativeToUserListRankingScore"];
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

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}

-(void) addPhotoFooter: (PersonHealthStatsQuickViewCell *)cell threeLetterCountryCode:(NSString*)threeLetterCountryCodeArg
{
    NSLog (@"HomeView addPhotoFooter called!");
    
    //If threeLetterCountryCode is saved to parse display it for the user in the cell
    if (threeLetterCountryCodeArg)
        cell.footer.text = [NSString stringWithFormat:@"   %@", threeLetterCountryCodeArg]; //Spaces will center it

    cell.footer.textColor = [UIColor whiteColor];
    cell.footer.font = [UIFont fontWithName:@"San Francisco" size:21];
    cell.footer.tag = 1;
    
    [cell.footer setTextColor:[UIColor lightGrayColor]];
    [cell.footer setFont:[UIFont fontWithName:@"San Francisco" size:8]];
}

- (PersonHealthStatsQuickViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"Cell";
    
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
        PersonHealthStatsQuickViewCell *cell = (PersonHealthStatsQuickViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[PersonHealthStatsQuickViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            //Add gray square to the left of profile photo with the number of the row its located in
            cell.squareNumberView = [[UIView alloc] initWithFrame:CGRectMake(0,0,27,cell.frame.size.height - 1)];
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

        PFUser *userFetched = object[@"toUser"];
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
                    [self addPhotoFooter:cell threeLetterCountryCode: threeLetterCountryCodeString];
                }
            }];
            
            //Add photoButton that brings up user profile when tapped
            [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)didTapLikePhotoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    PFObject *object = [self objectAtIndexPath:indexPath];
    
    //Determines if user has liked the photo already
    BOOL liked = ![[Cache sharedCache] isPhotoLikedByCurrentUser:object];
    
    // Update the like count in the Cache
    NSArray *likeUsers = [[Cache sharedCache] likersForPhoto:object];
    int numOfLikers = [likeUsers count];
    NSNumber *likeCount = [NSNumber numberWithInt:numOfLikers];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[Cache sharedCache] incrementLikerCountForPhoto:object];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[Cache sharedCache] decrementLikerCountForPhoto:object];
    }
    
    // Add the current user as a liker of the photo in Cache
    [[Cache sharedCache] setPhotoIsLikedByCurrentUser:object liked:liked];
    
    NSLog (@"Like button uploaded to this many likes = %li", [likeCount integerValue]);
    
    //Convert likeCount(NSNumber) to int
    int likeCountInt = [likeCount intValue];
    // Update the button label
    [button setTitle:[NSString stringWithFormat: @"%i Likes", likeCountInt] forState:UIControlStateNormal];
    
    // Call the appropriate static method to handle creating/deleting the right object
    if (liked) {
        [Utility likePhotoInBackground:object block:^(BOOL succeeded, NSError *error) {
            NSLog (@"success with liking!");
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            /*
             PhotoHeaderView *actualHeaderView = (PhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
             [actualHeaderView shouldEnableLikeButton:YES];
             [actualHeaderView setLikeStatus:succeeded];
             
             if (!succeeded) {
             // Revert the button title (the number) if the call fails
             [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
             }
             */
        }];
    } else {
        [Utility unlikePhotoInBackground:object block:^(BOOL succeeded, NSError *error) {
            NSLog (@"success with UNliking!");
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            /*
             PhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
             [actualHeaderView shouldEnableLikeButton:YES];
             [actualHeaderView setLikeStatus:!succeeded];
             
             if (!succeeded) {
             // Revert the button title (the number) if the call fails
             [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
             }
             */
        }];
    }
}

-(void)acceptButtonAction:(id)sender
{
    //1) 'Friend' the other person back
    //2) verify that both people are friends
    //3) Refresh page
    
    UIButton *button = (UIButton *)sender;
    
    if (![button isSelected]) {
    
        button.selected = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        
        PFObject *object = [self objectAtIndexPath:indexPath];
        
        //Extract the 'fromUser' from object
        //Fetch the user corresponding with the object (activity) in the fromUser field
        PFUser *userFetch = object[@"fromUser"];
        [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error)
        {
            //Return objectId of user
            PFObject *user = userFetched;
            PFQuery * query = [PFUser query];
            [query whereKey:@"objectId" equalTo:user.objectId];
            NSArray * results = [query findObjects];
            PFUser *targetUser = [results lastObject];
            
            [Utility friendUserEventually:targetUser block:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                     [self.tableView reloadData];
                 }
             }];
        }];
    }
}

-(void)rejectButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (![button isSelected]) {
        
        button.selected = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        
        PFObject *object = [self objectAtIndexPath:indexPath];
        
        //Extract the 'fromUser' from object
        //Fetch the user corresponding with the object (activity) in the fromUser field
        PFUser *userFetch = object[@"fromUser"];
        [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error)
         {
             NSLog (@"Rejected!");
             //Return objectId of user
             PFObject *user = userFetched;
             PFQuery * query = [PFUser query];
             [query whereKey:@"objectId" equalTo:user.objectId];
             NSArray * results = [query findObjects];
             PFUser *targetUser = [results lastObject];
             
             [Utility rejectFriendRequestEventually:targetUser tableViewController:self tableView:self.tableView];
             
             
             for (UIView *view in [self.tableView cellForRowAtIndexPath:indexPath].subviews)
             {
                 if ([view isKindOfClass: [UIButton class]] || [view isKindOfClass: [UILabel class]])
                 
                 [view removeFromSuperview];
             }
         }];
    }
}

- (void)didTapOnPhotoAction:(UIButton *)sender
{
    NSLog (@"HomeView didTapOnPhotoAction method called! ");
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    PFUser *userFetch = object[@"toUser"];
    [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
        PFObject *user = userFetched;
        
        if (user) {
            
            // NSLog (@"user = %@", user);
            
            MeViewController *viewController = [[MeViewController alloc] init];
            viewController.userObject = user;
            viewController.viewOffset = 460;
            viewController.currentViewIsNonRootView = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            
            NSLog (@"view should open!");
        }
    }];
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSLog (@"HomeView didSelectRowAtIndexPath called!");
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    PFUser *userFetch = object[@"toUser"];
    [userFetch fetchIfNeededInBackgroundWithBlock:^(PFObject *userFetched, NSError *error) {
        PFObject *user = userFetched;
        
        if (user) {
            
            NSLog (@"user Loaded = %@", user);
            
            MeViewController *viewController = [[MeViewController alloc] init];
            viewController.userObject = user;
            viewController.viewOffset = 460;
            viewController.currentViewIsNonRootView = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

-(BOOL) isNSDateToday: (NSDate*)dateToCheckArg
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dateToCheckArg];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(int) minutesOfExercise: (PFObject*)object
{
    //Show today's stats
    //Show yesterday's stats
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKeyedSubscript:@"MinutesOfExerciseToday"];
    
    if (!([self isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[minutesOfExerciseTodayNSNumber integerValue];
    }
}

-(int) numOfSteps: (PFObject*)object
{
    //Show today's stats
    NSNumber *numOfStepsTodayNSNumber = [object objectForKeyedSubscript:@"NumberOfStepsToday"];
    
    if (!([self isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[numOfStepsTodayNSNumber integerValue];
    }
}

-(int) caloriesBurned: (PFObject*)object
{
    //Show today's stats
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKeyedSubscript:@"CaloriesBurnedToday"];
    
    if (!([self isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[caloriesBurnedTodayNSNumber integerValue];
    }
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
