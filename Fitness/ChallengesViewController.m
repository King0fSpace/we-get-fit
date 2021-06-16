//
//  ChallengesViewController.m
//  We Get Fit
//
//  Created by Long Le on 10/23/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "ChallengesViewController.h"

@interface ChallengesViewController ()

@end

@implementation ChallengesViewController

@synthesize userAlreadyShownInList;
@synthesize whiteListBlockoutView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addGrayChallengeDayBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog (@"ChallengesViewController viewDidAppear");
    
    [super viewDidAppear:animated];
    
    userAlreadyShownInList = NO;    
}

-(void) addGrayChallengeDayBar
{
    //Add label under 'Friends | Following' buttons but above the tableView that reads 'Today's Activity'
    UILabel *todaysActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -HEADER_THICKNESS, [[UIScreen mainScreen] bounds].size.width, HEADER_THICKNESS)];
    todaysActivityLabel.textAlignment =  UITextAlignmentCenter;
    todaysActivityLabel.textColor = [UIColor whiteColor];
    todaysActivityLabel.backgroundColor = [UIColor lightGrayColor];
    todaysActivityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    [self.view addSubview:todaysActivityLabel];
    
    if ([self dayOfTheWeek] >= 4)
    {
        todaysActivityLabel.text = [NSString stringWithFormat: @"Top 4 Day Average - Challenge Day (%i of 6)", [self dayOfTheWeek]];
    }
    else if ([self dayOfTheWeek] <= 3)
    {
        todaysActivityLabel.text = [NSString stringWithFormat: @"%i Day Average - Challenge Day (%i of 6)", [self dayOfTheWeek], [self dayOfTheWeek]];
    }
    
    if ([self dayOfTheWeek] == 7)
        todaysActivityLabel.text = [NSString stringWithFormat: @"Non-Challenge Day: Final Scores"];
}

-(BFTask *) loadObjects
{
    NSLog (@"ChallengesViewController loadObjects");
    
    return [super loadObjects];
}

-(int) dayOfTheWeek
{
    //Determine day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int dayOfTheWeek = (int)[comps weekday];
    NSLog (@"day of the week UNconverted = %i", dayOfTheWeek);
    
    //Convert dayOfTheWeek to have Monday be day 1
    if (dayOfTheWeek == 2)
        dayOfTheWeek = 1; //Monday
    else if (dayOfTheWeek == 3)
        dayOfTheWeek = 2; //Tuesday
    else if (dayOfTheWeek == 4)
        dayOfTheWeek = 3; //Wednesday
    else if (dayOfTheWeek == 5)
        dayOfTheWeek = 4; //Thursday
    else if (dayOfTheWeek == 6)
        dayOfTheWeek = 5; //Friday
    else if (dayOfTheWeek == 7)
        dayOfTheWeek = 6; //Satruday
    else if (dayOfTheWeek == 1)
        dayOfTheWeek = 7; //Sunday
    
    return dayOfTheWeek;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showRulesView:(UIBarButtonItem *)sender
{
    //perform your action
    RulesViewController *viewController = [[RulesViewController alloc] init];
    
    //Add Navigation Controller to RulesViewController
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentModalViewController:navController animated:YES];
}

- (void)didTapOnCellPhotoAction:(UIButton *)sender
{
    NSLog (@"ChallengesViewController didTapOnPhotoAction method called! ");
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    PFObject *user = [self.objects objectAtIndex:indexPath.row];
    
    if (user) {
        
        // NSLog (@"user = %@", user);
        
        MeViewController *viewController = [[MeViewController alloc] init];
        viewController.userObject = user;
        viewController.viewOffset = 460;
        viewController.currentViewIsNonRootView = YES;
        [self.navigationController pushViewController:viewController animated:YES];\
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"ChallengesViewController didSelectRowAtIndexPath called");
            
    if (indexPath.row == self.objects.count && self.paginationEnabled)
    {
        // Load More Cell
        [self loadNextPage];
    }
    else
    {
        PFObject *user = [self.objects objectAtIndex:indexPath.row];
        
        if (user) {
            
            MeViewController *viewController = [[MeViewController alloc] init];
            viewController.userObject = user;
            viewController.viewOffset = 460;
            viewController.currentViewIsNonRootView = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

-(int) minutesOfExercise: (PFObject*)object
{
    NSString *minOfExerciseParseKey = [NSString stringWithFormat:@""];
    
    if ([self dayOfTheWeek] == 1)
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay1"];
    }
    else if ([self dayOfTheWeek] == 2)
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay2"];
    }
    else if ([self dayOfTheWeek] == 3)
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay3"];
    }
    else if ([self dayOfTheWeek] == 4)
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay4"];
    }
    else if ([self dayOfTheWeek] == 5)
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay5"];
    }
    else
    {
        minOfExerciseParseKey = [NSString stringWithFormat:@"ChallengeExerciseMinsDay6"];
    }
    
    //Show today's stats
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKeyedSubscript:minOfExerciseParseKey];
    
    return (int)[minutesOfExerciseTodayNSNumber integerValue];
}

-(int) numOfSteps: (PFObject*)object
{
    NSString *numOfStepsParseKey = [NSString stringWithFormat:@""];
    
    if ([self dayOfTheWeek] == 1)
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay1"];
    }
    else if ([self dayOfTheWeek] == 2)
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay2"];
    }
    else if ([self dayOfTheWeek] == 3)
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay3"];
    }
    else if ([self dayOfTheWeek] == 4)
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay4"];
    }
    else if ([self dayOfTheWeek] == 5)
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay5"];
    }
    else
    {
        numOfStepsParseKey = [NSString stringWithFormat:@"ChallengeStepsDay6"];
    }
    
    //Show today's stats
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:numOfStepsParseKey];
    
    NSLog (@"[numOfStepsTodayNSNumber integerValue] = %li", (long)[numOfStepsTodayNSNumber integerValue]);
    
    return (int)[numOfStepsTodayNSNumber integerValue];
}

-(int) caloriesBurned: (PFObject*)object
{
    NSString *calsBurnedParseKey = [NSString stringWithFormat:@""];
    
    if ([self dayOfTheWeek] == 1)
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay1"];
    }
    else if ([self dayOfTheWeek] == 2)
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay2"];
    }
    else if ([self dayOfTheWeek] == 3)
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay3"];
    }
    else if ([self dayOfTheWeek] == 4)
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay4"];
    }
    else if ([self dayOfTheWeek] == 5)
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay5"];
    }
    else
    {
        calsBurnedParseKey = [NSString stringWithFormat:@"ChallengeCalsBurnedDay6"];
    }
    
    //Show today's stats
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKeyedSubscript:calsBurnedParseKey];
    
    return (int)[caloriesBurnedTodayNSNumber integerValue];
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
