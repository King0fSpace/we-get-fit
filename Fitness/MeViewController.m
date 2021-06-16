//
//  MeViewController.m
//  Fitness
//
//  Created by Long Le on 3/8/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "MeViewController.h"
#import "UsersViewController.h"
#import "MotivationFriendsListViewController.h"
#import "APTimeZones.h"
#import "ChallengeWinnersViewController.h"
#import "ChallengesViewController.h"

@interface MeViewController ()

@end


@implementation MeViewController

@synthesize index;
@synthesize title;
@synthesize shouldReloadOnAppear;
@synthesize dashboardView;
@synthesize userObject;
@synthesize viewOffset;
@synthesize currentViewIsNonRootView;
@synthesize myPickerView;
@synthesize listsArray;
@synthesize pickerToolBarView;
@synthesize progressIndicator;
@synthesize shareHealthDataButton;
@synthesize askToShareData;
@synthesize calculatingFitnessRatingLabel;
@synthesize askUserToShareDataLabel;
@synthesize numOfDaysWatchWasWorn;
@synthesize numberOfFriends;
@synthesize numberOfPeopleYouAreFollowing;
@synthesize numberOfFollowers;
@synthesize friendsObjectIdArray;
@synthesize usernameLabel;
@synthesize locationManager;
@synthesize navControllerTitleLabel;
@synthesize userEditableTextField;
@synthesize facebookFriendsObjectIdsArray;

- (void)viewDidLoad {
    
    NSLog (@"MeViewController viewDidLoad");
    
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    [self addTodayDelimiterLabel];
    
    NSLog (@"[NSTimeZone localTimeZone] = %@", [NSTimeZone localTimeZone]);
    
    healthStore = [[HKHealthStore alloc] init];
    facebookFriendsObjectIdsArray = [[NSMutableArray alloc] init];
    
    //If HomeView's 'Today' hasn't yet been set as the default then do so
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"friendsOrFollowingSwitchSelected"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"friendsOrFollowingSwitchSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (userObject == nil)
        if ([PFUser currentUser])
            userObject = [PFUser currentUser];
    
    NSLog (@"currentViewIsNonRootView = %i", currentViewIsNonRootView);
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    if (viewOffset == 0)
        viewOffset = 455;
    
    //Moves the tableView down so that the NavigationBar does not overlap it
    UIEdgeInsets inset = UIEdgeInsetsMake(viewOffset, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    //Create 'progress' icon
    progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    progressIndicator.frame = CGRectMake(self.view.frame.size.width/4, -200, 160.0, 40.0);
    //progressIndicator.center = self.view.center;
    [self.view addSubview:progressIndicator];
    [progressIndicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    //Contents for Picker
    listsArray = [[NSMutableArray alloc] init];
    [listsArray addObject:@"Following"];
    [listsArray addObject:@"Friends"];
    [listsArray addObject:@"Top Rated"];
    
    //Create and add labels
    askToShareData = [[UITextView alloc] initWithFrame:CGRectMake(15, -285, 300, 275)];
    [self.view addSubview: askToShareData];
    askToShareData.hidden = YES;
    
    //Create and add labels
    calculatingFitnessRatingLabel = [[UITextView alloc] initWithFrame:CGRectMake(20, -260, 300, 275)];
    [self.view addSubview: calculatingFitnessRatingLabel];
    calculatingFitnessRatingLabel.hidden = YES;
    
    if (![PFUser currentUser]) {
                
        // Customize the Log In View Controller
        MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
        logInViewController.delegate = self;
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", nil]];
        [logInViewController setFields: PFLogInFieldsFacebook];
        
        // Present Log In View Controller
        [self.navigationController presentViewController:logInViewController animated:YES completion:nil];
    }
    else
    {
        //Adds friends, following, followers labels, and user's photo
        [self addDashboardView];
        [self shareHealthDataOrCreateButton];
    }
    
    friendsObjectIdArray = [[NSMutableArray alloc] init];

    /*
    //Every 5 seconds check if the user's fitnessScore is above a certain amount. If it is call dialogueBoxForWorkoutMotivation
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowMotivationDialogueBoxTimerToRun"] == YES)
    {
        NSLog (@"Setting timer to allow checkIfMotivationDialogueBoxShouldShow to run periodically");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AllowMotivationDialogueBoxTimerToRun"];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkIfMotivationDialogueBoxShouldShow) userInfo: nil repeats: YES];
    }
    */
    
    [self unflagForInappropriateContent:[PFUser currentUser] block:^(BOOL succeeded, NSError *error)
    {
        
    }];
    
    /* This shows a 'Winners View' on Monday morning.  Comment this out until you can get 'ChallengeWinnersViewController to show the winners and their data from the 'GeneralChallengeWinners' class
    ChallengesViewController *challengesViewSubClass = [[ChallengesViewController alloc] init];
    if ([challengesViewSubClass dayOfTheWeek] == 1 && [[NSUserDefaults standardUserDefaults] boolForKey:@"WinnersAlreadyShownOnMonday"] == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WinnersAlreadyShownOnMonday"];
        
        ChallengeWinnersViewController *challengeWinnersViewControllerSubClass = [[ChallengeWinnersViewController alloc] init];
        [self.navigationController presentViewController:challengeWinnersViewControllerSubClass animated:YES completion:nil];
    }
    //Reset WinnersAlreadyShownOnMonday NSUserDefaults on Tuesday
    if ([challengesViewSubClass dayOfTheWeek] == 2)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WinnersAlreadyShownOnMonday"];
    }
    
    ChallengeWinnersViewController *challengeWinnersViewControllerSubClass = [[ChallengeWinnersViewController alloc] init];
    [self.navigationController presentViewController:challengeWinnersViewControllerSubClass animated:YES completion:nil];
     */
    
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)]; // Declare the Gesture.
    gesRecognizer.delegate = self;
    [self.view addGestureRecognizer:gesRecognizer]; // Add Gesture to your view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog (@"MeViewController viewDidAppear");
        
    if ([PFUser currentUser] && userObject)
    {
        NSLog (@"viewDidAppear MeViewController");
        
        navControllerTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        navControllerTitleLabel.backgroundColor = [UIColor clearColor];
        navControllerTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        // navControllerTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        navControllerTitleLabel.textAlignment = NSTextAlignmentCenter;
        // ^-Use UITextAlignmentCenter for older SDKs.
        navControllerTitleLabel.textColor = [UIColor whiteColor]; // change this color
        //navControllerTitleLabel.text = [userObject objectForKey:@"username"];
        navControllerTitleLabel.text = @"We Get Fit";
        [navControllerTitleLabel sizeToFit];
        self.navigationItem.titleView = navControllerTitleLabel;
        
        
        //Add search button if you're on the 'Me' tab.  If you're on any other tab do not add it since those pages will have their own nav bar buttons
      //  if (currentViewIsNonRootView == NO)
      //      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchAction:)];
        
        [self addColoredCircles];
        
        //Refresh user profile photo in case they changed it just now
        if (userObject)
        {
            [userObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                if (!error)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    //NSLog(@"data = %@", data);
                    NSLog(@"userObject profile_photo = %@", userObject[@"profile_photo"]);
                    // image can now be set on a UIImageView
                    dashboardView.uploaderPhoto = [[UIImageView alloc] initWithImage:image];
                    dashboardView.uploaderPhoto.frame = CGRectMake(5, -15, 100, 100);
                    dashboardView.uploaderPhoto.layer.cornerRadius = dashboardView.uploaderPhoto.frame.size.width / 2;
                    dashboardView.uploaderPhoto.clipsToBounds = YES;
                    [dashboardView addSubview:dashboardView.uploaderPhoto];
                    [self addUserPersonalStats:userObject];
                }
            }];
        }
        
        //Refresh number of friends and requests
        /*
        if (userObject)
        {
            NSLog(@"userObject photo =  %@", userObject[@"profile_photo"]);
            
            [userObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                if (!error)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    // NSLog(@"data = %@", data);
                    NSLog(@"userObject profile_photo = %@", userObject[@"profile_photo"]);
                    // image can now be set on a UIImageView
                    dashboardView.uploaderPhoto = [[UIImageView alloc] initWithImage:image];
                    dashboardView.uploaderPhoto.frame = CGRectMake(5, -15, 100, 100);
                    dashboardView.uploaderPhoto.layer.cornerRadius = dashboardView.uploaderPhoto.frame.size.width / 2;
                    dashboardView.uploaderPhoto.clipsToBounds = YES;
                    [dashboardView addSubview:dashboardView.uploaderPhoto];
                    [self addUserPersonalStats:userObject];
                    
                    //Add tap recognizer to uploaderPhoto so that a full screen version of the photo opens up when user taps it
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPhotoTapped)];
                    singleTap.numberOfTapsRequired = 1;
                    dashboardView.uploaderPhoto.userInteractionEnabled = YES;
                    [dashboardView.uploaderPhoto addGestureRecognizer:singleTap];
                }
            }];
            
            [self queryNumberOfFriendsFollowingFollowers:userObject completionHandler:^(double done, NSError *error)
             {
                 //update the number of friends the person has
                 dashboardView.numberOfFriendsLabel.text = [NSString stringWithFormat:@"  %i  ", numberOfFriends];
                 [dashboardView.numberOfFriendsLabel sizeToFit];
                 dashboardView.numberOfFriendsLabel.center = CGPointMake(dashboardView.friendsLabel.center.x, dashboardView.friendsLabel.center.y - 16);
                 
                 //update the number of followers the person has
                 dashboardView.numberOfFollowersLabel.text = [NSString stringWithFormat:@"  %i  ", numberOfFollowers];
                 dashboardView.numberOfFollowersLabel.center = CGPointMake(dashboardView.followersLabel.center.x, dashboardView.followersLabel.center.y - 16);
             }];
        }
        */
        if (userObject == [PFUser currentUser])
        {
            //If last workout logged in Parse was duplicated then delete it
            PFQuery *query = [PFQuery queryWithClassName:@"Workouts"];
            [query whereKey:@"userObjectId" equalTo:[PFUser currentUser].objectId];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
             {
                 NSLog (@"querying for duplicate workouts");
                 
                 if (!error)
                 {
                     //If the 'createdAt' for the top two results is the same delete the first one
                     PFObject *topResult = [results objectAtIndex:0];
                     PFObject *secondResult = [results objectAtIndex:1];
                     
                     NSLog (@"your # of workouts = %li", [results count]);
                     
                     if (topResult.createdAt == secondResult.createdAt)
                     {
                         NSLog (@"duplicate workout found, deleting one");
                         
                         PFObject *object = [PFObject objectWithoutDataWithClassName:@"Workouts"
                                                                            objectId:topResult.objectId];
                         [object deleteEventually];
                     }
                 }
             }];
        }
        //This will reset the username displayed on the navBar title and username label under the user's photo in case the user changes it in Edit your Profile
        //usernameLabel.text = [userObject objectForKey:@"username"];
        //[usernameLabel sizeToFit];
        
        //Refresh friendsObjectIdArray to avoid the case where you're loading the app for the first time and you dont have any workouts listed in the workouts tab
        /*
        if (userObject == [PFUser currentUser])
        {
            PFQuery *friendsQuery1 = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [friendsQuery1 whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [friendsQuery1 whereKey:@"saved_to_list" equalTo:@"Following"];
            [friendsQuery1 whereKey:@"fromUserToUserSame" notEqualTo:@"YES"];
            [friendsQuery1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 NSLog (@"MeView viewDidAppear friendsObjectIdArray count = %li", [objects count]);
                 
                 if (!error)
                 {
                     for (PFObject *object in objects)
                     {
                         PFUser *userFetched = object[@"toUser"];
                         [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
                          {
                              NSString *friendObjectIdString = [NSString stringWithFormat:@"%@",userFetched.objectId];
                              NSLog (@"friendObjectIdString = %@", friendObjectIdString);
                              [friendsObjectIdArray addObject: friendObjectIdString];
                              
                              //Save array to NSUserDefaults
                              [[NSUserDefaults standardUserDefaults] setObject:friendsObjectIdArray forKey:@"friendsObjectIdArray"];
                          }];
                     }
                 }
             }];
        }
        */
        
        /*
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
         
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager requestAlwaysAuthorization];
        
        [locationManager startMonitoringSignificantLocationChanges];
         */
        
        [self loadObjects];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

-(void)checkIfMotivationDialogueBoxShouldShow
{
    NSLog (@"checkIfMotivationDialogueBoxShouldShow called!");
    
    if ([PFUser currentUser] && userObject == [PFUser currentUser])
    {
        NSNumber *listRankingScoreNSNumber = [PFUser currentUser][@"listRankingScore"];
        
        float listRankingScore = [listRankingScoreNSNumber floatValue];
        
        NSLog (@"MeViewController listRankingScore = %f", listRankingScore);
        
        if (listRankingScore > 0.5)
        {
            [self dialogueBoxForWorkoutMotivation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //get current location of phone:
    if (newLocation != nil)
    {
        NSLog(@"didUpdateToLocation: %@", newLocation);
    }
    
    self.currentLocation = newLocation;
    
    [self usersThreeLetterCountryCode];
}

-(void) usersThreeLetterCountryCode
{
    NSLog (@"MeViewController usersCountry");
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    if ([PFUser currentUser])
    {
        [reverseGeocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
             NSString *countryCode = myPlacemark.ISOcountryCode;
             NSString *countryName = myPlacemark.country;
             NSLog(@"My country code: %@ and countryName: %@", [self getThreeLetterCountryCodeFromTwoLetterCountryCode: countryCode], countryName);
             
             NSString *threeLetterCountryCode = [self getThreeLetterCountryCodeFromTwoLetterCountryCode: countryCode];
             
             //Upload user's three letter country code to parse
             if (threeLetterCountryCode)
             {
                 [PFUser currentUser][@"threeLetterCountryCode"] = threeLetterCountryCode;
                [[PFUser currentUser] saveInBackground];
             }
         }];
    }
}

-(void)flagForInappropriateContent:(PFUser *)userArg block:(void (^)(BOOL succeeded, NSError *error))completionHandler {
    
    NSLog (@"flagForInappropriateContent in MeViewController called!");
    /*
    if ([PFUser currentUser])
    {
        if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]])
        {
            return;
        }
    }
    */
    //Query for flagging objects aimed at 'userArg'
    if ([PFUser currentUser])
    {
        PFQuery *query2 = [PFQuery queryWithClassName:@"Flagged"];
        [query2 whereKey:@"flaggedUser" equalTo:userArg];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            NSLog (@"object4 = %@", [objects lastObject]);
            //If object exists then work with it
            if ([objects lastObject] != NULL)
            {
                NSLog (@"Flagged object already exists.");
                //proceed with adding the flagger to the array and incrementing the flag count for 'user'
                PFObject *flaggedObject = [objects lastObject];
                
                //See if user already flagged this person
                NSMutableArray *usersWhoFlaggedArrayFromParse = [[NSMutableArray alloc] init];
                usersWhoFlaggedArrayFromParse = flaggedObject[@"UsersWhoFlagged"];
                NSMutableArray *usersWhoFlaggedArrayLocal = [[NSMutableArray alloc] init];
                [usersWhoFlaggedArrayLocal addObjectsFromArray:usersWhoFlaggedArrayFromParse];
                BOOL userAlreadyExistsInArrayOnParse = NO;
                for (NSString *userWhoFlagged in usersWhoFlaggedArrayLocal)
                {
                    NSLog (@"userWhoFlagged = %@", userWhoFlagged);
                    //If user's objectId is already added to the array on parse then break
                    if ([userWhoFlagged isEqualToString:[PFUser currentUser].objectId])
                    {
                        NSLog (@"user already exists in 'UsersWhoFlagged' array on parse");
                        userAlreadyExistsInArrayOnParse = YES;
                    }
                }
                
                //Add current user to an array if they aren't already
                if (userAlreadyExistsInArrayOnParse == NO)
                {
                    NSLog (@"adding user to 'usersWhoFlaggedArray'");
                    //add user to array
                    NSString *currentUserObjectId = [PFUser currentUser].objectId;
                    [usersWhoFlaggedArrayLocal addObject:currentUserObjectId];
                    flaggedObject[@"UsersWhoFlagged"] = usersWhoFlaggedArrayLocal;
                    
                    //Increment flag count
                    NSNumber *currentFlaggedCountNSNumber = flaggedObject[@"FlaggedCount"];
                    long int currentFlaggedCountInt = [currentFlaggedCountNSNumber integerValue];
                    flaggedObject[@"FlaggedCount"] = [NSNumber numberWithInteger: currentFlaggedCountInt + 1];
                }
                
                [flaggedObject saveInBackground];
            }
            //If object doesn't exist then create it
            else
            {
                NSLog (@"Flagged object does not exist yet. Creating flagged object and setting 'FlaggedCount' to 1");
                //If it doesn't exist, create the flag object
                PFObject *flaggedObject = [PFObject objectWithClassName:@"Flagged"];
                [flaggedObject setObject:userArg forKey:@"flaggedUser"];
                
                //Add current user to an array that is saved to this object
                NSMutableArray *usersWhoFlaggedArray = [[NSMutableArray alloc] init];
                NSString *currentUserObjectId = [PFUser currentUser].objectId;
                [usersWhoFlaggedArray addObject:currentUserObjectId];
                flaggedObject[@"UsersWhoFlagged"] = usersWhoFlaggedArray;
                flaggedObject[@"FlaggedCount"] = [NSNumber numberWithInteger: 1];
                
                [flaggedObject saveInBackground];
            }
        }];
    }
}

-(void)unflagForInappropriateContent:(PFUser *)userArg block:(void (^)(BOOL succeeded, NSError *error))completionHandler
{
    NSLog (@"unflagForInappropriateContent in MeViewController called!");
    /*
     if ([PFUser currentUser])
     {
     if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]])
     {
     return;
     }
     }
     */
    //Query for flagging objects aimed at 'userArg'
    if ([PFUser currentUser])
    {
        PFQuery *query2 = [PFQuery queryWithClassName:@"Flagged"];
        [query2 whereKey:@"flaggedUser" equalTo:userArg];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             NSLog (@"object4 = %@", [objects lastObject]);
             if ([objects count] == 0)
                 return;
             //If object exists then work with it
             if ([objects lastObject] != NULL)
             {
                 NSLog (@"Flagged object already exists.");
                 //proceed with removing the flagger and decrementing the counter
                 PFObject *flaggedObject = [objects lastObject];
                 
                 //See if user already flagged this person
                 NSMutableArray *usersWhoFlaggedArrayFromParse = [[NSMutableArray alloc] init];
                 usersWhoFlaggedArrayFromParse = flaggedObject[@"UsersWhoFlagged"];
                 NSMutableArray *usersWhoFlaggedArrayLocal = [[NSMutableArray alloc] init];
                 [usersWhoFlaggedArrayLocal addObjectsFromArray:usersWhoFlaggedArrayFromParse];
                 BOOL userAlreadyExistsInArrayOnParse = NO;
                 for (NSString *userWhoFlagged in usersWhoFlaggedArrayLocal)
                 {
                     NSLog (@"userWhoFlagged = %@", userWhoFlagged);
                     //If user's objectId is already added to the array then remove them
                     if ([userWhoFlagged isEqualToString:[PFUser currentUser].objectId])
                     {
                         [usersWhoFlaggedArrayLocal removeObject:userWhoFlagged];
                         //Decrement flag count
                         NSNumber *currentFlaggedCountNSNumber = flaggedObject[@"FlaggedCount"];
                         long int currentFlaggedCountInt = [currentFlaggedCountNSNumber integerValue];
                         flaggedObject[@"FlaggedCount"] = [NSNumber numberWithInteger: currentFlaggedCountInt - 1];
                     }
                 }
                 
                 //If flag count is 0 then remove the object from parse
                 NSNumber *flaggedCountNSNumber = flaggedObject [@"FlaggedCount"];
                 long int flaggedCountInt = [flaggedCountNSNumber integerValue];
                 
                 if (flaggedCountInt == 0)
                 {
                     [flaggedObject deleteInBackground];
                 }
                 else
                 {
                     [flaggedObject saveInBackground];
                 }

                 
             }
             //If object doesn't exist then create it
             else
             {
                 NSLog (@"Flagged object does not exist yet. Creating flagged object and setting 'FlaggedCount' to 1");
                 //If it doesn't exist, create the flag object
                 PFObject *flaggedObject = [PFObject objectWithClassName:@"Flagged"];
                 [flaggedObject setObject:userArg forKey:@"flaggedUser"];
                 
                 //Add current user to an array that is saved to this object
                 NSMutableArray *usersWhoFlaggedArray = [[NSMutableArray alloc] init];
                 NSString *currentUserObjectId = [PFUser currentUser].objectId;
                 [usersWhoFlaggedArray addObject:currentUserObjectId];
                 flaggedObject[@"UsersWhoFlagged"] = usersWhoFlaggedArray;
                 flaggedObject[@"FlaggedCount"] = [NSNumber numberWithInteger: 1];
                 
                 [flaggedObject saveInBackground];
             }
         }];
    }
}

-(void)addFlagButton
{
    dashboardView.flagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dashboardView.flagButton addTarget:self action:@selector(flagButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardView.flagButton setTitle:@"Report Abuse" forState:UIControlStateNormal];
    [dashboardView.flagButton sizeToFit];
    dashboardView.flagButton.center = CGPointMake(dashboardView.uploaderPhoto.center.x, dashboardView.uploaderPhoto.center.y + 65);
    [dashboardView addSubview:dashboardView.flagButton];
    
    if ([PFUser currentUser])
    {
        //Determine if you have already flagged this person to see how the button should look
        
        PFQuery *query = [PFQuery queryWithClassName:@"Flagged"];
        [query whereKey:@"flaggedUser" equalTo:userObject];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog (@"object = %@", [objects lastObject]);
            
            BOOL currentUserAlreadyFlaggedTargetUser = NO;
            
            if ([objects lastObject] != NULL)
            {
                PFObject *flaggedObject = [objects lastObject];
                
                //See if current user has already flagged this user
                NSMutableArray *usersWhoFlaggedParse = [[NSMutableArray alloc] init];
                NSMutableArray *usersWhoFlaggedLocal = [[NSMutableArray alloc] init];
                usersWhoFlaggedParse = flaggedObject[@"UsersWhoFlagged"];
                [usersWhoFlaggedLocal addObjectsFromArray:usersWhoFlaggedParse];
                
                for (NSString *userWhoFlagged in usersWhoFlaggedLocal)
                {
                    if ([userWhoFlagged isEqualToString:[PFUser currentUser].objectId])
                    {
                        currentUserAlreadyFlaggedTargetUser = YES;
                    }
                }
                
                if (currentUserAlreadyFlaggedTargetUser == YES)
                {
                    [dashboardView.flagButton setTitle:@"Unreport" forState:UIControlStateNormal];
                    dashboardView.flagButton.selected = NO;
                }
            }
            else
            {
                [dashboardView.flagButton setTitle:@"Report Abuse" forState:UIControlStateSelected];
                dashboardView.flagButton.selected = YES;
            }
        }];
    }
}

-(void)flagButtonTapped:(UIButton*)sender
{
    //Get other user
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userObject.objectId];
    NSArray * results = [query findObjects];
    PFUser *targetUser = [results lastObject];
    
    if (![dashboardView.flagButton isSelected]) {
        // Unfollow
        NSLog (@"unflag user");
        [dashboardView.flagButton setTitle:@"Report Abuse" forState:UIControlStateSelected];
        dashboardView.flagButton.selected = YES;
        [self unflagForInappropriateContent:targetUser block:^(BOOL succeeded, NSError *error)
        {
        }];
    }
    else
    {
        // Follow
        NSLog (@"Flag user");
        [dashboardView.flagButton setTitle:@"Unflag" forState:UIControlStateNormal];
        dashboardView.flagButton.selected = NO;
        [self flagForInappropriateContent:targetUser block:^(BOOL succeeded, NSError *error)
        {
        }];
    }
}

- (NSString *)getThreeLetterCountryCodeFromTwoLetterCountryCode:(NSString *)twoLetterCountryCode{
    // modified from http://stackoverflow.com/a/7520861
    NSDictionary *translateCodeDic = @{@"AF" : @"AFG",    // Afghanistan
                                       @"AL" : @"ALB",    // Albania
                                       @"AE" : @"ARE",    // U.A.E.
                                       @"AR" : @"ARG",    // Argentina
                                       @"AM" : @"ARM",    // Armenia
                                       @"AU" : @"AUS",    // Australia
                                       @"AT" : @"AUT",    // Austria
                                       @"AZ" : @"AZE",    // Azerbaijan
                                       @"BE" : @"BEL",    // Belgium
                                       @"BD" : @"BGD",    // Bangladesh
                                       @"BG" : @"BGR",    // Bulgaria
                                       @"BH" : @"BHR",    // Bahrain
                                       @"BA" : @"BIH",    // Bosnia and Herzegovina
                                       @"BY" : @"BLR",    // Belarus
                                       @"BZ" : @"BLZ",    // Belize
                                       @"BO" : @"BOL",    // Bolivia
                                       @"BR" : @"BRA",    // Brazil
                                       @"BN" : @"BRN",    // Brunei Darussalam
                                       @"CA" : @"CAN",    // Canada
                                       @"CH" : @"CHE",    // Switzerland
                                       @"CL" : @"CHL",    // Chile
                                       @"CN" : @"CHN",    // People's Republic of China
                                       @"CO" : @"COL",    // Colombia
                                       @"CR" : @"CRI",    // Costa Rica
                                       @"CZ" : @"CZE",    // Czech Republic
                                       @"DE" : @"DEU",    // Germany
                                       @"DK" : @"DNK",    // Denmark
                                       @"DO" : @"DOM",    // Dominican Republic
                                       @"DZ" : @"DZA",    // Algeria
                                       @"EC" : @"ECU",    // Ecuador
                                       @"EG" : @"EGY",    // Egypt
                                       @"ES" : @"ESP",    // Spain
                                       @"EE" : @"EST",    // Estonia
                                       @"ET" : @"ETH",    // Ethiopia
                                       @"FI" : @"FIN",    // Finland
                                       @"FR" : @"FRA",    // France
                                       @"FO" : @"FRO",    // Faroe Islands
                                       @"GB" : @"GBR",    // United Kingdom
                                       @"GE" : @"GEO",    // Georgia
                                       @"GR" : @"GRC",    // Greece
                                       @"GL" : @"GRL",    // Greenland
                                       @"GT" : @"GTM",    // Guatemala
                                       @"HK" : @"HKG",    // Hong Kong S.A.R.
                                       @"HN" : @"HND",    // Honduras
                                       @"HR" : @"HRV",    // Croatia
                                       @"HU" : @"HUN",    // Hungary
                                       @"ID" : @"IDN",    // Indonesia
                                       @"IN" : @"IND",    // India
                                       @"IE" : @"IRL",    // Ireland
                                       @"IR" : @"IRN",    // Iran
                                       @"IQ" : @"IRQ",    // Iraq
                                       @"IS" : @"ISL",    // Iceland
                                       @"IL" : @"ISR",    // Israel
                                       @"IT" : @"ITA",    // Italy
                                       @"JM" : @"JAM",    // Jamaica
                                       @"JO" : @"JOR",    // Jordan
                                       @"JP" : @"JPN",    // Japan
                                       @"KZ" : @"KAZ",    // Kazakhstan
                                       @"KE" : @"KEN",    // Kenya
                                       @"KG" : @"KGZ",    // Kyrgyzstan
                                       @"KH" : @"KHM",    // Cambodia
                                       @"KR" : @"KOR",    // Korea
                                       @"KW" : @"KWT",    // Kuwait
                                       @"LA" : @"LAO",    // Lao P.D.R.
                                       @"LB" : @"LBN",    // Lebanon
                                       @"LY" : @"LBY",    // Libya
                                       @"LI" : @"LIE",    // Liechtenstein
                                       @"LK" : @"LKA",    // Sri Lanka
                                       @"LT" : @"LTU",    // Lithuania
                                       @"LU" : @"LUX",    // Luxembourg
                                       @"LV" : @"LVA",    // Latvia
                                       @"MO" : @"MAC",    // Macao S.A.R.
                                       @"MA" : @"MAR",    // Morocco
                                       @"MC" : @"MCO",    // Principality of Monaco
                                       @"MV" : @"MDV",    // Maldives
                                       @"MX" : @"MEX",    // Mexico
                                       @"MK" : @"MKD",    // Macedonia (FYROM)
                                       @"MT" : @"MLT",    // Malta
                                       @"ME" : @"MNE",    // Montenegro
                                       @"MN" : @"MNG",    // Mongolia
                                       @"MY" : @"MYS",    // Malaysia
                                       @"NG" : @"NGA",    // Nigeria
                                       @"NI" : @"NIC",    // Nicaragua
                                       @"NL" : @"NLD",    // Netherlands
                                       @"NO" : @"NOR",    // Norway
                                       @"NP" : @"NPL",    // Nepal
                                       @"NZ" : @"NZL",    // New Zealand
                                       @"OM" : @"OMN",    // Oman
                                       @"PK" : @"PAK",    // Islamic Republic of Pakistan
                                       @"PA" : @"PAN",    // Panama
                                       @"PE" : @"PER",    // Peru
                                       @"PH" : @"PHL",    // Republic of the Philippines
                                       @"PL" : @"POL",    // Poland
                                       @"PR" : @"PRI",    // Puerto Rico
                                       @"PT" : @"PRT",    // Portugal
                                       @"PY" : @"PRY",    // Paraguay
                                       @"QA" : @"QAT",    // Qatar
                                       @"RO" : @"ROU",    // Romania
                                       @"RU" : @"RUS",    // Russia
                                       @"RW" : @"RWA",    // Rwanda
                                       @"SA" : @"SAU",    // Saudi Arabia
                                       @"CS" : @"SCG",    // Serbia and Montenegro (Former)
                                       @"SN" : @"SEN",    // Senegal
                                       @"SG" : @"SGP",    // Singapore
                                       @"SV" : @"SLV",    // El Salvador
                                       @"RS" : @"SRB",    // Serbia
                                       @"SK" : @"SVK",    // Slovakia
                                       @"SI" : @"SVN",    // Slovenia
                                       @"SE" : @"SWE",    // Sweden
                                       @"SY" : @"SYR",    // Syria
                                       @"TJ" : @"TAJ",    // Tajikistan
                                       @"TH" : @"THA",    // Thailand
                                       @"TM" : @"TKM",    // Turkmenistan
                                       @"TT" : @"TTO",    // Trinidad and Tobago
                                       @"TN" : @"TUN",    // Tunisia
                                       @"TR" : @"TUR",    // Turkey
                                       @"TW" : @"TWN",    // Taiwan
                                       @"UA" : @"UKR",    // Ukraine
                                       @"UY" : @"URY",    // Uruguay
                                       @"US" : @"USA",    // United States
                                       @"UZ" : @"UZB",    // Uzbekistan
                                       @"VE" : @"VEN",    // Bolivarian Republic of Venezuela
                                       @"VN" : @"VNM",    // Vietnam
                                       @"YE" : @"YEM",    // Yemen
                                       @"ZA" : @"ZAF",    // Zimbabwe
                                       };
    NSString *result = [translateCodeDic objectForKey:twoLetterCountryCode];
    return result;
}

/*
-(void)localNotificationForWorkoutMotivation
{
    NSLog (@"MeViewController localNotificationForWorkoutMotivation called");
    
    //Schedule local notification using the above NSString
    NSString *messageToSend = [NSString stringWithFormat:@"Attribute your last workout to someone? We'll send them a notification."];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    [notification setAlertBody:messageToSend];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
*/
-(void)dialogueBoxForWorkoutMotivation
{
    NSLog (@"MeViewController dialogueBoxForWorkoutMotivation called");
    
 //   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MotivationDialogueBoxAlreadyShownToday"] == NO)
 //   {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MotivationDialogueBoxAlreadyShownToday"];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Motivation"
                                                                       message:@"Nice activity recently! Care to attribute your motiviation to someone? We'll send them a notification."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       MotivationFriendsListViewController *motivationControllerSubClass = [[MotivationFriendsListViewController alloc] init];
                                       
                                       [self.navigationController presentViewController:motivationControllerSubClass animated:YES completion:nil];
                                       NSLog (@"motivationFriendsSubClass should be presented");
                                   }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       //Do some thing here
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        [alert addAction:okAction];
        [alert addAction:noAction];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
  //  }
}

//Used to help generate random username
-(void)saveInitialAndLastNameToParse
{
    //Take first letter of first name
    NSString *firstName = [userObject objectForKey:@"first_name"];
    NSString *firstLetter = [firstName substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    NSLog (@"firstLetter = %@", firstLetter);
    
    //Take last name
    NSString *lastName = [userObject objectForKey:@"last_name"];
    NSLog (@"lastName = %@", lastName);
    
    NSString *initialAndLastName = [NSString stringWithFormat:@"%@%@", firstLetter, lastName];
    
    if ([PFUser currentUser])
    {
        if (userObject == [PFUser currentUser])
        {
            if (userObject[@"firstInitialLastName"] == nil)
            {
                NSLog (@"saving firstInitialLastName to parse");
                userObject[@"firstInitialLastName"] = initialAndLastName;
                [userObject saveInBackground];
            }
            
            //In case user's first_name and last_name on Parse are null
            if (firstName == NULL || lastName == NULL)
            {
                initialAndLastName = [NSString stringWithFormat:@"Guest"];
            }
        }
    }
}

-(void)randomlyGenerateUsername
{
    NSLog (@"randomlyGenerateUsername called!");
    
    if ([PFUser currentUser])
    {
        if (userObject == [PFUser currentUser])
        {
            //User NSUserDefaults to determine if the user has ever changed their username.
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UsernameManuallySet"] == NO)
            {
                NSLog (@"creating random username and saving to Parse");
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UsernameManuallySet"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //If not then proceed with the user name randomization...
                
                //Take first letter of first name
                NSString *firstName = [userObject objectForKey:@"first_name"];
                NSString *firstLetter = [firstName substringToIndex:1];
                firstLetter = [firstLetter uppercaseString];
                NSLog (@"firstLetter = %@", firstLetter);
                
                //Take last name
                NSString *lastName = [userObject objectForKey:@"last_name"];
                NSLog (@"lastName = %@", lastName);
            
                NSString *initialAndLastName = [NSString stringWithFormat:@"%@%@", firstLetter, lastName];

                NSLog (@"initialAndLastName = %@", initialAndLastName);
            
                //In case user's first_name and last_name on Parse are null
                if (firstName == NULL || lastName == NULL)
                {
                    initialAndLastName = [NSString stringWithFormat:@"Guest"];
                }
                
                //Determine how many other people on Parse have the same first initial last name you do
                PFQuery *query = [PFUser query];
                [query whereKey:@"firstInitialLastName" equalTo:initialAndLastName];
                [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                    if (!error)
                    {
                        NSLog (@"# of people with the same firstInitialLastName as you = %li", [objects count]);
                        
                        //Add the number of people plus 1 to the end of your username
                        NSString *numToAddToFirstInitialLastName = [NSString stringWithFormat:@"%li", [objects count] + 1];
                        
                        //save it to Parse as your username
                        NSString *usernameFinalForm = [NSString stringWithFormat:@"%@%@", initialAndLastName, numToAddToFirstInitialLastName];
                        NSString *fullName = userObject[@"full_name"];
                        
                        userObject[@"username"] = usernameFinalForm;
                        //Save a lowercase form of the username in the parse key "username_lowercase" for easy searching
                        userObject[@"username_lowercase"] = [usernameFinalForm lowercaseString];
                        //Save lowercase form of full_name in parse key "full_name_lowercase" for easy searching
                        userObject[@"full_name_lowercase"] = [fullName lowercaseString];
                        [userObject saveEventually];
                        
                        //Update the navBar title as well
                        usernameLabel.text = [NSString stringWithFormat:@"%@", usernameFinalForm];
                        navControllerTitleLabel.text = [userObject objectForKey:@"username"];
                        [navControllerTitleLabel sizeToFit];
                    }
                }];
            }
        }
    }
}

//Calling this method in queryForTable will make the indicator invisible
- (void)stylePFLoadingViewTheHardWay
{
    UIColor *labelTextColor = [UIColor clearColor];
    UIColor *labelShadowColor = [UIColor clearColor];
    UIActivityIndicatorViewStyle activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    // go through all of the subviews until you find a PFLoadingView subclass
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            // find the loading label and loading activity indicator inside the PFLoadingView subviews
            for (UIView *loadingViewSubview in subview.subviews) {
                if ([loadingViewSubview isKindOfClass:[UILabel class]])
                {
                    UILabel *label = (UILabel *)loadingViewSubview;
                    {
                        label.textColor = labelTextColor;
                        label.shadowColor = labelShadowColor;
                    }
                }
                
                if ([loadingViewSubview isKindOfClass:[UIActivityIndicatorView class]])
                {
                    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)loadingViewSubview;
                    activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
                    activityIndicatorView.hidden = YES;
                }
            }
        }
    }
}

-(void) queryNumberOfFriendsFollowingFollowers:(PFUser*)userObjectArg completionHandler:(void (^)(double, NSError *))completionHandler
{
    //Determine the number of friends you have
    PFQuery *friendsQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [friendsQuery whereKey:@"fromUser" equalTo:userObjectArg];
    [friendsQuery whereKey:@"toUser" notEqualTo:userObjectArg];
   // [friendsQuery whereKey:@"saved_to_list" equalTo:@"Following"];
    [friendsQuery whereKey:@"FriendStatus" equalTo: @"Friends"];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            NSLog (@"userObjectName = %@ number of friends = %li", userObjectArg[@"first_name"], [objects count]);
            numberOfFriends = [objects count];
        }
        
        //Determine the number of people you're following
        PFQuery *followingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [followingQuery whereKey:@"fromUser" equalTo:userObjectArg];
        [followingQuery whereKey:@"toUser" notEqualTo:userObjectArg];
        [followingQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                // NSLog (@"number of people you're following = %li", [objects count]);
                 numberOfPeopleYouAreFollowing = [objects count];
             }
             
             //Determine the number of followers you have
             PFQuery *followersQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
             [followersQuery whereKey:@"fromUser" notEqualTo:userObjectArg];
             [followersQuery whereKey:@"toUser" equalTo:userObjectArg];
             [followersQuery whereKey:@"saved_to_list" equalTo:@"Following"];
             [followersQuery whereKey:@"fromUserToUserSame" notEqualTo:@"YES"];
             [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error)
                  {
                     // NSLog (@"number of followers = %li", [objects count]);
                      numberOfFollowers = [objects count];
                      completionHandler(YES, nil);
                  }
              }];
         }];
    }];
}

-(void)followAndFriendYourself
{
    NSLog (@"followAndFriendYourself called!");
    
    if ([PFUser currentUser])
    {
        //If current User is already added to the list then dont add them again
        PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
        [query whereKeyExists:@"saved_to_list"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *friendActivities, NSError *error) {
            
            // If currentUser is already added to the lists dont add them again
            if ([friendActivities count] > 0)
            {
                NSLog (@"Current user already added to lists.  Not adding them again");
                return;
            }
            else
            {
                NSLog (@"Current user NOT added to lists.  Adding them now!");
                //Follow yourself
                PFObject *followYourself = [PFObject objectWithClassName:kPAPActivityClassKey];
                [followYourself setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                [followYourself setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                [followYourself setObject:@"Following" forKey:@"saved_to_list"];
                
                PFACL *followYourselfACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [followYourselfACL setPublicReadAccess:YES];
                [followYourselfACL setPublicWriteAccess:YES];
                followYourself.ACL = followYourselfACL;
                
                [followYourself saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog (@"Followed yourself Successfully!");
                    }
                    else
                    {
                        NSLog (@"Followed yourself NOT Successful!");
                    }
                }];
                
                //Friend yourself
                NSLog (@"Current user NOT added to lists.  Adding them now!");
                PFObject *friendYourself = [PFObject objectWithClassName:kPAPActivityClassKey];
                [friendYourself setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                [friendYourself setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                [friendYourself setObject:@"Following" forKey:@"saved_to_list"];
                [friendYourself setObject:@"Friends" forKey:@"FriendStatus"];
                [friendYourself setObject:@"YES" forKey:@"fromUserToUserSame"]; //set this so that the HomeView 'Yesterday' tab only shows one of you
                
                PFACL *friendYourselfACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [friendYourselfACL setPublicReadAccess:YES];
                [friendYourselfACL setPublicWriteAccess:YES];
                friendYourself.ACL = friendYourselfACL;
                
                [friendYourself saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog (@"Friended yourself Successfully!");
                        [self loadObjects];
                        [self.tableView reloadData];
                    }
                    else
                    {
                        NSLog (@"Friended yourself NOT Successful!");
                    }
                }];
            }
        }];
    }
}

-(void) chatButtonTapped:(UIButton *)sender
{
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //Get current user
    PFUser *user1 = [PFUser currentUser];
    
    //Get other user
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userObject.objectId];
    NSArray * results = [query findObjects];
    PFUser *user2 = [results lastObject];
    
    NSString *roomId = StartPrivateChat(user1, user2);
    //-----------------------------------------------------------------------------------------------------------------------------------------
    ChatView *chatView = [[ChatView alloc] initWith:roomId];
    
    //Add navBar to chatView
    UINavigationController *navBar = [[UINavigationController alloc]initWithRootViewController:chatView];
    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}

-(void) showUpdatingLabel
{
    dashboardView.todayDelimiterLabel.hidden = YES;
    dashboardView.updatingLabel.hidden = NO;
}

-(void)callHealthQueries
{
    NSLog (@"callHealthQueries called!");
    NSLog (@"isFirstTimeHealthQueriesBeingRunToday = %i", [self isFirstTimeHealthQueriesBeingRunToday]);
    
    if ([self isFirstTimeHealthQueriesBeingRunToday])
    {
        //Reset TopScoreAlreadyAnnounced
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TopScoreAlreadyAnnounced"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    //    [self shiftHealthStatsDownADayInParse];
    //    [self shiftHeartRatesDownADayInParse];
    }

    dashboardView.todayDelimiterLabel.hidden = YES;
    dashboardView.updatingLabel.hidden = NO;
        
    HealthMethods *healthMethods = [[HealthMethods alloc] init];
    //Calculate all of your friends' timeRelativeToUserListRankingScore
    //[healthMethods calculateTimeRelativeToUserListRankingScore];
    //Querying steps does returns all steps for last 6 days, and calorie burn for last 6 days, and minutes of exercise for the last 6 days, and then the last 6 days of heart rate samples
    [healthMethods queryTotalStepsForToday:self unit:[HKUnit countUnit]];
}

-(BOOL)isFirstTimeHealthQueriesBeingRunToday
{
    NSLog (@"isFirstTimeHealthQueriesBeingRunToday called!");
    NSLog (@"todaysDateFormatted = %@", [self todaysDateFormatted]);
    NSLog (@"DateWhenHealthQueriesLastRun = %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"DateWhenHealthQueriesLastRun"]);
        
    //If today’s date is not the same as whats saved in NSUserDefaults then its a new day.
    if ([[self todaysDateFormatted] isEqualToString: [[NSUserDefaults standardUserDefaults] stringForKey:@"DateWhenHealthQueriesLastRun"]])
    {
        return false;
    }
    else
    {
        //If this is the first time healthQueries are being run today then allow a motivation dialogue box to be shown today
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MotivationDialogueBoxAlreadyShownToday"];

        return true;
    }
}

-(NSString*)todaysDateFormatted
{
    NSDate* now = [NSDate date];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
    return [df stringFromDate:now];
}

-(NSDate*)todaysDateNSDate
{
    return [NSDate date];
}

-(void)shiftHeartRatesDownADayInParse
{
    NSLog (@"shiftHeartRatesDownADayInParse called!");
    
    if ([PFUser currentUser])
    {
        //Shift RHR's down a day in Parse
        //Shift RHR_5_days_ago down
        NSNumber *rhr5DaysAgo = [[PFUser currentUser] objectForKey:@"RHR_5_days_ago"];
        [[PFUser currentUser] setObject:rhr5DaysAgo forKey:@"RHR_6_days_ago"];
        //Shift RHR_4_days_ago down
        NSNumber *rhr4DaysAgo = [[PFUser currentUser] objectForKey:@"RHR_4_days_ago"];
        [[PFUser currentUser] setObject:rhr4DaysAgo forKey:@"RHR_5_days_ago"];
        //Shift RHR_3_days_ago down
        NSNumber *rhr3DaysAgo = [[PFUser currentUser] objectForKey:@"RHR_3_days_ago"];
        [[PFUser currentUser] setObject:rhr3DaysAgo forKey:@"RHR_4_days_ago"];
        //Shift RHR_2_days_ago down
        NSNumber *rhr2DaysAgo = [[PFUser currentUser] objectForKey:@"RHR_2_days_ago"];
        [[PFUser currentUser] setObject:rhr2DaysAgo forKey:@"RHR_3_days_ago"];
        //Shift RHR_1_day_ago down
        NSNumber *rhr1DayAgo = [[PFUser currentUser] objectForKey:@"RHR_1_day_ago"];
        [[PFUser currentUser] setObject:rhr1DayAgo forKey:@"RHR_2_days_ago"];
        
        //Shift HRR's down a day in Parse
        //Shift HRR_5_days_ago down
        NSNumber *hrr5DaysAgo = [[PFUser currentUser] objectForKey:@"HRR_5_days_ago"];
        [[PFUser currentUser] setObject:hrr5DaysAgo forKey:@"HRR_6_days_ago"];
        //Shift HRR_4_days_ago down
        NSNumber *hrr4DaysAgo = [[PFUser currentUser] objectForKey:@"HRR_4_days_ago"];
        [[PFUser currentUser] setObject:hrr4DaysAgo forKey:@"HRR_5_days_ago"];
        //Shift HRR_3_days_ago down
        NSNumber *hrr3DaysAgo = [[PFUser currentUser] objectForKey:@"HRR_3_days_ago"];
        [[PFUser currentUser] setObject:hrr3DaysAgo forKey:@"HRR_4_days_ago"];
        //Shift HRR_2_days_ago down
        NSNumber *hrr2DaysAgo = [[PFUser currentUser] objectForKey:@"HRR_2_days_ago"];
        [[PFUser currentUser] setObject:hrr2DaysAgo forKey:@"HRR_3_days_ago"];
        //Shift HRR_1_day_ago down
        NSNumber *hrr1DayAgo = [[PFUser currentUser] objectForKey:@"HRR_1_day_ago"];
        [[PFUser currentUser] setObject:hrr1DayAgo forKey:@"HRR_2_days_ago"];
        
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_1_day_ago"];
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_1_day_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"set HRR_1_day_ago & RHR_1_day_ago to nil in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
    }
}

-(void)shiftHealthStatsDownADayInParse
{
    NSLog (@"shiftHealthStatsDownADayInParse called!");
    
    if ([PFUser currentUser])
    {
        //Shift step count down a day in Parse
        //Shift NumberOfStepsFiveDaysAgo down
        NSNumber *stepCountFiveDaysAgo = [[PFUser currentUser] objectForKey:@"NumberOfStepsFiveDaysAgo"];
        [[PFUser currentUser] setObject:stepCountFiveDaysAgo forKey:@"NumberOfStepsSixDaysAgo"];
        //Shift NumberOfStepsFourDaysAgo down
        NSNumber *stepCountFourDaysAgo = [[PFUser currentUser] objectForKey:@"NumberOfStepsFourDaysAgo"];
        [[PFUser currentUser] setObject:stepCountFourDaysAgo forKey:@"NumberOfStepsFiveDaysAgo"];
        //Shift NumberOfStepsThreeDaysAgo down
        NSNumber *stepCountThreeDaysAgo = [[PFUser currentUser] objectForKey:@"NumberOfStepsThreeDaysAgo"];
        [[PFUser currentUser] setObject:stepCountThreeDaysAgo forKey:@"NumberOfStepsFourDaysAgo"];
        //Shift NumberOfStepsTwoDaysAgo down
        NSNumber *stepCountTwoDaysAgo = [[PFUser currentUser] objectForKey:@"NumberOfStepsTwoDaysAgo"];
        [[PFUser currentUser] setObject:stepCountTwoDaysAgo forKey:@"NumberOfStepsThreeDaysAgo"];
        //Shift NumberOfStepsYesterday down
        NSNumber *stepCountOneDayAgo = [[PFUser currentUser] objectForKey:@"NumberOfStepsYesterday"];
        [[PFUser currentUser] setObject:stepCountOneDayAgo forKey:@"NumberOfStepsTwoDaysAgo"];
        //Shift NumberOfStepsToday down
        NSNumber *stepCountToday = [[PFUser currentUser] objectForKey:@"NumberOfStepsToday"];
        [[PFUser currentUser] setObject:stepCountToday forKey:@"NumberOfStepsYesterday"];
        
        //Shift exercise minutes down a day in Parse
        //Shift MinutesOfExerciseFiveDaysAgo down
        NSNumber *minOfExerciseFiveDaysAgo = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseFiveDaysAgo"];
        [[PFUser currentUser] setObject:minOfExerciseFiveDaysAgo forKey:@"MinutesOfExerciseSixDaysAgo"];
        //Shift MinutesOfExerciseFourDaysAgo down
        NSNumber *minOfExerciseFourDaysAgo = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseFourDaysAgo"];
        [[PFUser currentUser] setObject:minOfExerciseFourDaysAgo forKey:@"MinutesOfExerciseFiveDaysAgo"];
        //Shift MinutesOfExerciseThreeDaysAgo down
        NSNumber *minOfExerciseThreeDaysAgo = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseThreeDaysAgo"];
        [[PFUser currentUser] setObject:minOfExerciseThreeDaysAgo forKey:@"MinutesOfExerciseFourDaysAgo"];
        //Shift MinutesOfExerciseTwoDaysAgo down
        NSNumber *minOfExerciseTwoDaysAgo = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseTwoDaysAgo"];
        [[PFUser currentUser] setObject:minOfExerciseTwoDaysAgo forKey:@"MinutesOfExerciseThreeDaysAgo"];
        //Shift MinutesOfExerciseOneDayAgo down
        NSNumber *minOfExerciseOneDayAgo = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseOneDayAgo"];
        [[PFUser currentUser] setObject:minOfExerciseOneDayAgo forKey:@"MinutesOfExerciseTwoDaysAgo"];
        //Shift MinutesOfExerciseToday down
        NSNumber *minOfExerciseToday = [[PFUser currentUser] objectForKey:@"MinutesOfExerciseToday"];
        [[PFUser currentUser] setObject:minOfExerciseToday forKey:@"MinutesOfExerciseOneDayAgo"];
        
        //Shift Calories down a day in Parse
        //Shift CaloriesBurnedFiveDaysAgo down
        NSNumber *caloriesBurnedFiveDaysAgo = [[PFUser currentUser] objectForKey:@"CaloriesBurnedFiveDaysAgo"];
        [[PFUser currentUser] setObject:caloriesBurnedFiveDaysAgo forKey:@"CaloriesBurnedSixDaysAgo"];
        //Shift CaloriesBurnedFourDaysAgo down
        NSNumber *caloriesBurnedFourDaysAgo = [[PFUser currentUser] objectForKey:@"CaloriesBurnedFourDaysAgo"];
        [[PFUser currentUser] setObject:caloriesBurnedFourDaysAgo forKey:@"CaloriesBurnedFiveDaysAgo"];
        //Shift CaloriesBurnedThreeDaysAgo down
        NSNumber *caloriesBurnedThreeDaysAgo = [[PFUser currentUser] objectForKey:@"CaloriesBurnedThreeDaysAgo"];
        [[PFUser currentUser] setObject:caloriesBurnedThreeDaysAgo forKey:@"CaloriesBurnedFourDaysAgo"];
        //Shift CaloriesBurnedTwoDaysAgo down
        NSNumber *caloriesBurnedTwoDaysAgo = [[PFUser currentUser] objectForKey:@"CaloriesBurnedTwoDaysAgo"];
        [[PFUser currentUser] setObject:caloriesBurnedTwoDaysAgo forKey:@"CaloriesBurnedThreeDaysAgo"];
        //Shift CaloriesBurnedOneDayAgo down
        NSNumber *caloriesBurnedOneDayAgo = [[PFUser currentUser] objectForKey:@"CaloriesBurnedOneDayAgo"];
        [[PFUser currentUser] setObject:caloriesBurnedOneDayAgo forKey:@"CaloriesBurnedTwoDaysAgo"];
        //Shift CaloriesBurnedOneDayAgo down
        NSNumber *caloriesBurnedToday = [[PFUser currentUser] objectForKey:@"CaloriesBurnedToday"];
        [[PFUser currentUser] setObject:caloriesBurnedToday forKey:@"CaloriesBurnedOneDayAgo"];
        
        //Shift listRankingScore down a day
        NSNumber *listRankingScore = [[PFUser currentUser] objectForKey:@"listRankingScore"];
        [[PFUser currentUser] setObject:listRankingScore forKey:@"yesterdaysListRankingScore"];

        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"Finished shifting steps, exercise, and calorie stats down a day = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
    }
}

-(BOOL)allHealthDataSharedByUser
{
    //Heart rates saved to NSUserDefaults
    /*
    int numOfTodaysHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfTodaysHeartRateSamplesInt"];
    NSLog (@"numOfTodaysHeartRateSamplesInt = %i", numOfTodaysHeartRateSamplesInt);
    int numOfYesterdaysHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfYesterdaysHeartRateSamplesInt"];
    NSLog (@"numOfYesterdaysHeartRateSamplesInt = %i", numOfYesterdaysHeartRateSamplesInt);
    int numOfTwoDaysAgoHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfTwoDaysAgoHeartRateSamplesInt"];
    NSLog (@"numOfTwoDaysAgoHeartRateSamplesInt = %i", numOfTwoDaysAgoHeartRateSamplesInt);
    int numOfThreeDaysAgoHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfThreeDaysAgoHeartRateSamplesInt"];
    NSLog (@"numOfThreeDaysAgoHeartRateSamplesInt = %i", numOfThreeDaysAgoHeartRateSamplesInt);
    int numOfFourDaysAgoHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfFourDaysAgoHeartRateSamplesInt"];
    NSLog (@"numOfFourDaysAgoHeartRateSamplesInt = %i", numOfFourDaysAgoHeartRateSamplesInt);
    int numOfFiveDaysAgoHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfFiveDaysAgoHeartRateSamplesInt"];
    NSLog (@"numOfFiveDaysAgoHeartRateSamplesInt = %i", numOfFiveDaysAgoHeartRateSamplesInt);
    int numOfSixDaysAgoHeartRateSamplesInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numOfSixDaysAgoHeartRateSamplesInt"];
    NSLog (@"numOfSixDaysAgoHeartRateSamplesInt = %i", numOfSixDaysAgoHeartRateSamplesInt);
    */
    
    //Calories saved to NSUserDefaults
    int caloriesBurnedOneDayAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedOneDayAgo"];
    NSLog (@"caloriesBurnedOneDayAgo = %i", caloriesBurnedOneDayAgo);
    int caloriesBurnedTwoDaysAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedTwoDaysAgo"];
    NSLog (@"caloriesBurnedTwoDaysAgo = %i", caloriesBurnedTwoDaysAgo);
    int caloriesBurnedThreeDaysAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedThreeDaysAgo"];
    NSLog (@"caloriesBurnedThreeDaysAgo = %i", caloriesBurnedThreeDaysAgo);
    int caloriesBurnedFourDaysAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedFourDaysAgo"];
    NSLog (@"caloriesBurnedFourDaysAgo = %i", caloriesBurnedFourDaysAgo);
    int caloriesBurnedFiveDaysAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedFiveDaysAgo"];
    NSLog (@"caloriesBurnedFiveDaysAgo = %i", caloriesBurnedFiveDaysAgo);
    int caloriesBurnedSixDaysAgo = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CaloriesBurnedSixDaysAgo"];
    NSLog (@"caloriesBurnedSixDaysAgo = %i", caloriesBurnedSixDaysAgo);
    NSLog (@"usersAge = %li", (long)[self usersAge]);
    
    if (caloriesBurnedOneDayAgo > 0 || caloriesBurnedTwoDaysAgo > 0 || caloriesBurnedThreeDaysAgo > 0 || caloriesBurnedFourDaysAgo > 0 || caloriesBurnedFiveDaysAgo > 0 || caloriesBurnedSixDaysAgo > 0 || [self usersAge] > 0)
    {
        NSLog (@"allHealthDataSharedByUser = YES");
        
        return YES;
    }
    else
    {
        NSLog (@"allHealthDataSharedByUser = NO");
        return NO;
    }
}

-(void)removeColoredCircles
{
    [dashboardView.todayDelimiterLabel removeFromSuperview];
    [dashboardView.updatingLabel removeFromSuperview];

    [dashboardView.blueCircleView removeFromSuperview];
    [dashboardView.blueCircleStepsLabel removeFromSuperview];
    [dashboardView.blueCircleSmallStepsLabel removeFromSuperview];
    [dashboardView.blueCircleNumOfStepsTodayLabel removeFromSuperview];
    
    [dashboardView.redCircleView removeFromSuperview];
    [dashboardView.redCircleExerciseLabel removeFromSuperview];
    [dashboardView.redCircleSmallMinLabel removeFromSuperview];
    [dashboardView.redCircleMinOfExerciseTodayLabel removeFromSuperview];
    
    [dashboardView.orangeCircleView removeFromSuperview];
    [dashboardView.orangeCircleCaloriesLabel removeFromSuperview];
    [dashboardView.orangeCircleSmallMinLabel removeFromSuperview];
    [dashboardView.orangeCircleNumOfCaloriesTodayLabel removeFromSuperview];
}

-(void) addColoredCircles
{
    NSLog (@"addColoredCircles in MeViewController called!");
    
    if (askToShareData.hidden == YES && calculatingFitnessRatingLabel.hidden == YES)
    {
        [self removeColoredCircles];
        
        [self addBlueCircle: userObject];
        [self addRedCircle: userObject];
        [self addOrangeCircle: userObject];
        [self addTodayDelimiterLabel];
    }
}

-(BFTask *) loadObjects
{
    NSLog (@"MeViewController loadObjects");
    
    //Get array of facebook friend's objectIds here
    [self saveArrayOfFacebookFriendsObjectIdsToUserDefaults];
    
    [self shareHealthDataOrCreateButton];
    
    return [super loadObjects];
}

-(void) saveArrayOfFacebookFriendsObjectIdsToUserDefaults
{
    NSMutableString *facebookRequest = [NSMutableString new];
    [facebookRequest appendString:@"/me/friends"];
    [facebookRequest appendString:@"?limit=100"];
    
    [facebookFriendsObjectIdsArray removeAllObjects];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:facebookRequest
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        // result will contain an array with your user's friends in the "data" key
        NSArray *friendObjects = [result objectForKey:@"data"];
        for (id friendObject in friendObjects)
        {
            NSString *friendsFacebookId = (NSString*)[friendObject valueForKey:@"id"];
            NSLog (@"friendsFacebookId = %@", friendsFacebookId);
            PFQuery *query = [PFUser query];
            [query whereKey:@"FacebookID" equalTo:friendsFacebookId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (!error)
                {
                    PFObject *facebookFriend = [objects lastObject];
                    NSString *facebookFriendsObjectId = facebookFriend.objectId;
                    NSLog (@"facebookFriendsObjectId = %@", facebookFriendsObjectId);
                    if (facebookFriendsObjectId)
                    {
                        [facebookFriendsObjectIdsArray addObject: facebookFriendsObjectId];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:facebookFriendsObjectIdsArray forKey:@"facebookFriendsObjectIdsArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}

//This methods should populate health stats for current user if the appropriate data is shared.  If data is not shared, create 'share' button
-(void)shareHealthDataOrCreateButton
{
    NSLog (@"shareHealthDataOrCreateButton called!");
    
    if ([PFUser currentUser])
    {
        //Check for heart rate readings, calories, DOB, gender, and steps
        if ([self allHealthDataSharedByUser])
        {
            //Run health query
            if (userObject == [PFUser currentUser])
            {
                //addDashboardView is called within HealthMethods->calculateFitnessRating, this also adds the colored circles after the health query is done
                [self callHealthQueries];
            }
        }
        else
        {
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
            {
                [self displayShareDataRequest];
            }
        }
    }
}

-(void)displayShareDataRequest
{
    NSLog (@"from MeViewController: user has not shared all health data");
    
    if (userObject)
    {
        //This is an effort to fix a bug where restoring the app will cause the 'askToShareData' label to show on top of the colored bubbles
        [self removeColoredCircles];
        
        //Configure message
        askToShareData.hidden = NO;
        askToShareData.text = @"To use We Get Fit you must agree to share your HealthKit data. Your health data will be stored on secure, 3rd party servers to enable competitions with other We Get Fit users";
        askToShareData.backgroundColor = [UIColor clearColor];
        askToShareData.font = [UIFont boldSystemFontOfSize:16.0];
        askToShareData.editable = NO;
        //Resize frame size to match contents
        askToShareData.scrollEnabled = NO;
        [askToShareData sizeToFit];

        //Create message and button on an empty dashboard telling the user to tap the button to share their health data
        shareHealthDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [shareHealthDataButton addTarget:self action:@selector(shareHealthDataButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [shareHealthDataButton setTitle:@"OK" forState:UIControlStateNormal];
        shareHealthDataButton.frame = CGRectMake(self.view.frame.size.width/4, -150, 160.0, 40.0);
        [self.view addSubview:shareHealthDataButton];
        
        //Add 'Why, why?' button beneath the OK button which will bring up the WhyHealthKitView
        UIButton *waitWhyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [waitWhyButton addTarget:self action:@selector(waitWhyButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [waitWhyButton setTitle:@"Wait, Please Explain" forState:UIControlStateNormal];
        waitWhyButton.frame = CGRectMake(self.view.frame.size.width/4, -100, 160.0, 40.0);
        [self.view addSubview:waitWhyButton];
    }
}

-(void)waitWhyButtonTapped: (UIButton*)sender
{
    WhyHealthKitViewController *viewController = [[WhyHealthKitViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)shareHealthDataButtonTapped: (UIButton*)sender
{
    NSLog (@"shareHealthDataButtonTapped");
    
    //Remove labels asking user to share health data and remove the OK button
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass: [UITextView class]] || [view isKindOfClass: [UIButton class]])
            view.hidden = YES;
    }
    
    //Start animating progress Indicator
    [progressIndicator startAnimating];
    
    //This is an effort to fix a bug where restoring the app will cause the 'askToShareData' label to show on top of the colored bubbles
    [self removeColoredCircles];
    
    //configure label telling the user that you're calculating their fitness rating
    calculatingFitnessRatingLabel.hidden = NO;
    calculatingFitnessRatingLabel.text = @"Calculating Recent Fitness Activity...";
    calculatingFitnessRatingLabel.backgroundColor = [UIColor clearColor];
    calculatingFitnessRatingLabel.font = [UIFont boldSystemFontOfSize:16.0];
    //Resize frame size to match contents
    [calculatingFitnessRatingLabel sizeToFit];
    calculatingFitnessRatingLabel.scrollEnabled = NO;
    
    //Request permission to Healthkit data
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
            if (error)
                NSLog (@"health info request error = %@", error);
                
                return;
            }
            
            if (success)
            {
                //This is an effort to fix a bug where restoring the app will cause the 'askToShareData' label to show on top of the colored bubbles
                [self removeColoredCircles];
                
                //If success then run health queries and try adding the dashboard again
                HealthMethods *healthMethods = [[HealthMethods alloc] init];
                //Querying steps does returns all steps for last 6 days, and calorie burn for last 6 days, and minutes of exercise for the last 6 days, and then the last 6 days of heart rate samples
                [healthMethods queryTotalStepsForToday:self unit:[HKUnit countUnit]];
                calculatingFitnessRatingLabel.hidden = NO;
            }
        }];
    }
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    
    NSLog (@"dataTypesToRead method running");
    
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *bodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *biologicalSex = [HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierBiologicalSex];
    HKCharacteristicType *age = [HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];    HKQuantityType *caloriesBurned = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *distanceWalkingRunning = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKObjectType *runningType = [HKObjectType workoutType];
    
    return [NSSet setWithObjects:heartRateType, biologicalSex, age, heightType, weightType, stepsType, bodyMass, caloriesBurned, distanceWalkingRunning, runningType, nil];
}

//Returns user's age.  Method to save user's height and weight is in HealthMethods class
-(NSInteger)usersAge
{
    NSLog (@"usersAge called!");
    
    // Set the user's age unit (years).
    NSError *error;
    NSDate *dateOfBirth = [healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth)
    {
        NSLog (@"dateOfBirth not available");
        return 0;
    }
    else
    {
        NSLog (@"dateOfBirth = %@", dateOfBirth);
        
        // Compute the age of the user.
        NSDate *now = [NSDate date];
        
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        
        NSInteger usersAge = [ageComponents year];
        
        //Save usersAge to NSUserDefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:usersAge forKey:@"usersAge"];
        [userDefaults synchronize];
        
        if ([PFUser currentUser])
        {
            //Set user's age in Parse
            [[PFUser currentUser] setObject:[NSNumber numberWithInteger:usersAge] forKey:@"age"];
            [[PFUser currentUser] saveInBackground];
        }
        
        return usersAge;
    }
}

// Sent to the delegate when a PFUser is logged in
- (void)logInViewController:(MyLoginViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog (@"logInViewController:(MyLoginViewController *)logInController didLogInUser:(PFUser *)user");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"id, name, first_name, last_name, email, gender, picture"}];
    
    if ([PFUser currentUser])
    {
        if ([FBSDKAccessToken currentAccessToken]) {
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                 if (!error)
                 {
                     NSLog(@"fetched user:%@", result);
                     
                     NSLog (@"FBRequestConnection");
                    
                     if (userObject == nil)
                         if ([PFUser currentUser])
                             userObject = [PFUser currentUser];
                     
                     NSString *facebookId = [result objectForKey:@"id"];
                     [[PFUser currentUser] setObject:facebookId forKey:@"FacebookID"];
                     
                     //Save user's full name in 'displayName' field
                     NSString *facebookFullName = [result objectForKey:@"name"];
                     [[PFUser currentUser] setObject:facebookFullName forKey:@"full_name"];
                     
                     //Save user's first name in 'first_name' field
                     NSString *facebookFirstName = [result objectForKey:@"first_name"];
                     [[PFUser currentUser] setObject:facebookFirstName forKey:@"first_name"];
                     
                     //Save user's last name in last_name' field
                     NSString *facebookLastName = [result objectForKey:@"last_name"];
                     [[PFUser currentUser] setObject:facebookLastName forKey:@"last_name"];
                     
                     //Save user's email in facebook_email field
                     NSString *facebookEmail = [result objectForKey:@"email"];
                     [[PFUser currentUser] setObject:facebookEmail forKey:@"facebook_email"];
                     
                     //Save user's large facebook photo to parse
                     NSString *facebookId4 = [[PFUser currentUser] objectForKey:@"FacebookID"];
                     NSString *profilePictureURL4 = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=720&height=720", facebookId4];
                     NSData *profilePictureData4 = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL4]];
                     PFFile *imageFile = [PFFile fileWithName:@"Profileimage.png" data:profilePictureData4];
                     [[PFUser currentUser] setObject:imageFile forKey:@"profile_photo"];

                     //Save user's gender in 'gender' field
                     NSString *facebookGender = [result objectForKey:@"gender"];
                     [[PFUser currentUser] setObject:facebookGender forKey:@"gender"];
                     
                     
                     /*
                      // result will contain an array with your user's friends in the "data" key
                      NSArray *friendObjects = [result objectForKey:@"data"];
                      NSMutableArray *friendIdsArray = [NSMutableArray arrayWithCapacity:friendObjects.count];
                      // Create a list of friends' Facebook IDs
                      for (NSDictionary *friendObject in friendObjects) {
                      [friendIdsArray addObject:[friendObject objectForKey:@"id"]];
                      }
                      
                      NSLog (@"friendIdsArray appdelegate = %lu", (unsigned long)[friendIdsArray count]);
                      //Save 'friendsIds" NSMutableArray to NSUserDefaults
                      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                      [userDefaults setObject:friendIdsArray forKey:@"friendIdsArray"];
                      [userDefaults synchronize];
                      */
                     
                     [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         // some logging code here
                         if (succeeded)
                         {
                             NSLog (@"PFUser data save in background success = %i", succeeded);
                             //After loogging in successfully create the dashboard and button so that it will respond to touches this way
                             NSLog (@"addDashboardView called in logInViewController:(MyLoginViewController *)logInController");
                             [self addDashboardView];
                             [self shareHealthDataOrCreateButton];
                         }
                         if (error)
                         {
                             NSLog (@"Error = %@", error);
                         }
                     }];
                     
                     //Save gender to NSUserDefaults
                     [[NSUserDefaults standardUserDefaults] setObject:facebookGender forKey:@"gender"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     NSLog (@"facebookGender = %@", facebookGender);
                 }
             }];
        }
    }
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(MyLoginViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(MyLoginViewController *)logInController
{
    NSLog (@"logInViewControllerDidCancelLogIn:(MyLoginViewController *)logInController");
    [self.navigationController popViewControllerAnimated:YES];
}

/*
-(void)addToListViewButton
{
    dashboardView.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dashboardView.followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self setFollowButtonNotTapped];
    [dashboardView addSubview:dashboardView.followButton];
    
    PFQuery *query2 = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query2 whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query2 whereKey:kPAPActivityToUserKey equalTo:userObject];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog (@"object4 = %@", [objects lastObject]);
        if ([objects lastObject] != NULL)
        {
            [self setFollowButtonTapped];
        }
        else
        {
            [self setFollowButtonNotTapped];
        }
    }];
}
*/
-(void)setFollowButtonTapped
{
    [dashboardView.followButton setTitle:@"Unfriend" forState:UIControlStateNormal];
    dashboardView.followButton.selected = NO;
    dashboardView.followButton.frame = CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 116, dashboardView.uploaderPhoto.frame.origin.y + 50, 160.0, 40.0);
}

-(void)setFollowButtonNotTapped
{
    [dashboardView.followButton setTitle:@"Friend" forState:UIControlStateSelected];
    dashboardView.followButton.selected = YES;
    dashboardView.followButton.frame = CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 83, dashboardView.uploaderPhoto.frame.origin.y + 50, 160.0, 40.0);
}
/*
-(void)addToListButtonTapped:(UIButton*)sender
{
    NSLog (@"followButtonTapped called");
    
    if (dashboardView.followButton.selected)
    {
        //This block brings up a picker view which allows you to add the target person to a specific lit of your choice
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
        [dashboardView addSubview:pickerToolBarView];
        [dashboardView bringSubviewToFront:pickerToolBarView];
    }
    else
    {
        [self unfollowUser];
    }
}
*/
-(void)doneTouched:(id)sender
{
    [pickerToolBarView removeFromSuperview];
    
    [self setFollowButtonTapped];
}

-(void)addChatButton
{
    dashboardView.chatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dashboardView.chatButton addTarget:self action:@selector(chatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardView.chatButton setTitle:@"Chat" forState:UIControlStateNormal];
    dashboardView.chatButton.frame = CGRectMake(dashboardView.uploaderPhoto.frame.origin.x - 10, dashboardView.uploaderPhoto.frame.origin.y + 80, 160.0, 40.0);
    [dashboardView addSubview:dashboardView.chatButton];
}

-(void)addFollowButton
{
    dashboardView.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dashboardView.followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardView.followButton setTitle:@"" forState:UIControlStateNormal];
    dashboardView.followButton.frame = CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 75, dashboardView.uploaderPhoto.frame.origin.y + 50, 160.0, 40.0);
    [dashboardView addSubview:dashboardView.followButton];
    
    if ([PFUser currentUser])
    {
        PFQuery *query2 = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [query2 whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [query2 whereKey:kPAPActivityToUserKey equalTo:userObject];
        [query2 whereKey:@"saved_to_list" equalTo:@"Following"];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog (@"object4 = %@", [objects lastObject]);
            if ([objects lastObject] != NULL)
            {
                //self.friendButton.titleLabel.text = @"Unfriend";
                [dashboardView.followButton setTitle:@"Unfriend" forState:UIControlStateNormal];
                dashboardView.followButton.selected = NO;
            }
            else
            {
                //self.friendButton.titleLabel.text = @"Friend";
                [dashboardView.followButton setTitle:@"Friend" forState:UIControlStateSelected];
                dashboardView.followButton.selected = YES;
            }
        }];
    }
}

-(void)followButtonTapped:(UIButton*)sender
{

    //Get other user
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userObject.objectId];
    NSArray * results = [query findObjects];
    PFUser *targetUser = [results lastObject];
    
    if (![dashboardView.followButton isSelected]) {
        // Unfollow
        NSLog (@"Unfollowing user");
        [dashboardView.followButton setTitle:@"Friend" forState:UIControlStateSelected];
        dashboardView.followButton.selected = YES;
        [Utility unfollowUserEventually:targetUser];
    }
    else
    {
        // Follow
        NSLog (@"Following user");
        [dashboardView.followButton setTitle:@"Unfriend" forState:UIControlStateNormal];
        dashboardView.followButton.selected = NO;
        [Utility followUserEventually:targetUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                dashboardView.followButton.selected = NO;
            }
            NSInteger number = 0;
            //Add user to the 'following' list by default. The argument '0' refers to the 'following' string object in listsArray
            [self userObjectSavedToList:number];
        }];
    }
}

/*
-(void)unfollowUser
{
    //Get other user
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userObject.objectId];
    NSArray * results = [query findObjects];
    PFUser *targetUser = [results lastObject];
    
    if (![dashboardView.followButton isSelected]) {
        // Unfollow
        NSLog (@"Unfollowing user");
        [self setFollowButtonNotTapped];
        [Utility unfollowUserEventually:targetUser];
    }
}
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // Handle the selection
    [self userObjectSavedToList:row];
}

-(void)userObjectSavedToList:(NSInteger)row
{
    NSLog (@"userObjectSavedToList called!");
    
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

-(void)createChangeButton //This method is located under the user's photo and just allows the user to edit their photo
{
    NSLog (@"createChangeButton called!");
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Change" forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = CGPointMake(dashboardView.uploaderPhoto.center.x, dashboardView.uploaderPhoto.center.y + 60);
    [dashboardView addSubview:button];
}

//When user taps 'Upload Photo' button on Home Page this displays one button that slide up from the button of the screen that lets the user Take a Photo or Choose a Photo from their library
- (void)uploadPhoto
{
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        NSLog (@"cameraDeviceAvailable & photoLibraryAvailable available");
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showInView: self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    NSLog (@"shouldStartPhotoLibraryPickerController called!");
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog (@"imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info");
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    EditPhotoViewController *viewController = [[EditPhotoViewController alloc] initWithImage:image];
    //[viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

-(void)createEditYourProfileButton
{
    NSLog (@"createEditYourProfileButton called!");
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(editYourProfilesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Edit Your Profile" forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = CGPointMake(dashboardView.uploaderPhoto.center.x + 160, dashboardView.uploaderPhoto.center.y + 5);
    [dashboardView addSubview:button];
}

-(void)editYourProfilesButtonTapped:(UIBarButtonItem *)sender
{
    //perform your action
    EditYourProfileViewController *viewController = [[EditYourProfileViewController alloc] init];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

-(void)addDashboardView
{
    NSLog (@"addDashboardView called!");
    
    //Make sure dashboardView hasn't already been added as a child to self.view
    if(![dashboardView isDescendantOfView:[self view]])
    {
        dashboardView = [[UserDashboardView alloc] init];
        dashboardView.frame = CGRectMake(0, -432, [[UIScreen mainScreen] bounds].size.width, viewOffset);
        
        [self populateUserDashboardView];
        [self.view addSubview:dashboardView];
    }
}

-(void)friendsListTapped:(UIBarButtonItem *)sender {
    
    NSLog (@"friendsListTapped called!");
    
    FriendsListViewController *viewController = [[FriendsListViewController alloc] init];
    viewController.userObject = userObject;
    // viewController.viewOffset = 460;
    // viewController.currentViewIsNonRootView = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)followingListTapped:(UIBarButtonItem *)sender{
    
    NSLog (@"followingListTapped called!");
    
    FollowingListViewController *viewController = [[FollowingListViewController alloc] init];
    viewController.userObject = userObject;
    // viewController.viewOffset = 460;
    // viewController.currentViewIsNonRootView = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)requestsListTapped:(UIBarButtonItem *)sender{
    
    NSLog (@"followersListTapped called!");
    
    FollowersListViewController *viewController = [[FollowersListViewController alloc] init];
    viewController.userObject = userObject;
    // viewController.viewOffset = 460;
    // viewController.currentViewIsNonRootView = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)searchAction:(UIBarButtonItem *)sender{
    
    //perform your action
    UsersViewController *viewController = [[UsersViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 475.0f;
}

//Query all photos uploaded by all users
-(PFQuery *)queryForTable {
    
    NSLog (@"MeViewController queryForTable");
   
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query setLimit:0];
    
    /*
    if ([PFUser currentUser])
    {
        // We create a second query for the current user's photos
        PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"Photo"];
        if (userObject)
        {
            [photosFromCurrentUserQuery whereKey:kPAPPhotoUserKey equalTo:userObject];
            [photosFromCurrentUserQuery whereKeyExists:kPAPPhotoPictureKey];
        }
    
        [query includeKey:kPAPPhotoUserKey];
        [query orderByDescending:@"createdAt"];
        
        // A pull-to-refresh should always trigger a network request.
        [query setCachePolicy:kPFCachePolicyNetworkOnly];
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        //
        // If there is no network connection, we will hit the cache first.
        if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
            [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        }
    }
    */
    
    [self stylePFLoadingViewTheHardWay];
    
    return query;
}

-(void) addFitnessLabel:(PFObject *)object
{
    NSNumber *fitnessRatingNSNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitnessRating"];
    int fitnessRatingInt = (int)[fitnessRatingNSNumber integerValue];
    NSLog (@"fitness rating = %i", fitnessRatingInt);
    
    dashboardView.fitnessLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    dashboardView.fitnessLevelLabel.text = [NSString stringWithFormat: @"Fitness Level: %i", fitnessRatingInt];
    dashboardView.fitnessLevelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dashboardView.fitnessLevelLabel.textColor = [UIColor whiteColor];
    dashboardView.fitnessLevelLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    dashboardView.fitnessLevelLabel.tag = 2;
    [dashboardView.fitnessLevelLabel sizeToFit];
    dashboardView.fitnessLevelLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    dashboardView.fitnessLevelLabel.center = CGPointMake(dashboardView.uploaderPhoto.center.x, dashboardView.uploaderPhoto.center.y + 41);
    [dashboardView addSubview:dashboardView.fitnessLevelLabel];
}

//Pulls user's minutes of exercise from Parse
-(int) minutesOfExercise: (PFObject*)object
{
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKey:@"MinutesOfExerciseToday"];
    
 //   NSLog (@"minutesOfExerciseTodayNSNumber int value in MeViewController 'minutesOfExercise' method = %li", [minutesOfExerciseTodayNSNumber integerValue]);
    HealthMethods *healthMethodsSubclass = [[HealthMethods alloc] init];
    
    if (!([healthMethodsSubclass isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[minutesOfExerciseTodayNSNumber integerValue];
    }
}

//Pulls user's number of steps from Parse
-(int) numOfSteps: (PFObject*)object
{
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:@"NumberOfStepsToday"];
    
 //   NSLog (@"numOfStepsTodayNSNumber int value in MeViewController 'numOfSteps' method = %li", [numOfStepsTodayNSNumber integerValue]);

    HealthMethods *healthMethodsSubclass = [[HealthMethods alloc] init];
    
    if (!([healthMethodsSubclass isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[numOfStepsTodayNSNumber integerValue];
    }
}

//Pulls user's calories burned from Parse
-(int) caloriesBurned: (PFObject*)object
{
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKey:@"CaloriesBurnedToday"];
    
   // NSLog (@"caloriesBurnedTodayNSNumber int value in MeViewController 'caloriesBurned' method = %li", [caloriesBurnedTodayNSNumber integerValue]);
    
    HealthMethods *healthMethodsSubclass = [[HealthMethods alloc] init];
    
    if (!([healthMethodsSubclass isNSDateToday:[object updatedAt]]))
    {
        return 0;
    }
    else
    {
        return (int)[caloriesBurnedTodayNSNumber integerValue];
    }
}

-(void) addBlueCircle: (PFObject *)object
{
    //Determine blueCircle size
    float blueCircleHeightAndWidth;
    
    if ([self numOfSteps:object] < 10) {
        
        blueCircleHeightAndWidth = 15*2.3;
    }
    else if ([self numOfSteps:object] >= 10 && [self numOfSteps:object] < 999)
    {
        blueCircleHeightAndWidth = 17*2.3;
    }
    else if ([self numOfSteps:object] >= 999 && [self numOfSteps:object] < 5000)
    {
        blueCircleHeightAndWidth = 19*3.0;
    }
    else if ([self numOfSteps:object] >= 5000 && [self numOfSteps:object] < 10000)
    {
        blueCircleHeightAndWidth = 21*4.0;
    }
    else if ([self numOfSteps:object] >= 10000)
    {
        blueCircleHeightAndWidth = 23*5.0;
    }
    
    //Add blue colored circle
    dashboardView.blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,blueCircleHeightAndWidth,blueCircleHeightAndWidth)];
    dashboardView.blueCircleView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/4 + 35, 275);
    dashboardView.blueCircleView.layer.cornerRadius = blueCircleHeightAndWidth/2;
    dashboardView.blueCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:164/255.0 alpha:1];
    dashboardView.blueCircleView.tag = 2;
    dashboardView.blueCircleView.alpha = 0.8;
    [dashboardView.blueCircleView sizeToFit];
    [dashboardView addSubview: dashboardView.blueCircleView];
    
    //Add blue 'Walk' title label to blue circle
    dashboardView.blueCircleStepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.blueCircleView.center.x, dashboardView.blueCircleView.center.y - dashboardView.blueCircleView.frame.size.height, 0, 0)];
    dashboardView.blueCircleStepsLabel.text = @"Walk";
    dashboardView.blueCircleStepsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    dashboardView.blueCircleStepsLabel.textColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:164/255.0 alpha:1];
    dashboardView.blueCircleStepsLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.blueCircleStepsLabel sizeToFit];
    [dashboardView addSubview:dashboardView.blueCircleStepsLabel];
    //Adjust y-position of the blueCircleStepsLabel to accomodate red circle size
    float walkLabelYOffset;
    
    if ([self numOfSteps:object] < 10) {
        
        walkLabelYOffset = 15*1.7;
    }
    else if ([self numOfSteps:object] >= 10 && [self numOfSteps:object] < 999)
    {
        walkLabelYOffset = 17*1.7;
    }
    else if ([self numOfSteps:object] >= 999 && [self numOfSteps:object] < 5000)
    {
        walkLabelYOffset = 19*2.0;
    }
    else if ([self numOfSteps:object] >= 5000 && [self numOfSteps:object] < 10000)
    {
        walkLabelYOffset = 21*2.5;
    }
    else if ([self numOfSteps:object] >= 10000)
    {
        walkLabelYOffset = 22*3.0;
    }

    dashboardView.blueCircleStepsLabel.center = CGPointMake(dashboardView.blueCircleView.center.x, dashboardView.blueCircleView.center.y + walkLabelYOffset);
    
    //Add small blue 'Steps' label under the number of steps
    dashboardView.blueCircleSmallStepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.blueCircleView.center.x, dashboardView.blueCircleView.center.y - dashboardView.blueCircleView.frame.size.height, 0, 0)];
    dashboardView.blueCircleSmallStepsLabel.text = @"steps";
    dashboardView.blueCircleSmallStepsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    dashboardView.blueCircleSmallStepsLabel.textColor = [UIColor whiteColor];
    dashboardView.blueCircleSmallStepsLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.blueCircleSmallStepsLabel sizeToFit];
    [dashboardView addSubview:dashboardView.blueCircleSmallStepsLabel];
    dashboardView.blueCircleSmallStepsLabel.center = CGPointMake(dashboardView.blueCircleView.center.x, dashboardView.blueCircleView.center.y + 10);
    
    //Add number of steps inside the blue circle
    dashboardView.blueCircleNumOfStepsTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    dashboardView.blueCircleNumOfStepsTodayLabel.text = [NSString stringWithFormat: @"%i", [self numOfSteps:object]];
    dashboardView.blueCircleNumOfStepsTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dashboardView.blueCircleNumOfStepsTodayLabel.textColor = [UIColor whiteColor];
    dashboardView.blueCircleNumOfStepsTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    dashboardView.blueCircleNumOfStepsTodayLabel.tag = 2;
    [dashboardView.blueCircleNumOfStepsTodayLabel sizeToFit];
    [dashboardView addSubview:dashboardView.blueCircleNumOfStepsTodayLabel];
    dashboardView.blueCircleNumOfStepsTodayLabel.center = CGPointMake(dashboardView.blueCircleView.center.x, dashboardView.blueCircleView.center.y);
}

-(void) addRedCircle:(PFObject *)object
{
    //Determine redCircle size
    float redCircleHeightAndWidth;

    if ([self minutesOfExercise:object] < 1) {
        
        redCircleHeightAndWidth = 15*2.3;
    }
    else if ([self minutesOfExercise:object] >= 1 && [self minutesOfExercise:object] < 20)
    {
        redCircleHeightAndWidth = 17*2.3;
    }
    else if ([self minutesOfExercise:object] >= 20 && [self minutesOfExercise:object] < 40)
    {
        redCircleHeightAndWidth = 19*3.0;
    }
    else if ([self minutesOfExercise:object] >= 40 && [self minutesOfExercise:object] < 60)
    {
        redCircleHeightAndWidth = 21*4.0;
    }
    else if ([self minutesOfExercise:object] >= 60)
    {
        redCircleHeightAndWidth = 23*5.0;
    }
    
    //Add red colored circle
    dashboardView.redCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redCircleHeightAndWidth,redCircleHeightAndWidth)];
    dashboardView.redCircleView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2 + 2.5, dashboardView.blueCircleView.center.y - 90);
    dashboardView.redCircleView.layer.cornerRadius = redCircleHeightAndWidth/2;
    dashboardView.redCircleView.backgroundColor = [UIColor colorWithRed:140/255.0 green:198/255.0 blue:62/255.0 alpha:1];
    dashboardView.redCircleView.tag = 2;
    [dashboardView.redCircleView sizeToFit];
    dashboardView.redCircleView.alpha = 0.8;
    [dashboardView addSubview: dashboardView.redCircleView];
    
    //Add red 'Run' title label to red circle
    dashboardView.redCircleExerciseLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.redCircleView.center.x, dashboardView.redCircleView.center.y - dashboardView.redCircleView.frame.size.height, 0, 0)];
    dashboardView.redCircleExerciseLabel.text = @"Exercise";
    dashboardView.redCircleExerciseLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    dashboardView.redCircleExerciseLabel.textColor = [UIColor colorWithRed:140/255.0 green:198/255.0 blue:62/255.0 alpha:1];
    dashboardView.redCircleExerciseLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.redCircleExerciseLabel sizeToFit];
    [dashboardView addSubview:dashboardView.redCircleExerciseLabel];
    //Adjust y-position of the redCircleExerciseLabel to accomodate red circle size
    float stepsLabelYOffset;
    
    if ([self minutesOfExercise:object] < 1) {
        
        stepsLabelYOffset = 15*1.7;
    }
    else if ([self minutesOfExercise:object] >= 1 && [self minutesOfExercise:object] < 20)
    {
        stepsLabelYOffset = 17*1.7;
    }
    else if ([self minutesOfExercise:object] >= 20 && [self minutesOfExercise:object] < 40)
    {
        stepsLabelYOffset = 19*2.0;
    }
    else if ([self minutesOfExercise:object] >= 40 && [self minutesOfExercise:object] < 60)
    {
        stepsLabelYOffset = 21*2.5;
    }
    else if ([self minutesOfExercise:object] >= 60)
    {
        stepsLabelYOffset = 22*3.0;
    }
    

    dashboardView.redCircleExerciseLabel.center = CGPointMake(dashboardView.redCircleView.center.x, dashboardView.redCircleView.center.y - stepsLabelYOffset);
    
    //Add small 'mi' label under the distance run label
    dashboardView.redCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.redCircleView.center.x, dashboardView.redCircleView.center.y - dashboardView.redCircleView.frame.size.height, 0, 0)];
    dashboardView.redCircleSmallMinLabel.text = @"min";
    dashboardView.redCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    dashboardView.redCircleSmallMinLabel.textColor = [UIColor whiteColor];
    dashboardView.redCircleSmallMinLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.redCircleSmallMinLabel sizeToFit];
    [dashboardView addSubview:dashboardView.redCircleSmallMinLabel];
    dashboardView.redCircleSmallMinLabel.center = CGPointMake(dashboardView.redCircleView.center.x, dashboardView.redCircleView.center.y + 10);
    
    //Add number of steps inside the red circle
    dashboardView.redCircleMinOfExerciseTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    dashboardView.redCircleMinOfExerciseTodayLabel.text = [NSString stringWithFormat: @"%i", [self minutesOfExercise:object]];
    dashboardView.redCircleMinOfExerciseTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dashboardView.redCircleMinOfExerciseTodayLabel.textColor = [UIColor whiteColor];
    dashboardView.redCircleMinOfExerciseTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    dashboardView.redCircleMinOfExerciseTodayLabel.tag = 2;
    [dashboardView.redCircleMinOfExerciseTodayLabel sizeToFit];
    [dashboardView addSubview:dashboardView.redCircleMinOfExerciseTodayLabel];
    dashboardView.redCircleMinOfExerciseTodayLabel.center = CGPointMake(dashboardView.redCircleView.center.x, dashboardView.redCircleView.center.y);
}

-(void) promptUserToSetHealthProfile
{
    if ([userObject.objectId isEqualToString:[PFUser currentUser].objectId])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Set Your Health Profile"
                                                                       message:@"Set your height, weight, gender, & birthday in Apple's Watch app. Go to Watch > Health. Not doing so will set you at a disadvantage for Challenges."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                   }];
        [alert addAction:okAction];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
}

-(void) addOrangeCircle:(PFObject *)object
{
    //Determine orangeCircle size
    float orangeCircleHeightAndWidth;
    float orangeCircleXPosition;
    float orangeCircleYPosition;
    int moveGoal;
    
    //User's calculated move goal factoring in weight, height, age, and gender
    /*
    double usersHeightInCM = [[NSUserDefaults standardUserDefaults] floatForKey:@"heightInCM"];
    double usersWeightInKG = [[NSUserDefaults standardUserDefaults] floatForKey:@"weightInKG"];
    int usersAge = (int)[self usersAge];
    NSString *genderFromFacebook = [[NSUserDefaults standardUserDefaults] objectForKey:@"gender"];
    */
    NSNumber *usersHeightInCMNSNumber = [userObject objectForKey:@"heightInCM"];
    NSNumber *usersWeightInKGNSNumber = [userObject objectForKey:@"weightInKG"];
    NSNumber *usersAgeNSNumber = [userObject objectForKey:@"age"];

    double usersHeightInCM = [usersHeightInCMNSNumber doubleValue];
    double usersWeightInKG = [usersWeightInKGNSNumber doubleValue];
    int usersAge = (int)[usersAgeNSNumber integerValue];
    NSString *genderFromFacebook = [userObject objectForKey:@"gender"];
    
    NSLog (@"usersHeightInCM = %f", usersHeightInCM);
    NSLog (@"usersWeightInKG = %f", usersWeightInKG);
    NSLog (@"usersAge = %i", usersAge);
    NSLog (@"genderFromFacebook = %@", genderFromFacebook);

    
    //Set default height if it's not available
    if (usersHeightInCM <= 91) //About 3ft
    {
        usersHeightInCM = 190;  //About 6'3
        
        [self promptUserToSetHealthProfile];
    }
    
    //Set default weight if it's not available
    if (usersWeightInKG <= 22) //About 22kg
    {
        usersWeightInKG = 127; //about 280lbs
        
        [self promptUserToSetHealthProfile];
    }
    
    //Set default age if it's not available
    if (usersAge <= 0)
    {
        usersAge = 30;
    }
    
    if ([genderFromFacebook isEqualToString:@"male"])
    {
        NSLog (@"user is MALE");
        //For men
        moveGoal = (int)(10*usersWeightInKG + 6.25*usersHeightInCM - 5*usersAge + 5);
    }
    else if ([genderFromFacebook isEqualToString:@"female"])
    {
        NSLog (@"user is FEMALE");
        //For women
        moveGoal = (int)(10*usersWeightInKG + 6.25*usersHeightInCM - 5*usersAge - 161);
    }
    else
    {
        //For men
        moveGoal = (int)(10*usersWeightInKG + 6.25*usersHeightInCM - 5*usersAge + 5);
    }
    
    //If moveGoal is too small then set it to a default
    if (moveGoal <= 10)
    {
        if ([genderFromFacebook isEqualToString:@"male"])
        {
            moveGoal = 800;
        }
        else
        {
            moveGoal = 700;
        }
    }
    
    NSLog (@"MeViewController moveGoal = %f", moveGoal*0.35);
    
    
    if ([PFUser currentUser] && userObject == [PFUser currentUser])
    {
        //Upload user's moveGoal to Parse to use on 'Home' tab
        [[PFUser currentUser] setObject:[NSNumber numberWithFloat:moveGoal*0.35] forKey:@"moveGoal"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             // some logging code here
             if (succeeded)
             {
                 NSLog (@"Successfully saved user's moveGoal to Parse");
             }
             if (error)
             {
                 NSLog (@"Error saving user's moveGoal to Parse");
             }
         }];
    }
    
    if ([self caloriesBurned:object] < moveGoal*0.25*0.35) {
        
        orangeCircleHeightAndWidth = 15*2.3;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.25*0.35 && [self caloriesBurned:object] < moveGoal*0.5*0.35)
    {
        orangeCircleHeightAndWidth = 17*2.3;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.5*0.35 && [self caloriesBurned:object] < moveGoal*0.75*0.35)
    {
        orangeCircleHeightAndWidth = 19*3.0;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.75*0.35 && [self caloriesBurned:object] < moveGoal*0.35)
    {
        orangeCircleHeightAndWidth = 21*4.0;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.35)
    {
        orangeCircleHeightAndWidth = 23*5.0;
    }
    
    //Add orange colored circle
    dashboardView.orangeCircleView = [[UIView alloc] initWithFrame:CGRectMake(orangeCircleXPosition,orangeCircleYPosition,orangeCircleHeightAndWidth,orangeCircleHeightAndWidth)];
    dashboardView.orangeCircleView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4 - 30, dashboardView.blueCircleView.center.y);
    dashboardView.orangeCircleView.layer.cornerRadius = orangeCircleHeightAndWidth/2;
    dashboardView.orangeCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:173/255.0 blue:239/255.0 alpha:1];
    dashboardView.orangeCircleView.tag = 2;
    [dashboardView.orangeCircleView sizeToFit];
    dashboardView.orangeCircleView.alpha = 0.8;
    [dashboardView addSubview: dashboardView.orangeCircleView];
    
    //Add red 'Cardio' title label to orange circle
    dashboardView.orangeCircleCaloriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.orangeCircleView.center.x, dashboardView.orangeCircleView.center.y - dashboardView.orangeCircleView.frame.size.height, 0, 0)];
    dashboardView.orangeCircleCaloriesLabel.text = @"Calories";
    dashboardView.orangeCircleCaloriesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    dashboardView.orangeCircleCaloriesLabel.textColor = [UIColor colorWithRed:0/255.0 green:173/255.0 blue:239/255.0 alpha:1];
    dashboardView.orangeCircleCaloriesLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.orangeCircleCaloriesLabel sizeToFit];
    [dashboardView addSubview:dashboardView.orangeCircleCaloriesLabel];
    
    //Adjust y-position of the orangeCircleCaloriesLabel to accomodate orange circle size
    float caloriesLabelYOffset;
    
    if ([self caloriesBurned:object] < moveGoal*0.25*0.35) {
        
        caloriesLabelYOffset = 15*1.7;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.25*0.35 && [self caloriesBurned:object] < moveGoal*0.5*0.35)
    {
        caloriesLabelYOffset = 17*1.7;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.5*0.35 && [self caloriesBurned:object] < moveGoal*0.75*0.35)
    {
        caloriesLabelYOffset = 19*2.0;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.75*0.35 && [self caloriesBurned:object] < moveGoal*0.35)
    {
        caloriesLabelYOffset = 21*2.5;
    }
    else if ([self caloriesBurned:object] >= moveGoal*0.35)
    {
        caloriesLabelYOffset = 22*3.0;
    }

    dashboardView.orangeCircleCaloriesLabel.center = CGPointMake(dashboardView.orangeCircleView.center.x, dashboardView.orangeCircleView.center.y + caloriesLabelYOffset);

    
    //Add small 'cal' label under the distance run label
    dashboardView.orangeCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.orangeCircleView.center.x, dashboardView.orangeCircleView.center.y - dashboardView.orangeCircleView.frame.size.height, 0, 0)];
    dashboardView.orangeCircleSmallMinLabel.text = @"cal";
    dashboardView.orangeCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    dashboardView.orangeCircleSmallMinLabel.textColor = [UIColor whiteColor];
    dashboardView.redCircleSmallMinLabel.tag = 2;
    //Resize the frame of the UILabel to fit the text
    [dashboardView.orangeCircleSmallMinLabel sizeToFit];
    [dashboardView addSubview:dashboardView.orangeCircleSmallMinLabel];
    dashboardView.orangeCircleSmallMinLabel.center = CGPointMake(dashboardView.orangeCircleView.center.x, dashboardView.orangeCircleView.center.y + 10);
    
    //Add number of steps inside the orange circle
    dashboardView.orangeCircleNumOfCaloriesTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.text = [NSString stringWithFormat: @"%i", [self caloriesBurned:object]];
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.textColor = [UIColor whiteColor];
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.tag = 2;
    [dashboardView.orangeCircleNumOfCaloriesTodayLabel sizeToFit];
    [dashboardView addSubview:dashboardView.orangeCircleNumOfCaloriesTodayLabel];
    dashboardView.orangeCircleNumOfCaloriesTodayLabel.center = CGPointMake(dashboardView.orangeCircleView.center.x, dashboardView.orangeCircleView.center.y);
}

-(void) setTodaysActivityLabel
{
    dashboardView.todayDelimiterLabel.text = [NSString stringWithFormat: @"Today's Activity"];
}

-(void) addTodayDelimiterLabel
{
    //Add Today's Activity label
    dashboardView.todayDelimiterLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
    dashboardView.todayDelimiterLabel.textColor = [UIColor lightGrayColor];
    dashboardView.todayDelimiterLabel.backgroundColor = [UIColor clearColor];
    dashboardView.todayDelimiterLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    dashboardView.todayDelimiterLabel.text = [NSString stringWithFormat: @"Today's Activity"];
    [dashboardView.todayDelimiterLabel sizeToFit];
    dashboardView.todayDelimiterLabel.center = CGPointMake(dashboardView.redCircleExerciseLabel.center.x, dashboardView.redCircleExerciseLabel.center.y - 22);
    [dashboardView addSubview:dashboardView.todayDelimiterLabel];
    
    //Add Updating... label
    dashboardView.updatingLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
    dashboardView.updatingLabel.textColor = [UIColor lightGrayColor];
    dashboardView.updatingLabel.backgroundColor = [UIColor clearColor];
    dashboardView.updatingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    dashboardView.updatingLabel.text = [NSString stringWithFormat: @"Updating..."];
    [dashboardView.updatingLabel sizeToFit];
    dashboardView.updatingLabel.center = CGPointMake(dashboardView.redCircleExerciseLabel.center.x, dashboardView.redCircleExerciseLabel.center.y - 22);
    [dashboardView addSubview:dashboardView.updatingLabel];    
    
    
    NSLog (@"StepsQueryCurrentlyRunning = %i", [[NSUserDefaults standardUserDefaults] boolForKey:@"StepsQueryCurrentlyRunning"]);
    if (([userObject.objectId isEqualToString:[PFUser currentUser].objectId]) && [[NSUserDefaults standardUserDefaults] boolForKey:@"StepsQueryCurrentlyRunning"] == YES)
    {
        NSLog (@"Making updatingLabel visible!");
        dashboardView.todayDelimiterLabel.hidden = YES;
        dashboardView.updatingLabel.hidden = NO;
    }
    else
    {
        NSLog (@"Making todayDelimiterLabel visible!");
        dashboardView.todayDelimiterLabel.hidden = NO;
        dashboardView.updatingLabel.hidden = YES;
    }
}

-(void) addThisWeekDelimiterLabel:(PFObject *)object
{
    dashboardView.thisWeekDelimiterLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
    dashboardView.thisWeekDelimiterLabel.textColor = [UIColor lightGrayColor];
    dashboardView.thisWeekDelimiterLabel.backgroundColor = [UIColor clearColor];
    dashboardView.thisWeekDelimiterLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    dashboardView.thisWeekDelimiterLabel.text = [NSString stringWithFormat: @"This Week"];
    [dashboardView.thisWeekDelimiterLabel sizeToFit];
    dashboardView.thisWeekDelimiterLabel.center = CGPointMake(dashboardView.redBarView.center.x, dashboardView.redBarView.center.y - 80);
    [dashboardView addSubview:dashboardView.thisWeekDelimiterLabel];
}

-(void) addBlueBar:(PFObject *)object
{
    CGPoint bottomLeftBarPositions = CGPointMake(dashboardView.blueCircleView.center.x, 245);
    
    //Add outline for blue bar
    float grayBarForBlueBarWidth = 46;
    float grayBarForBlueBarHeight = 120;
    dashboardView.grayBarForBlueBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, grayBarForBlueBarWidth, grayBarForBlueBarHeight)];
    dashboardView.grayBarForBlueBarView.frame = CGRectMake(bottomLeftBarPositions.x - 0.5 - dashboardView.grayBarForBlueBarView.frame.size.width/2, bottomLeftBarPositions.y - 30, grayBarForBlueBarWidth, grayBarForBlueBarHeight);
    dashboardView.grayBarForBlueBarView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    dashboardView.grayBarForBlueBarView.tag = 2;
    [dashboardView addSubview: dashboardView.grayBarForBlueBarView];
    
    //Add blue bar
    float blueBarWidth = 45;
    float blueBarHeight = 85; //Full height is 120
    dashboardView.blueBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, blueBarWidth, blueBarHeight)];
    dashboardView.blueBarView.frame = CGRectMake(bottomLeftBarPositions.x - dashboardView.blueBarView.frame.size.width/2, bottomLeftBarPositions.y + (120 - blueBarHeight) - 30, blueBarWidth, blueBarHeight);
    dashboardView.blueBarView.backgroundColor = [UIColor colorWithRed:163/255.0 green:207/255.0 blue:99/255.0 alpha:1];
    dashboardView.blueBarView.tag = 2;
    [dashboardView addSubview: dashboardView.blueBarView];
}

-(void) addRedBar:(PFObject *)object
{
    CGPoint bottomLeftBarPositions = CGPointMake(dashboardView.redCircleView.center.x, 245);
    
    //Add outline for red bar
    float grayBarForRedBarWidth = 46;
    float grayBarForRedBarHeight = 120;
    dashboardView.grayBarForRedBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, grayBarForRedBarWidth, grayBarForRedBarHeight)];
    dashboardView.grayBarForRedBarView.frame = CGRectMake(bottomLeftBarPositions.x - 0.5 - dashboardView.grayBarForRedBarView.frame.size.width/2, bottomLeftBarPositions.y - 30, grayBarForRedBarWidth, grayBarForRedBarHeight);
    dashboardView.grayBarForRedBarView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    dashboardView.grayBarForRedBarView.tag = 2;
    [dashboardView addSubview: dashboardView.grayBarForRedBarView];
    
    //Add red bar
    float redBarWidth = 45;
    float redBarHeight = 110; //Max is 120
    dashboardView.redBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redBarWidth, redBarHeight)];
    dashboardView.redBarView.frame = CGRectMake(bottomLeftBarPositions.x - dashboardView.redBarView.frame.size.width/2, bottomLeftBarPositions.y + (120 - redBarHeight) - 30, redBarWidth, redBarHeight);
    dashboardView.redBarView.backgroundColor = [UIColor colorWithRed:81/255.0 green:193/255.0 blue:180/255.0 alpha:1];
    dashboardView.redBarView.tag = 2;
    [dashboardView addSubview: dashboardView.redBarView];
}

-(void) addOrangeBar:(PFObject *)object
{
    CGPoint bottomLeftBarPositions = CGPointMake(dashboardView.orangeCircleView.center.x, 245);
    
    //Add outline for red bar
    float grayBarForOrangeBarWidth = 46;
    float grayBarForOrangeBarHeight = 120;
    dashboardView.grayBarForOrangeBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, grayBarForOrangeBarWidth, grayBarForOrangeBarHeight)];
    dashboardView.grayBarForOrangeBarView.frame = CGRectMake(bottomLeftBarPositions.x - 0.5 - dashboardView.grayBarForOrangeBarView.frame.size.width/2, bottomLeftBarPositions.y - 30, grayBarForOrangeBarWidth, grayBarForOrangeBarHeight);
    dashboardView.grayBarForOrangeBarView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    dashboardView.grayBarForOrangeBarView.tag = 2;
    [dashboardView addSubview: dashboardView.grayBarForOrangeBarView];
    
    //Add orange bar
    float orangeBarWidth = 45;
    float orangeBarHeight = 55; //Max is 120
    dashboardView.orangeBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, orangeBarWidth, orangeBarHeight)];
    dashboardView.orangeBarView.frame = CGRectMake(bottomLeftBarPositions.x - dashboardView.orangeBarView.frame.size.width/2, bottomLeftBarPositions.y + (120 - orangeBarHeight) - 30, orangeBarWidth, orangeBarHeight);
    dashboardView.orangeBarView.backgroundColor = [UIColor colorWithRed:163/255.0 green:186/255.0 blue:242/255.0 alpha:1];
    dashboardView.orangeBarView.tag = 2;
    [dashboardView addSubview: dashboardView.orangeBarView];
}

-(void) addFitnessLevelBar:(PFObject *)object
{
    NSNumber *fitnessRatingNSNumber = [userObject objectForKey:@"fitness_rating"];
    float fitnessRatingFloat = [fitnessRatingNSNumber floatValue];
    
    //Add fitness level bar's gray background
    dashboardView.grayBarForFitnessLevelBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    dashboardView.grayBarForFitnessLevelBarView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, 425 - 20);
    dashboardView.grayBarForFitnessLevelBarView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    dashboardView.grayBarForFitnessLevelBarView.tag = 2;
    dashboardView.grayBarForFitnessLevelBarView.layer.cornerRadius = 5;
    dashboardView.grayBarForFitnessLevelBarView.layer.masksToBounds = YES;
    [dashboardView addSubview: dashboardView.grayBarForFitnessLevelBarView];
    
    //Add fitness Level Bar
    dashboardView.fitnessLevelBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200*fitnessRatingFloat*0.1, 45)];
    dashboardView.fitnessLevelBarView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2 - (200 - 200*fitnessRatingFloat*0.1)/2, 425 - 20);
    dashboardView.fitnessLevelBarView.backgroundColor = [UIColor orangeColor];
    dashboardView.fitnessLevelBarView.tag = 2;
    dashboardView.fitnessLevelBarView.layer.cornerRadius = 5;
    dashboardView.fitnessLevelBarView.layer.masksToBounds = YES;
    [dashboardView addSubview: dashboardView.fitnessLevelBarView];
    
    //Add fitness label label to bar
    dashboardView.fitnessRatingForBarLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
    dashboardView.fitnessRatingForBarLabel.center = CGPointMake(dashboardView.redCircleView.frame.origin.x, 260 - 20);
    dashboardView.fitnessRatingForBarLabel.textColor = [UIColor whiteColor];
    dashboardView.fitnessRatingForBarLabel.backgroundColor = [UIColor clearColor];
    dashboardView.fitnessRatingForBarLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(22.0)];
    dashboardView.fitnessRatingForBarLabel.text = [NSString stringWithFormat: @"%.01f of 10", [fitnessRatingNSNumber floatValue]];
    [dashboardView.fitnessRatingForBarLabel sizeToFit];
    dashboardView.fitnessRatingForBarLabel.center = CGPointMake(dashboardView.fitnessLevelBarView.center.x, dashboardView.fitnessLevelBarView.center.y);
    [dashboardView addSubview:dashboardView.fitnessRatingForBarLabel];
    
    if ([fitnessRatingNSNumber floatValue] == 0)
    {
        dashboardView.fitnessRatingForBarLabel.text = [NSString stringWithFormat: @"Not Enough Workouts Detected"];
        dashboardView.fitnessRatingForBarLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(13.0)];
        [dashboardView.fitnessRatingForBarLabel sizeToFit];
        dashboardView.fitnessRatingForBarLabel.center = CGPointMake(dashboardView.grayBarForFitnessLevelBarView.center.x, dashboardView.grayBarForFitnessLevelBarView.center.y);
    }
}

-(void) addFitnessLevelDelimiterLabel:(PFObject *)object
{
    dashboardView.fitnessLevelDelimiterLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
    dashboardView.fitnessLevelDelimiterLabel.center = CGPointMake(0, 0);
    dashboardView.fitnessLevelDelimiterLabel.textColor = [UIColor lightGrayColor];
    dashboardView.fitnessLevelDelimiterLabel.backgroundColor = [UIColor clearColor];
    dashboardView.fitnessLevelDelimiterLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(14.0)];
    dashboardView.fitnessLevelDelimiterLabel.text = [NSString stringWithFormat: @"Fitness Rating"];
    [dashboardView.fitnessLevelDelimiterLabel sizeToFit];
    dashboardView.fitnessLevelDelimiterLabel.center = CGPointMake(dashboardView.grayBarForFitnessLevelBarView.center.x, dashboardView.grayBarForFitnessLevelBarView.center.y - 31);
    [dashboardView addSubview:dashboardView.fitnessLevelDelimiterLabel];
}

-(void) addUserPersonalStats:(PFObject *)object
{
    /*
    NSString *firstName = [NSString stringWithFormat:@"%@", [object objectForKey:@"first_name"]];
    NSString *gender = [NSString stringWithFormat:@"%@", [object objectForKey:@"gender"]];
    
    dashboardView.userPersonalStats = [[UITextView alloc] initWithFrame:CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 100, dashboardView.uploaderPhoto.frame.origin.y, 300, 300)];
    dashboardView.userPersonalStats.text = [NSString stringWithFormat:@"\nName: %@\nGender: %@", firstName, gender];
    dashboardView.userPersonalStats.backgroundColor = [UIColor clearColor];
    //Resize frame size to match contents
    [dashboardView.userPersonalStats sizeToFit];
    [dashboardView addSubview: dashboardView.userPersonalStats];
    dashboardView.userPersonalStats.scrollEnabled = NO;
     */
}

-(int) sevenDayAvgNumOfSteps: (PFObject*)object
{
    NSLog (@"sevenDayAvgNumOfSteps called!");
    
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:@"NumberOfStepsToday"];
    NSNumber *numOfStepsOneDayAgoNSNumber = [object objectForKey:@"NumberOfStepsYesterday"];
    NSNumber *numOfStepsTwoDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsTwoDaysAgo"];
    NSNumber *numOfStepsThreeDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsThreeDaysAgo"];
    NSNumber *numOfStepsFourDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsFourDaysAgo"];
    NSNumber *numOfStepsFiveDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsFiveDaysAgo"];
    NSNumber *numOfStepsSixDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsSixDaysAgo"];

    NSLog (@"numOfStepsTodayNSNumber = %li", (long)[numOfStepsTodayNSNumber integerValue]);
    NSLog (@"numOfStepsOneDayAgoNSNumber = %li", (long)[numOfStepsOneDayAgoNSNumber integerValue]);
    NSLog (@"numOfStepsTwoDaysAgoNSNumber = %li", (long)[numOfStepsTwoDaysAgoNSNumber integerValue]);
    NSLog (@"numOfStepsThreeDaysAgoNSNumber = %li", (long)[numOfStepsThreeDaysAgoNSNumber integerValue]);
    NSLog (@"numOfStepsFourDaysAgoNSNumber = %li", (long)[numOfStepsFourDaysAgoNSNumber integerValue]);
    NSLog (@"numOfStepsFiveDaysAgoNSNumber = %li", (long)[numOfStepsFiveDaysAgoNSNumber integerValue]);
    NSLog (@"numOfStepsSixDaysAgoNSNumber = %li", (long)[numOfStepsSixDaysAgoNSNumber integerValue]);


    
    int sevenDayAvgNumOfStepsInt = 0;
    
    int divisor = 0;
    if ([numOfStepsOneDayAgoNSNumber integerValue] > 0)
        divisor++;
    if ([numOfStepsTwoDaysAgoNSNumber integerValue] > 0)
        divisor++;
    if ([numOfStepsThreeDaysAgoNSNumber integerValue] > 0)
        divisor++;
    if ([numOfStepsFourDaysAgoNSNumber integerValue] > 0)
        divisor++;
    if ([numOfStepsFiveDaysAgoNSNumber integerValue] > 0)
        divisor++;
    if ([numOfStepsSixDaysAgoNSNumber integerValue] > 0)
        divisor++;
    
    numOfDaysWatchWasWorn = divisor;
    NSLog (@"numOfDaysWatchWasWorn = %i", numOfDaysWatchWasWorn);
    
    //Average steps for yesterday through 6 days ago
    int sixDayAvgNumOfStepsInt = (int)([numOfStepsOneDayAgoNSNumber integerValue] + [numOfStepsTwoDaysAgoNSNumber integerValue] + [numOfStepsThreeDaysAgoNSNumber integerValue] + [numOfStepsFourDaysAgoNSNumber integerValue] + [numOfStepsFiveDaysAgoNSNumber integerValue] + [numOfStepsSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    NSLog (@"sixDayAvgNumOfStepsInt = %i", sixDayAvgNumOfStepsInt);
    
    //If today's number of steps is lower than the average of the 6 days prior
    if ([numOfStepsTodayNSNumber integerValue] < sixDayAvgNumOfStepsInt)
    {
        sevenDayAvgNumOfStepsInt = (int)([numOfStepsOneDayAgoNSNumber integerValue] + [numOfStepsTwoDaysAgoNSNumber integerValue] + [numOfStepsThreeDaysAgoNSNumber integerValue] + [numOfStepsFourDaysAgoNSNumber integerValue] + [numOfStepsFiveDaysAgoNSNumber integerValue] + [numOfStepsSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    }
    //If today's number of steps is higher than the average of the 6 days prior
    else
    {
        sevenDayAvgNumOfStepsInt = (int)([numOfStepsTodayNSNumber integerValue] + [numOfStepsOneDayAgoNSNumber integerValue] + [numOfStepsTwoDaysAgoNSNumber integerValue] + [numOfStepsThreeDaysAgoNSNumber integerValue] + [numOfStepsFourDaysAgoNSNumber integerValue] + [numOfStepsFiveDaysAgoNSNumber integerValue] + [numOfStepsSixDaysAgoNSNumber integerValue])/(numOfDaysWatchWasWorn + 1);
    }
    
    //Upload sevenDayAvgNumOfStepsInt to Parse if userObject = [PFUser currentUser]
    
    if ([PFUser currentUser])
    {
        if (object == [PFUser currentUser])
        {
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:sevenDayAvgNumOfStepsInt] forKey:@"sevenDayAvgNumOfSteps"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // some logging code here
                if (succeeded)
                {
                    NSLog (@"sevenDayAvgNumOfSteps data save in background success = %i", sevenDayAvgNumOfStepsInt);
                }
                if (error)
                {
                    NSLog (@"sevenDayAvgNumOfSteps Error saving sevenDayAvgNumOfSteps data = %@", error);
                }
            }];
                
            NSLog (@"sevenDayAvgNumOfStepsInt = %i", sevenDayAvgNumOfStepsInt);
        }
    }
    
    return sevenDayAvgNumOfStepsInt;
}

-(int) sevenDayAvgCaloriesBurned: (PFObject*)object
{
    NSLog (@"sevenDayAvgCaloriesBurned called!");
    
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKey:@"CaloriesBurnedToday"];
    NSNumber *caloriesBurnedYesterdayNSNumber = [object objectForKey:@"CaloriesBurnedOneDayAgo"];
    NSNumber *caloriesBurnedTwoDaysAgoNSNumber = [object objectForKey:@"CaloriesBurnedTwoDaysAgo"];
    NSNumber *caloriesBurnedThreeDaysAgoNSNumber = [object objectForKey:@"CaloriesBurnedThreeDaysAgo"];
    NSNumber *caloriesBurnedFourDaysAgoNSNumber = [object objectForKey:@"CaloriesBurnedFourDaysAgo"];
    NSNumber *caloriesBurnedFiveDaysAgoNSNumber = [object objectForKey:@"CaloriesBurnedFiveDaysAgo"];
    NSNumber *caloriesBurnedSixDaysAgoNSNumber = [object objectForKey:@"CaloriesBurnedSixDaysAgo"];

    int sevenDayAvgNumOfCaloriesBurnedInt = 0;
    
    //Average calories burned for yesterday through 6 days ago
    int sixDayAvgCaloriesBurnedInt = (int)([caloriesBurnedYesterdayNSNumber integerValue] + [caloriesBurnedTwoDaysAgoNSNumber integerValue] + [caloriesBurnedThreeDaysAgoNSNumber integerValue] + [caloriesBurnedFourDaysAgoNSNumber integerValue] + [caloriesBurnedFiveDaysAgoNSNumber integerValue] + [caloriesBurnedSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    NSLog (@"sixDayAvgCaloriesBurnedInt = %i", sixDayAvgCaloriesBurnedInt);
    
    //If today's number of calories burned is lower than the average of the 6 days prior
    if ([caloriesBurnedTodayNSNumber integerValue] < sixDayAvgCaloriesBurnedInt)
    {
        sevenDayAvgNumOfCaloriesBurnedInt = (int)([caloriesBurnedYesterdayNSNumber integerValue] + [caloriesBurnedTwoDaysAgoNSNumber integerValue] + [caloriesBurnedThreeDaysAgoNSNumber integerValue] + [caloriesBurnedFourDaysAgoNSNumber integerValue] + [caloriesBurnedFiveDaysAgoNSNumber integerValue] + [caloriesBurnedSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    }
    //If today's number of calories burned is higher than the average of the 6 days prior
    else
    {
        sevenDayAvgNumOfCaloriesBurnedInt = (int)([caloriesBurnedTodayNSNumber integerValue] + [caloriesBurnedYesterdayNSNumber integerValue] + [caloriesBurnedTwoDaysAgoNSNumber integerValue] + [caloriesBurnedThreeDaysAgoNSNumber integerValue] + [caloriesBurnedFourDaysAgoNSNumber integerValue] + [caloriesBurnedFiveDaysAgoNSNumber integerValue] + [caloriesBurnedSixDaysAgoNSNumber integerValue])/(numOfDaysWatchWasWorn + 1);
    }
    
    if ([PFUser currentUser])
    {
        
        //Upload sevenDayAvgNumOfCaloriesBurned to Parse if userObject = [PFUser currentUser]
        if (object == [PFUser currentUser])
        {
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:sevenDayAvgNumOfCaloriesBurnedInt] forKey:@"sevenDayAvgNumOfCaloriesBurned"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // some logging code here
                if (succeeded)
                {
                    NSLog (@"sevenDayAvgNumOfCaloriesBurned data save in background success = %i", sevenDayAvgNumOfCaloriesBurnedInt);
                }
                if (error)
                {
                    NSLog (@"Error saving sevenDayAvgNumOfCaloriesBurned data = %@", error);
                }
            }];
            NSLog (@"sevenDayAvgNumOfCaloriesBurnedInt = %i", sevenDayAvgNumOfCaloriesBurnedInt);
        }
    }
    
    return sevenDayAvgNumOfCaloriesBurnedInt;
}


-(int) sevenDayAvgMinutesOfExercise: (PFObject*)object
{
    NSLog (@"sevenDayAvgMinutesOfExercise called!");
    
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKey:@"MinutesOfExerciseToday"];
    NSNumber *minutesOfExerciseYesterdayNSNumber = [object objectForKey:@"MinutesOfExerciseOneDayAgo"];
    NSNumber *minutesOfExerciseTwoDaysAgoNSNumber = [object objectForKey:@"MinutesOfExerciseTwoDaysAgo"];
    NSNumber *minutesOfExerciseThreeDaysAgoNSNumber = [object objectForKey:@"MinutesOfExerciseThreeDaysAgo"];
    NSNumber *minutesOfExerciseFourDaysAgoNSNumber = [object objectForKey:@"MinutesOfExerciseFourDaysAgo"];
    NSNumber *minutesOfExerciseFiveDaysAgoNSNumber = [object objectForKey:@"MinutesOfExerciseFiveDaysAgo"];
    NSNumber *minutesOfExerciseSixDaysAgoNSNumber = [object objectForKey:@"MinutesOfExerciseSixDaysAgo"];

    int sevenDayAvgNumOfMinOfExerciseInt = 0;
    
    //Average minutes of exericse for yesterday through 6 days ago
    int sixDayAvgMinOfExerciseInt = (int)([minutesOfExerciseYesterdayNSNumber integerValue] + [minutesOfExerciseTwoDaysAgoNSNumber integerValue] + [minutesOfExerciseThreeDaysAgoNSNumber integerValue] + [minutesOfExerciseFourDaysAgoNSNumber integerValue] + [minutesOfExerciseFiveDaysAgoNSNumber integerValue] + [minutesOfExerciseSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    NSLog (@"sixDayAvgMinOfExerciseInt = %i", sixDayAvgMinOfExerciseInt);
    
    //If today's number of calories burned is lower than the average of the prior 6 days
    if ([minutesOfExerciseTodayNSNumber integerValue] < sixDayAvgMinOfExerciseInt)
    {
        sevenDayAvgNumOfMinOfExerciseInt = (int)([minutesOfExerciseYesterdayNSNumber integerValue] + [minutesOfExerciseTwoDaysAgoNSNumber integerValue] + [minutesOfExerciseThreeDaysAgoNSNumber integerValue] + [minutesOfExerciseFourDaysAgoNSNumber integerValue] + [minutesOfExerciseFiveDaysAgoNSNumber integerValue] + [minutesOfExerciseSixDaysAgoNSNumber integerValue])/numOfDaysWatchWasWorn;
    }
    //If today's number of calories burned is higher than the average of the prior 6 days
    else
    {
        sevenDayAvgNumOfMinOfExerciseInt = (int)([minutesOfExerciseTodayNSNumber integerValue] + [minutesOfExerciseYesterdayNSNumber integerValue] + [minutesOfExerciseTwoDaysAgoNSNumber integerValue] + [minutesOfExerciseThreeDaysAgoNSNumber integerValue] + [minutesOfExerciseFourDaysAgoNSNumber integerValue] + [minutesOfExerciseFiveDaysAgoNSNumber integerValue] + [minutesOfExerciseSixDaysAgoNSNumber integerValue])/(numOfDaysWatchWasWorn + 1);
    }
    
    if ([PFUser currentUser])
    {
        
        //Upload sevenDayAvgNumOfMinOfExercise to Parse if userObject = [PFUser currentUser]
        if (object == [PFUser currentUser])
        {
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:sevenDayAvgNumOfMinOfExerciseInt] forKey:@"sevenDayAvgNumOfMinOfExercise"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // some logging code here
                if (succeeded)
                {
                    NSLog (@"sevenDayAvgNumOfMinOfExercise data save in background success = %i", sevenDayAvgNumOfMinOfExerciseInt);
                }
                if (error)
                {
                    NSLog (@"Error saving sevenDayAvgNumOfMinOfExercise data = %@", error);
                }
            }];
            NSLog (@"sevenDayAvgNumOfMinOfExerciseInt = %i", sevenDayAvgNumOfMinOfExerciseInt);
        }
    }
    
    return sevenDayAvgNumOfMinOfExerciseInt;
}

-(void)userPhotoTapped
{
    PhotoDetailsViewController *viewController = [[PhotoDetailsViewController alloc] init];
    viewController.passedInUserObject = userObject;
    [self.navigationController pushViewController:viewController animated:YES];
}

//This method populates the first cell with the current user's photo and workout stats
-(void) populateUserDashboardView
{
    //Add UIImage to dashboardView
    //Load user photo into
    //NSLog(@"MeViewController userObject = %@", userObject); // self.user is a PFUser Object
    
    if ([PFUser currentUser])
    {
        //Auto generate username and save to parse to use in randomlyGenerateUsername method
        //[self saveInitialAndLastNameToParse];
        
        //Randomly generate username
        //[self randomlyGenerateUsername];
        
    }
    /*
    //Show the number of friends the person has
    //'Friends' label
    dashboardView.friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 168, dashboardView.uploaderPhoto.frame.origin.y + 15, 0, 0)];
    dashboardView.friendsLabel.text = [NSString stringWithFormat:@"friends"];
    dashboardView.friendsLabel.backgroundColor = [UIColor clearColor];
    [dashboardView.friendsLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [dashboardView.friendsLabel sizeToFit];
    dashboardView.friendsLabel.textColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *friendsLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsListTapped:)];
    [dashboardView.numberOfFriendsLabel addGestureRecognizer:friendsLabelTapGesture];
    [dashboardView addSubview: dashboardView.friendsLabel];
    //Label for number of friends the user has
    dashboardView.numberOfFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.friendsLabel.center.x - 5, dashboardView.friendsLabel.center.y - 28, 0, 0)];
    dashboardView.numberOfFriendsLabel.text = [NSString stringWithFormat:@"  --  "];
    dashboardView.numberOfFriendsLabel.backgroundColor = [UIColor clearColor];
    [dashboardView.numberOfFriendsLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [dashboardView.numberOfFriendsLabel sizeToFit];
    dashboardView.numberOfFriendsLabel.center = CGPointMake(dashboardView.friendsLabel.center.x, dashboardView.friendsLabel.center.y - 16);
    dashboardView.numberOfFriendsLabel.textColor = [UIColor darkGrayColor];
    dashboardView.numberOfFriendsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *numberOfFriendsLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsListTapped:)];
    [dashboardView.numberOfFriendsLabel addGestureRecognizer:numberOfFriendsLabelTapGesture];
    [dashboardView addSubview: dashboardView.numberOfFriendsLabel];
    
    
    //Show the number of followers the person has
    //'Followers' label
    dashboardView.followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.uploaderPhoto.frame.origin.x + 235, dashboardView.uploaderPhoto.frame.origin.y + 15, 0, 0)];
    dashboardView.followersLabel.text = [NSString stringWithFormat:@"followers"];
    dashboardView.followersLabel.backgroundColor = [UIColor clearColor];
    [dashboardView.followersLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [dashboardView.followersLabel sizeToFit];
    dashboardView.followersLabel.textColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *followersLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestsListTapped:)];
    [dashboardView.followersLabel addGestureRecognizer:followersLabelTapGesture];
    [dashboardView addSubview: dashboardView.followersLabel];
    //Label for number of followers the person has
    dashboardView.numberOfFollowersLabel = [[UILabel alloc] initWithFrame:CGRectMake(dashboardView.followersLabel.center.x - 5, dashboardView.followersLabel.center.y - 28, 0, 0)];
    dashboardView.numberOfFollowersLabel.text = [NSString stringWithFormat:@"  --  "];
    [dashboardView.numberOfFollowersLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [dashboardView.numberOfFollowersLabel sizeToFit];
    dashboardView.numberOfFollowersLabel.center = CGPointMake(dashboardView.followersLabel.center.x, dashboardView.followersLabel.center.y - 16);
    dashboardView.numberOfFollowersLabel.backgroundColor = [UIColor clearColor];
    dashboardView.numberOfFollowersLabel.textColor = [UIColor darkGrayColor];
    dashboardView.numberOfFollowersLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *numberOfFollowersLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestsListTapped:)];
    [dashboardView.numberOfFollowersLabel addGestureRecognizer:numberOfFollowersLabelTapGesture];
    [dashboardView addSubview: dashboardView.numberOfFollowersLabel];
    
    if ([PFUser currentUser])
    {
        //If the profile doesn't belong to the current user then add a follow button
        if (![userObject.objectId isEqualToString: [PFUser currentUser].objectId])
        {
            // [self addChatButton];
            [self addFollowButton];
            [self addFlagButton];
        }
        else
        {
            //If you're looking at your own profile add the 'Edit Your Profile' button
            [self createEditYourProfileButton];
        }
    }
    */
    //Update number of friends and requests988
    if (userObject)
    {
        NSLog(@"userObject photo = %@", userObject[@"profile_photo"]);
        
        [userObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
           
            if (!error)
            {
                UIImage *image = [UIImage imageWithData:data];
               // NSLog(@"data = %@", data);
                NSLog(@"userObject profile_photo = %@", userObject[@"profile_photo"]);
                // image can now be set on a UIImageView
                dashboardView.uploaderPhoto = [[UIImageView alloc] initWithImage:image];
                dashboardView.uploaderPhoto.frame = CGRectMake(5, -15, 100, 100);
                dashboardView.uploaderPhoto.layer.cornerRadius = dashboardView.uploaderPhoto.frame.size.width / 2;
                dashboardView.uploaderPhoto.clipsToBounds = YES;
                [dashboardView addSubview:dashboardView.uploaderPhoto];
                //[self addUserPersonalStats:userObject];
                
                //Add user editable text field to the right of user's photo
                //Add the 'name' field to the top left
                userEditableTextField = [[UITextView alloc] initWithFrame:CGRectMake(dashboardView.uploaderPhoto.frame.origin.x+ 105, dashboardView.uploaderPhoto.frame.origin.y, 200, 100)];
                NSLog (@"meView userObject = %@", userObject);
                NSLog (@"userEditableProfileText = %@", userObject[@"userEditableProfileText"]);
                if (userObject && userObject[@"userEditableProfileText"])
                {
                    userEditableTextField.text = userObject[@"userEditableProfileText"];
                }
                userEditableTextField.returnKeyType = UIReturnKeyDefault;
                userEditableTextField.delegate = self;
                userEditableTextField.backgroundColor = [UIColor whiteColor];
                userEditableTextField.dataDetectorTypes = UIDataDetectorTypeAll;
                userEditableTextField.selectable = YES;
                [dashboardView addSubview:userEditableTextField];
                if ([userEditableTextField.text isEqualToString:@""] && [userObject.objectId isEqualToString:[PFUser currentUser].objectId])
                {
                    userEditableTextField.text = @"Tap here to add text and links to your profile. Tap outside of this area when you're done...";
                }
                if ([userObject.objectId isEqualToString:[PFUser currentUser].objectId])
                {
                    userEditableTextField.userInteractionEnabled = YES;
                }
                else
                {
                    userEditableTextField.userInteractionEnabled = NO;
                    userEditableTextField.editable = NO;
                }
                userEditableTextField.userInteractionEnabled = YES;

                
                //If the profile doesn't belong to the current user then add a flag button
                if (![userObject.objectId isEqualToString: [PFUser currentUser].objectId])
                {
                    [self addFlagButton];
                }
                else //If the profile DOEs belong to current user add the button that allows user to change photo
                {
                    [self createChangeButton];
                }
                
                //Add tap recognizer to uploaderPhoto so that a full screen version of the photo opens up when user taps it
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPhotoTapped)];
                singleTap.numberOfTapsRequired = 1;
                dashboardView.uploaderPhoto.userInteractionEnabled = YES;
                [dashboardView.uploaderPhoto addGestureRecognizer:singleTap];
                
                //Add label of username under photo
                /*
                usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                usernameLabel.backgroundColor = [UIColor clearColor];
                usernameLabel.font = [UIFont boldSystemFontOfSize:16.0];
                usernameLabel.textAlignment = NSTextAlignmentLeft;
                usernameLabel.textColor = [UIColor darkGrayColor]; // change this color
                usernameLabel.center = CGPointMake(dashboardView.uploaderPhoto.frame.origin.x + 10, dashboardView.uploaderPhoto.frame.origin.y - 325);
                usernameLabel.text = [userObject objectForKey:@"username"];
                [usernameLabel sizeToFit];
                [self.view addSubview:usernameLabel];
                
                //update navBar title as well
                navControllerTitleLabel.text = [userObject objectForKey:@"username"];
                [navControllerTitleLabel sizeToFit];
                */
            }
        }];
    
        [self queryNumberOfFriendsFollowingFollowers:userObject completionHandler:^(double done, NSError *error)
         {
            //update the number of friends the person has
            dashboardView.numberOfFriendsLabel.text = [NSString stringWithFormat:@"  %i  ", numberOfFriends];
            [dashboardView.numberOfFriendsLabel sizeToFit];
            dashboardView.numberOfFriendsLabel.center = CGPointMake(dashboardView.friendsLabel.center.x, dashboardView.friendsLabel.center.y - 16);
             
            //update the number of followers the person has
            if (numberOfFollowers < 10)
                dashboardView.numberOfFollowersLabel.text = [NSString stringWithFormat:@"  %i  ", numberOfFollowers];
            else
                dashboardView.numberOfFollowersLabel.text = [NSString stringWithFormat:@" %i  ", numberOfFollowers];

            dashboardView.numberOfFollowersLabel.center = CGPointMake(dashboardView.followersLabel.center.x, dashboardView.followersLabel.center.y - 16);
         }];
    }
}

- (ActivityCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog (@"[self.objects count] = %li", [self.objects count]);
    
    static NSString *CellIdentifier1;

    
    ActivityCell *cell = (ActivityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (!cell) {
        
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
    }
    
    //Remove photoCaption before you reuse cell
    [cell.photoCaption removeFromSuperview];
    //Remove uploaderPhoto before you reuse cell
    [cell.uploaderPhoto removeFromSuperview];
    //Remove uploaderName label before you reuse cell
    [cell.uploaderName removeFromSuperview];
    //Remove updateAt label before you reuse cell
    [cell.updatedAt removeFromSuperview];
    //Remove elapsed time label before you reuse cell
    [cell.labelElapsed removeFromSuperview];
    
    [cell.contentView.layer setBorderColor:[UIColor grayColor].CGColor];
    [cell.contentView.layer setBorderWidth:0.3];
    
    cell.photoButton.tag = index;
    cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    
    //Change color of every other cell
    if (indexPath.row % 2) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    }
    
    
    cell.uploaderPhoto = [[PFImageView alloc] init];
    cell.uploaderName = [[UILabel alloc] init];
    cell.updatedAt = [[UILabel alloc] init];
    //3rd party class used to convert 'updatedAt' label to something human understable (1 hour ago)
    cell.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];

    
    if (object) {
        
        //Load user's photo for header
        PFUser *uploader = object[@"user"];
        [cell.uploaderPhoto setFile:uploader[@"profile_photo"]];
        //Get uploader's name
        NSString *uploaderName = uploader[@"full_name"];
        //Get updatedAt time
        NSTimeInterval timeInterval = [object.updatedAt timeIntervalSinceDate: [NSDate date]];
        //Convert updatedAt into something more human understable (1 hour ago)
        NSString *humanFriendlyUpdatedAt = [cell.timeIntervalFormatter stringForTimeInterval:timeInterval];
        //Get uploader's photo caption
        NSString *comment = [object objectForKey:@"photoCaption"];

        
        //Call in background to allow image to load and THEN resize it and stuff
        [cell.uploaderPhoto loadInBackground:^(UIImage *image, NSError *error) {
            
            if (!error) {
                
                //Add uploader name to the right of the photo
                cell.uploaderName.text = [NSString stringWithFormat: @"%@", uploaderName];
                cell.uploaderName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
                cell.uploaderName.textColor = [UIColor grayColor];
                cell.uploaderName.frame = CGRectMake(60, 9, cell.uploaderName.frame.size.width, cell.uploaderName.frame.size.height);
                cell.uploaderName.tag = 2;
                [cell.uploaderName sizeToFit];
                cell.uploaderName.backgroundColor = [UIColor clearColor];
                [cell addSubview:cell.uploaderName];
                
                //Add uploader's small photo to top-left of the cell
                cell.uploaderPhoto.frame = CGRectMake(5, 5, 50, 50);
                cell.uploaderPhoto.layer.cornerRadius = cell.uploaderPhoto.frame.size.height/2;
                cell.uploaderPhoto.layer.cornerRadius = cell.uploaderPhoto.frame.size.width/2;
                cell.uploaderPhoto.layer.masksToBounds = YES;
                cell.uploaderPhoto.layer.borderWidth = 0;
                cell.uploaderPhoto.tag = 2;
                [cell addSubview:cell.uploaderPhoto];
                
                
                
                //Query the number of likes on this object (photo)
                PFQuery *query = [Utility queryForActivitiesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    self.likersQueryInProgress = NO;
                    if (error) {
                        return;
                    }
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[userObject objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    NSLog (@"likers count1 = %li", [likers count]);
                    
                    [[Cache sharedCache] setAttributesForPhoto:object likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                    
                    //Add like button
                    cell.likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    //Remove likeButton first before adding it
                    [cell.likeButton removeFromSuperview];
                    [cell addSubview:cell.likeButton];
                    
                    //Configure Like button
                    [cell.likeButton addTarget:self action:@selector(didTapLikePhotoButton:) forControlEvents:UIControlEventTouchUpInside];
                    //Determine number of likers on photo
                    int likeCount = [[[Cache sharedCache] likeCountForPhoto:object] intValue];
                    [cell.likeButton setTitle:[NSString stringWithFormat:@"%i Likes", likeCount] forState:UIControlStateNormal];
                    
                    cell.likeButton.frame = CGRectMake(30, cell.imageView.frame.origin.y + cell.imageView.frame.size.height + 30, 160, 40);
                    [cell.likeButton.titleLabel setFont:[UIFont fontWithName:@"Cooperplate" size:24.0]];
                    [cell.likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [cell.likeButton sizeToFit];
                    cell.likeButton.tag = indexPath.row;
                    
                    //Determine if button is liked by the current user
                    BOOL likedByCurrentUser = [[Cache sharedCache] isPhotoLikedByCurrentUser:object];
                    if (likedByCurrentUser)
                        [cell.likeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    
                    
                }];
            }
            else
            {
                NSLog (@"problem finding uploader photo!");
            }
        }];
        
        //Load uploaded photo
        cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
        
        // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
        if ([cell.imageView.file isDataAvailable]) {
            [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                
                if (!error) {
                                    
                    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];

                    //Init photoCaption label
                    cell.photoCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, cell.imageView.frame.origin.y, 300, 30)];
                    cell.photoCaption.numberOfLines = 0;
                    cell.photoCaption.lineBreakMode = UILineBreakModeWordWrap;

                    //Add the photo's associated comment under the photo
                    if (comment != nil)
                    {
                        cell.photoCaption.text = [NSString stringWithFormat: @"\"%@\"", comment];
                    }
                    else
                    {
                        cell.photoCaption.text = [NSString stringWithFormat:@""];
                    }
                    cell.photoCaption.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
                    cell.photoCaption.textColor = [UIColor darkGrayColor];
                    cell.photoCaption.layer.anchorPoint = CGPointMake(0.5, 0.5);
                    cell.photoCaption.tag = 2;
                    [cell.photoCaption sizeToFit];
                    cell.photoCaption.backgroundColor = [UIColor clearColor];
                    [cell addSubview:cell.photoCaption];
                    //Find the height of the entire comment
                    CGSize labelSize = [cell.photoCaption.text sizeWithFont:cell.photoCaption.font constrainedToSize:cell.photoCaption.frame.size lineBreakMode:UILineBreakModeWordWrap];
                    //Reposition the photoCaption's y value to accomodate its height
                    CGFloat labelHeight = labelSize.height;
                    NSLog (@"labelHeight = %f", labelHeight);
                    cell.photoCaption.frame = CGRectMake(5, 92 - labelHeight, cell.photoCaption.frame.size.width, cell.photoCaption.frame.size.height);

                    
                    //Add updatedAt label beneath the uploader's name
                    NSLog (@"humanFriendlyUpdatedAt = %@", humanFriendlyUpdatedAt);
                    if (humanFriendlyUpdatedAt != nil)
                    {
                        cell.updatedAt.text = [NSString stringWithFormat: @"%@", humanFriendlyUpdatedAt];
                    }
                    else
                    {
                        cell.updatedAt.text = [NSString stringWithFormat:@""];
                    }
                    cell.updatedAt.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
                    cell.updatedAt.textColor = [UIColor grayColor];
                    cell.updatedAt.frame = CGRectMake(60, 29, cell.updatedAt.frame.size.width, cell.updatedAt.frame.size.height);
                    cell.updatedAt.tag = 2;
                    [cell.updatedAt sizeToFit];
                    cell.updatedAt.backgroundColor = [UIColor clearColor];
                    [cell addSubview:cell.updatedAt];
                }
            }];
        }
    }
    
    return cell;
}

#pragma mark - PAPPhotoHeaderViewDelegate

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
/*
- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    
    return nil;
}
*/
- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}

//Commenting this out for now since it has to do with photo detail stuff the MVP will not implement yet
/*
- (void)didTapOnPhotoAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}
*/
/*
 For each object in self.objects, we display two cells. If pagination is enabled, there will be an extra cell at the end.
 NSIndexPath     index self.objects
 0 0 HEADER      0
 0 1 PHOTO       0
 0 2 HEADER      1
 0 3 PHOTO       1
 0 4 LOAD MORE
 */

- (NSIndexPath *)indexPathForObjectAtIndex:(NSUInteger)index header:(BOOL)header {
    return [NSIndexPath indexPathForItem:(index * 2 + (header ? 0 : 1)) inSection:0];
}

- (NSUInteger)indexForObjectAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row / 2;
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    
    NSLog (@"MeView didTapAnywhere called!");
    
    //Save textview text to Parse
    if (userObject)
        userObject[@"userEditableProfileText"] = userEditableTextField.text;
    
    [[PFUser currentUser] saveInBackground];
    
    [userEditableTextField resignFirstResponder];
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


