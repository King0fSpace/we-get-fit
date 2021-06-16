//
//  ChallengeWinnersViewController.m
//  We Get Fit
//
//  Created by Long Le on 11/7/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "ChallengeWinnersViewController.h"

@interface ChallengeWinnersViewController ()

@end

@implementation ChallengeWinnersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSInteger viewOffset = 75;
    
    //Moves the tableView down so that the NavigationBar does not overlap it
    UIEdgeInsets inset = UIEdgeInsetsMake(viewOffset, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    //Add title to the top of the screen (navigational controller)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -75, 320, 75)];
    //do something like background color, title, etc you self
    [self.view addSubview:navBar];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(dismissView)];
    
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Last Week's Winners"];
    navigItem.rightBarButtonItem = doneItem;
    navBar.items = [NSArray arrayWithObjects: navigItem, nil];
    
    [navBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void) dismissView
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Overloading 'queryForTable' method in 'UsersViewController' class in order to limit query
- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    PFQuery *query;
    
    if ([PFUser currentUser])
    {
        //Show the top Challengers
        query = [PFUser query];
        [query whereKeyExists:@"NumberOfStepsToday"];
        [query orderByDescending:@"ChallengeDay6ListRankingScore"];
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
    
    self.paginationEnabled = NO;
    query.limit = 3;
    
    return query;
}

-(void) addPhotoFooter: (PhotoCell *)cell countryCode:(NSString*)countryCode age:(NSNumber*)ageArg gender:(NSString*)genderArg username:(NSString*)usernameArg
{
    NSLog (@"addPhotoFooter in ChallengeWinnersViewController called!");
    NSLog (@"usernameArg = %@", usernameArg);
    
    cell.footer.text = [NSString stringWithFormat: @"%@", usernameArg];
    cell.footer.textAlignment = NSTextAlignmentCenter;
    
    cell.footer.textColor = [UIColor whiteColor];
    cell.footer.font = [UIFont fontWithName:@"Helvetica" size:21];
    cell.footer.tag = 1;
}

-(int) sevenDayAvgNumOfSteps: (PFObject*)object
{
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:@"ChallengeStepsDay6"];
    return (int)[numOfStepsTodayNSNumber integerValue];
}

-(int) sevenDayAvgMinutesOfExercise: (PFObject*)object
{
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKey:@"ChallengeExerciseMinsDay6"];
    return (int)[minutesOfExerciseTodayNSNumber integerValue];
}

-(int) sevenDayAvgCaloriesBurned: (PFObject*)object
{
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKey:@"ChallengeCalsBurnedDay6"];
    return (int)[caloriesBurnedTodayNSNumber integerValue];
}

- (PhotoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog (@"indexPath = %@", indexPath);
    
    NSLog (@"cellForRowAtIndexPath in UsersViewController");
    
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.row == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        PhotoCell *cell = (PhotoCell *)[self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
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
        
        return cell;
        
    } else {
        
        PhotoCell *cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //Add all cell assets within this if block. configure the assets right outside the block
        if (!cell)
        {
            cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.blueCircleView];
            
            cell.blueCircleSmallStepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.blueCircleSmallStepsLabel];
            
            cell.blueCircleNumOfStepsTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.blueCircleNumOfStepsTodayLabel];
            
            cell.redCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.redCircleView];
            
            cell.redCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.redCircleSmallMinLabel];
            
            cell.redCircleMinOfExerciseTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.redCircleMinOfExerciseTodayLabel];
            
            cell.orangeCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.orangeCircleView];
            
            cell.orangeCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.orangeCircleSmallMinLabel];
            
            cell.orangeCircleNumOfCaloriesTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
        
        PFUser *userFetched = object;
        [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
         {
             NSString *gender = [object objectForKey:@"gender"];
             NSNumber *age = [object objectForKey:@"age"];
             NSString *countryCode = [object objectForKey:@"threeLetterCountryCode"];
             NSString *username = [object objectForKey:@"username"];
             
             //Add user photo to cell
             cell.imageView.file = [object objectForKey:@"profile_photo"];
             cell.imageView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 20, 20);
             [cell.imageView loadInBackground];
             
             //add text to footer
             [self addPhotoFooter:cell countryCode:countryCode age:age gender:gender username:username];
         }];
        
        //Add photoButton that brings up user profile when tapped
        cell.photoButton.tag = indexPath.row;
        [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *sevenDayAverageLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
        sevenDayAverageLabel.textColor = [UIColor lightGrayColor];
        sevenDayAverageLabel.backgroundColor = [UIColor clearColor];
        sevenDayAverageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(10.0)];
        sevenDayAverageLabel.text = [NSString stringWithFormat: @"Top 4 Days - Average"];
        [sevenDayAverageLabel sizeToFit];
        float xPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4;
        float yPosition = 8;
        sevenDayAverageLabel.center = CGPointMake(xPosition, yPosition);
        [cell addSubview:sevenDayAverageLabel];
        
        //Add exercise metrics to the right of picture
        //Determine blueCircle size
        float blueCircleHeightAndWidth;
        float blueCircleXPosition;
        float blueCircleYPosition;
        NSLog (@"[self sevenDayAvgNumOfSteps:object] = %i", [self sevenDayAvgNumOfSteps:object]);
        if ([self sevenDayAvgNumOfSteps:object] < 10) {
            
            blueCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 10 && [self sevenDayAvgNumOfSteps:object] < 999)
        {
            blueCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 999 && [self sevenDayAvgNumOfSteps:object] < 5000)
        {
            blueCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 5000 && [self sevenDayAvgNumOfSteps:object] < 10000)
        {
            blueCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 10000)
        {
            blueCircleHeightAndWidth = 15*5.25;
        }
        
        double cellBoundsHeight = 160; //Hardcoding this will position the bubbles correctly automatically
        
        blueCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4 - [[UIScreen mainScreen] bounds].size.width/10 - sqrt(4.5);
        blueCircleYPosition = (cellBoundsHeight/2) + (cellBoundsHeight/5);
        
        //Add blue colored circle
        cell.blueCircleView.frame = CGRectMake(0, 0, blueCircleHeightAndWidth, blueCircleHeightAndWidth);
        cell.blueCircleView.center = CGPointMake(blueCircleXPosition, blueCircleYPosition);
        cell.blueCircleView.alpha = 0.8;
        cell.blueCircleView.layer.cornerRadius = blueCircleHeightAndWidth/2;
        cell.blueCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:164/255.0 alpha:1];
        cell.blueCircleView.tag = 2;
        [cell.blueCircleView sizeToFit];
        
        cell.blueCircleStepsLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y);
        
        //Add small blue 'Steps' label under the number of steps
        cell.blueCircleSmallStepsLabel.text = @"steps";
        cell.blueCircleSmallStepsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.blueCircleSmallStepsLabel.textColor = [UIColor whiteColor];
        cell.blueCircleSmallStepsLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.blueCircleSmallStepsLabel sizeToFit];
        cell.blueCircleSmallStepsLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y + 10);
        
        //Add number of steps inside the blue circle
        cell.blueCircleNumOfStepsTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgNumOfSteps:object]];
        cell.blueCircleNumOfStepsTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.blueCircleNumOfStepsTodayLabel.textColor = [UIColor whiteColor];
        cell.blueCircleNumOfStepsTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.blueCircleNumOfStepsTodayLabel.tag = 2;
        [cell.blueCircleNumOfStepsTodayLabel sizeToFit];
        cell.blueCircleNumOfStepsTodayLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y);
        
        
        //Determine redCircle size
        float redCircleHeightAndWidth;
        float redCircleXPosition;
        float redCircleYPosition;
        if ([self sevenDayAvgMinutesOfExercise:object] < 1) {
            
            redCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 1 && [self sevenDayAvgMinutesOfExercise:object] < 20)
        {
            redCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 20 && [self sevenDayAvgMinutesOfExercise:object] < 40)
        {
            redCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 40 && [self sevenDayAvgMinutesOfExercise:object] < 60)
        {
            redCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 60)
        {
            redCircleHeightAndWidth = 15*5.25;
        }
        
        redCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4;
        redCircleYPosition = (cellBoundsHeight/2) - (cellBoundsHeight/6);
        
        
        //Add red colored circle
        cell.redCircleView.frame = CGRectMake(0, 0, redCircleHeightAndWidth, redCircleHeightAndWidth);
        cell.redCircleView.alpha = 0.8;
        cell.redCircleView.center = CGPointMake(redCircleXPosition, redCircleYPosition);
        cell.redCircleView.layer.cornerRadius = redCircleHeightAndWidth/2;
        cell.redCircleView.backgroundColor = [UIColor colorWithRed:140/255.0 green:198/255.0 blue:62/255.0 alpha:1];
        cell.redCircleView.tag = 2;
        [cell.redCircleView sizeToFit];
        cell.redCircleExerciseLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y);
        
        
        //Add small 'min' label under the distance run label
        cell.redCircleSmallMinLabel.text = @"min";
        cell.redCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.redCircleSmallMinLabel.textColor = [UIColor whiteColor];
        cell.redCircleSmallMinLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.redCircleSmallMinLabel sizeToFit];
        cell.redCircleSmallMinLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y + 10);
        
        
        //Add number of steps inside the red circle
        cell.redCircleMinOfExerciseTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgMinutesOfExercise:object]];
        cell.redCircleMinOfExerciseTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.redCircleMinOfExerciseTodayLabel.textColor = [UIColor whiteColor];
        cell.redCircleMinOfExerciseTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.redCircleMinOfExerciseTodayLabel.tag = 2;
        [cell.redCircleMinOfExerciseTodayLabel sizeToFit];
        cell.redCircleMinOfExerciseTodayLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y);
        
        
        //Determine orangeCircle size
        float orangeCircleHeightAndWidth;
        float orangeCircleXPosition;
        float orangeCircleYPosition;
        NSNumber *moveGoalNSNum = [object objectForKey:@"moveGoal"];
        double moveGoal = [moveGoalNSNum doubleValue];
        
        if ([self sevenDayAvgCaloriesBurned:object] < moveGoal*0.25 || [self sevenDayAvgCaloriesBurned:object] == 0) {
            
            orangeCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.25 && [self sevenDayAvgCaloriesBurned:object] < moveGoal*0.5)
        {
            orangeCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.5 && [self sevenDayAvgCaloriesBurned:object] < moveGoal*0.75)
        {
            orangeCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.75 && [self sevenDayAvgCaloriesBurned:object] < moveGoal)
        {
            orangeCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal)
        {
            orangeCircleHeightAndWidth = 15*5.25;
        }
        
        orangeCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4 + [[UIScreen mainScreen] bounds].size.width/10 + sqrt(4.5);
        orangeCircleYPosition = (cellBoundsHeight/2) + (cellBoundsHeight/5);
        
        
        //Add orange colored circle
        cell.orangeCircleView.frame = CGRectMake(0, 0, orangeCircleHeightAndWidth, orangeCircleHeightAndWidth);
        cell.orangeCircleView.center = CGPointMake(orangeCircleXPosition, orangeCircleYPosition);
        cell.orangeCircleView.alpha = 0.8;
        cell.orangeCircleView.layer.cornerRadius = orangeCircleHeightAndWidth/2;
        cell.orangeCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:173/255.0 blue:239/255.0 alpha:1];
        cell.orangeCircleView.tag = 2;
        [cell.orangeCircleView sizeToFit];
        
        
        //Add small 'cal' label under the distance run label
        cell.orangeCircleSmallMinLabel.text = @"cal";
        cell.orangeCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.orangeCircleSmallMinLabel.textColor = [UIColor whiteColor];
        cell.redCircleSmallMinLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.orangeCircleSmallMinLabel sizeToFit];
        cell.orangeCircleSmallMinLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y + 10);
        
        
        //Add number of steps inside the orange circle
        cell.orangeCircleNumOfCaloriesTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgCaloriesBurned:object]];
        cell.orangeCircleNumOfCaloriesTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.orangeCircleNumOfCaloriesTodayLabel.textColor = [UIColor whiteColor];
        cell.orangeCircleNumOfCaloriesTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.orangeCircleNumOfCaloriesTodayLabel.tag = 2;
        [cell.orangeCircleNumOfCaloriesTodayLabel sizeToFit];
        cell.orangeCircleNumOfCaloriesTodayLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y);
        
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
