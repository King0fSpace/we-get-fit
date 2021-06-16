//
//  HealthMethods.m
//  Fitness
//
//  Created by Long Le on 3/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "HealthMethods.h"
#import "MeViewController.h"
#import "HomeView.h"
#import "MotivationFriendsListViewController.h"
#import "ChallengesViewController.h"


@implementation HealthMethods


@synthesize yesterdaysStepSamplesArray;
@synthesize twoDaysAgoStepSamplesArray;
@synthesize threeDaysAgoStepSamplesArray;
@synthesize fourDaysAgoStepSamplesArray;
@synthesize fiveDaysAgoStepSamplesArray;
@synthesize sixDaysAgoStepSamplesArray;

@synthesize todaysHeartRatesArray;
@synthesize yesterdaysHeartRatesArray;
@synthesize twoDaysAgoHeartRatesArray;
@synthesize threeDaysAgoHeartRatesArray;
@synthesize fourDaysAgoHeartRatesArray;
@synthesize fiveDaysAgoHeartRatesArray;
@synthesize sixDaysAgoHeartRatesArray;
@synthesize heartRatesForDateRangeArray;

@synthesize lastSixDaysWorthOfWorkoutsArray;

@synthesize todaysMinOfExercise;
@synthesize todaysCaloriesBurned;

@synthesize userSharedStepsData;
@synthesize dataSources;
@synthesize sourcesSet;
@synthesize iPhoneSourcePredicate;
@synthesize appleWatchSourcePredicate;

@synthesize archivedReadingsArray;

@synthesize workoutCreditMultiplierDouble;

HKHealthStore *healthStore;

-(id) init
{
    NSLog (@"HealthMethods init called!");
    
    self = [super init];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HeartRatesQueryCurrentlyRunning"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dataSources = [[NSMutableArray alloc] init];

    userSharedStepsData = NO;
    
    healthStore = [[HKHealthStore alloc] init];
    
    archivedReadingsArray = [[NSMutableArray alloc] init];
    
    //Step samples array
    yesterdaysStepSamplesArray = [[NSMutableArray alloc] init];
    twoDaysAgoStepSamplesArray = [[NSMutableArray alloc] init];
    threeDaysAgoStepSamplesArray = [[NSMutableArray alloc] init];
    fourDaysAgoStepSamplesArray = [[NSMutableArray alloc] init];
    fiveDaysAgoStepSamplesArray = [[NSMutableArray alloc] init];
    sixDaysAgoStepSamplesArray = [[NSMutableArray alloc] init];
    
    //Heart rates array
    todaysHeartRatesArray = [[NSMutableArray alloc] init];
    yesterdaysHeartRatesArray = [[NSMutableArray alloc] init];
    twoDaysAgoHeartRatesArray = [[NSMutableArray alloc] init];
    threeDaysAgoHeartRatesArray = [[NSMutableArray alloc] init];
    fourDaysAgoHeartRatesArray = [[NSMutableArray alloc] init];
    fiveDaysAgoHeartRatesArray = [[NSMutableArray alloc] init];
    sixDaysAgoHeartRatesArray = [[NSMutableArray alloc] init];
    heartRatesForDateRangeArray = [[NSMutableArray alloc] init];
    
    //Workouts array
    lastSixDaysWorthOfWorkoutsArray = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)queryTotalNumberOfWorldChallengers: (void (^)(double, int, int, NSError *))completionHandler
{
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
    //[query whereKey:@"updatedAt" greaterThanOrEqualTo:twoDaysAgoAtMidnight];

    ChallengesViewController *challengesViewSubClass = [[ChallengesViewController alloc] init];
    
    if ([challengesViewSubClass dayOfTheWeek] == 1)
        [query orderByDescending:@"ChallengeDay1ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 2)
        [query orderByDescending:@"ChallengeDay2ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 3)
        [query orderByDescending:@"ChallengeDay3ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 4)
        [query orderByDescending:@"ChallengeDay4ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 5)
        [query orderByDescending:@"ChallengeDay5ListRankingScore"];
    else
        [query orderByDescending:@"ChallengeDay6ListRankingScore"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            int totalChallengers = (int)[objects count];
            int yourRank = 1000;
            
            //Find out your rank among the challengers
            for (PFObject *object in objects)
            {
                if ([PFUser currentUser])
                {
                    NSLog (@"object username = %@, your username = %@", object[@"username"], [PFUser currentUser][@"username"]);
                    if ([object[@"username"] isEqualToString:[PFUser currentUser][@"username"]])
                    {
                        yourRank = (int)[objects indexOfObject:object] + 1;
                        NSLog (@"yourRank = %i", yourRank);
                    }
                }
            }
            
            completionHandler(YES, yourRank, totalChallengers, nil);
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)queryTotalNumberOfFacebookFriendsChallengers: (void (^)(double, int, int, NSError *))completionHandler
{
    PFQuery *query;
    
    NSArray *facebookFriendsObjectIdsNSArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsObjectIdsArray"];
    NSMutableArray *facebookFriendsObjectIdsMutableArray = [[NSMutableArray alloc] init];
    [facebookFriendsObjectIdsMutableArray addObjectsFromArray:facebookFriendsObjectIdsNSArray];
    //Add your objectId to the array so it shows up on the Friends Challenge list
    NSString *yourObjectId = (NSString*)[PFUser currentUser].objectId;
    [facebookFriendsObjectIdsMutableArray addObject:yourObjectId];
    
    NSLog (@"facebookFriendsObjectIdsArray count = %li", [facebookFriendsObjectIdsMutableArray count]);
    
    for (NSString *objectId in facebookFriendsObjectIdsMutableArray)
    {
        NSLog (@"facebookFriendObjectId = %@", objectId);
    }
    [query whereKey:@"objectId" containedIn:facebookFriendsObjectIdsMutableArray];
    
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
    //[query whereKey:@"updatedAt" greaterThanOrEqualTo:twoDaysAgoAtMidnight];
    
    ChallengesViewController *challengesViewSubClass = [[ChallengesViewController alloc] init];
    
    if ([challengesViewSubClass dayOfTheWeek] == 1)
        [query orderByDescending:@"ChallengeDay1ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 2)
        [query orderByDescending:@"ChallengeDay2ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 3)
        [query orderByDescending:@"ChallengeDay3ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 4)
        [query orderByDescending:@"ChallengeDay4ListRankingScore"];
    else if ([challengesViewSubClass dayOfTheWeek] == 5)
        [query orderByDescending:@"ChallengeDay5ListRankingScore"];
    else
        [query orderByDescending:@"ChallengeDay6ListRankingScore"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             int totalChallengers = (int)[objects count];
             int yourRank = 1000;
             
             //Find out your rank among the challengers
             for (PFObject *object in objects)
             {
                 if ([PFUser currentUser])
                 {
                     NSLog (@"object username = %@, your username = %@", object[@"username"], [PFUser currentUser][@"username"]);
                     if ([object[@"username"] isEqualToString:[PFUser currentUser][@"username"]])
                     {
                         yourRank = (int)[objects indexOfObject:object] + 1;
                         NSLog (@"yourRank = %i", yourRank);
                     }
                 }
             }
             
             completionHandler(YES, yourRank, totalChallengers, nil);
         }
         else
         {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];
}

-(void)fetchSources:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"fetchSources called!");
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *prefix = [NSString stringWithFormat:@"com.apple.health"];
    HKQuantityType *stepsCount = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:stepsCount
                                                           samplePredicate:nil
                                                         completionHandler:^(HKSourceQuery *query, NSSet *sources, NSError *error)
                                  {
                                      for (HKSource *source in sources)
                                      {
                                          if ([source.bundleIdentifier hasPrefix:prefix])
                                          {
                                              /*
                                              if ([source.name isEqualToString:deviceName])
                                              {
                                                  // Iphone
                                                  [dataSources addObject:source];
                                                  iPhoneSourcePredicate = [HKQuery predicateForObjectsFromSource: source];
                                                  NSLog (@"source = %@", source);
                                              }
                                              else
                                              {
                                                  // Apple Watch
                                                  [dataSources addObject:source];
                                                  appleWatchSourcePredicate = [HKQuery predicateForObjectsFromSource: source];
                                                  NSLog (@"source = %@", source);
                                              }
                                              */
                                              //Only accept data collected by Apple Watch
                                              if (![source.name isEqualToString:deviceName])
                                              {
                                                  // Apple Watch
                                                  [dataSources addObject:source];
                                                  appleWatchSourcePredicate = [HKQuery predicateForObjectsFromSource: source];
                                                  NSLog (@"source = %@", source);
                                              }
                                          }
                                      }
                                      
                                      completionHandler(YES, nil);
                                  }];
    
    [healthStore executeQuery:sourceQuery];
}

-(int)numberOfDaysBetweenQueryLastRunAndNow
{
    NSLog (@"numberOfDaysBetweenQueryLastRunAndNow called!");
    NSLog (@"all6DaysWorthOfHealthMethodsAlreadyRunForFirstTime = %i", [[NSUserDefaults standardUserDefaults] boolForKey:@"all6DaysWorthOfHealthMethodsAlreadyRunForFirstTime"]);
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"all6DaysWorthOfHealthMethodsAlreadyRunForFirstTime"] == NO)
        {
            return 6; //If this is the first time running the app run all 6 days worth of stats
        }
        else
        {
            return 1; //Run two days worth of stats if all 6 days worth have already been run for the first time and app is in background
        }
    }
    else
    {
        NSLog (@"app is in foreground so only run today's and yesterday's health stats.");
        
        return 6;
    }
}

-(NSString*) workoutString: (HKWorkoutActivityType)workoutType
{
    NSString *result = nil;
    
    switch(workoutType)
    {
        case 1:
            result = @"American Football";
            break;
        case 2:
            result = @"Archery";
            break;
        case 3:
            result = @"Australian Football";
            break;
        case 4:
            result = @"Badminton";
            break;
        case 5:
            result = @"Baseball";
            break;
        case 6:
            result = @"Basketball";
            break;
        case 7:
            result = @"Bowling";
            break;
        case 8:
            result = @"Boxing";
            break;
        case 9:
            result = @"Climbing";
            break;
        case 10:
            result = @"Cricket";
            break;
        case 11:
            result = @"Cross Training";
            break;
        case 12:
            result = @"Curling";
            break;
        case 13:
            result = @"Cycling";
            break;
        case 14:
            result = @"Dance";
            break;
        case 15:
            result = @"Dance Inspired Training";
            break;
        case 16:
            result = @"Elliptical";
            break;
        case 17:
            result = @"Equestrian Sports";
            break;
        case 18:
            result = @"Fencing";
            break;
        case 19:
            result = @"Fishing";
            break;
        case 20:
            result = @"Strength Training";
            break;
        case 21:
            result = @"Golf";
            break;
        case 22:
            result = @"Gymnastics";
            break;
        case 23:
            result = @"Handball";
            break;
        case 24:
            result = @"Hiking";
            break;
        case 25:
            result = @"Hockey";
            break;
        case 26:
            result = @"Hunting";
            break;
        case 27:
            result = @"Lacrosse";
            break;
        case 28:
            result = @"Martial Arts";
            break;
        case 29:
            result = @"Mind and Body";
            break;
        case 30:
            result = @"Mixed Metabolic Cardio Training";
            break;
        case 31:
            result = @"Paddle Sports";
            break;
        case 32:
            result = @"Play";
            break;
        case 33:
            result = @"Preparation and Recovery";
            break;
        case 34:
            result = @"Racquetball";
            break;
        case 35:
            result = @"Rowing";
            break;
        case 36:
            result = @"Rugby";
            break;
        case 37:
            result = @"Running";
            break;
        case 38:
            result = @"Sailing";
            break;
        case 39:
            result = @"Skating Sports";
            break;
        case 40:
            result = @"Snow Sports";
            break;
        case 41:
            result = @"Soccer";
            break;
        case 42:
            result = @"Softball";
            break;
        case 43:
            result = @"Squash";
            break;
        case 44:
            result = @"Stair Climbing";
            break;
        case 45:
            result = @"Surfing";
            break;
        case 46:
            result = @"Swimming";
            break;
        case 47:
            result = @"Table Tennis";
            break;
        case 48:
            result = @"Tennis";
            break;
        case 49:
            result = @"Track and Field";
            break;
        case 50:
            result = @"Traditional Strength Training";
            break;
        case 51:
            result = @"Volleyball";
            break;
        case 52:
            result = @"Walking";
            break;
        case 53:
            result = @"Water Fitness";
            break;
        case 54:
            result = @"Water Polo";
            break;
        case 55:
            result = @"Water Sports";
            break;
        case 56:
            result = @"Wrestling";
            break;
        case 57:
            result = @"Yoga";
            break;
        case 3000:
            result = @"Other";
            break;
    }
    
    return result;
}

//Query all of yesterday's HR's
- (void)queryHeartRatesForGivenDateRange:startDateArg endDate:(NSDate*)endDateArg completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryHeartRatesForGivenDateRange running!");

    // Create a predicate to set start/end date bounds of the query
    NSPredicate *dateRangePredicate = [HKQuery predicateForSamplesWithStartDate:startDateArg endDate:endDateArg options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:dateRangePredicate, wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Run the query
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's heart rate samples for yesterday. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            [heartRatesForDateRangeArray removeAllObjects];
            
            [heartRatesForDateRangeArray addObjectsFromArray:results];
            
            completionHandler(YES, nil);
        }
    }];
    
    [healthStore executeQuery:query];
}

//Method calculates # of seconds HR was above 100 during and after workout
-(void)workoutCreditMultiplier:(HKWorkout*)workoutArg completion:(void (^)(double, double, NSError *))completionHandler
{
    NSLog (@"workoutCreditMultiplier called!");
    
    //Query for all HR's between startTimeArg and endTimeArg
    NSDate *workoutStartTime = [workoutArg startDate];
    NSDate *workoutEndTime = [workoutArg endDate];

    [self queryHeartRatesForGivenDateRange:workoutStartTime endDate:workoutEndTime completion:^(double done, NSError *error)
    {
        double sampleBPMDouble = 0;
        double differenceInSecondsOfDateRange = 0;
        workoutCreditMultiplierDouble = 0;
        
        //Iterate through array of HR's
        for (int i = 1; i < [heartRatesForDateRangeArray count]; i++) //set i = 1 so that you can always reference previous object in array
        {
            HKQuantitySample *sample = [heartRatesForDateRangeArray objectAtIndex:i];
            
            sampleBPMDouble = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //If 'addToWorkoutCredit' is YES, AND current sample's bpm is greater than 100, get 'startDate' for current sample, and add the difference of seconds between the current sample's 'startDate' and the last sample's 'startDate' to workoutCreditMultiplierInt.  skip the rest and iterate over next sample
            if (sampleBPMDouble > 100 && [heartRatesForDateRangeArray indexOfObject:sample] != [heartRatesForDateRangeArray count] - 1)
            {
                //Previous sample in heartRatesForDateRangeArray's date
                NSDate *previousSampleNSDate = [[heartRatesForDateRangeArray objectAtIndex: [heartRatesForDateRangeArray indexOfObject:sample] - 1] startDate];
                //Current sample in heartRatesForDateRangeArray's date
                NSDate *currentSampleNSDate = [sample startDate];
                
                differenceInSecondsOfDateRange = [currentSampleNSDate timeIntervalSinceDate:previousSampleNSDate];
                workoutCreditMultiplierDouble = workoutCreditMultiplierDouble + differenceInSecondsOfDateRange;
                //NSLog (@"workout ended above 100bpm, workoutCreditMultiplierDouble = %f", workoutCreditMultiplierDouble);
                
                //NSLog (@"[%i of %lu], credit to add = %f, workoutCreditMultiplierDouble so far = %f", (int)[heartRatesForDateRangeArray indexOfObject:sample], (unsigned long)[heartRatesForDateRangeArray count], differenceInSecondsOfDateRange, workoutCreditMultiplierDouble);
            }
            
            //If 'addToWorkoutCredit' is YES, AND current sample's bpm is lower than 100, iterate over the next 8 minutes worth of samples.
            else if (sampleBPMDouble < 100 && [heartRatesForDateRangeArray indexOfObject:sample] != [heartRatesForDateRangeArray count] - 1)
            {
                //Iterate over every over the next 8 minutes' worth of samples
                for (int j = (int)[heartRatesForDateRangeArray indexOfObject:sample] + 1; j < [heartRatesForDateRangeArray count]; j++)
                @autoreleasepool
                {
                    HKQuantitySample *nextSample = [heartRatesForDateRangeArray objectAtIndex:j];
                    
                    NSDate *currentSampleNSDate = [sample startDate];
                    NSDate *nextSampleNSDate = [nextSample startDate];
                    //Time in seconds
                    NSTimeInterval differenceInSecondsOfDateRange = [nextSampleNSDate timeIntervalSinceDate:currentSampleNSDate];

                    //If sample's time is no more than 8 minutes ahead of the current sample
                    if (differenceInSecondsOfDateRange < 480)
                    {
                        double nextSampleBPMDouble = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //if nextSample's bpm is over the next 8 minutes is greater than 100, get 'startDate' for current sample, and add the difference of seconds between the current sample's 'startDate' and the last sample's 'startDate' to workoutCreditMultiplierInt. skip the rest and iterate over next sample
                        if (nextSampleBPMDouble > 100)
                        {
                            //Previous sample in heartRatesForDateRangeArray's date
                            NSDate *nextSampleNSDate = [[heartRatesForDateRangeArray objectAtIndex: j] startDate];
                            //Current sample in heartRatesForDateRangeArray's date
                            NSDate *currentSampleNSDate = [sample startDate];
                            
                            differenceInSecondsOfDateRange = [nextSampleNSDate timeIntervalSinceDate:currentSampleNSDate];
                            workoutCreditMultiplierDouble = workoutCreditMultiplierDouble + differenceInSecondsOfDateRange;
                            
                            //Right here start iterating from the position nextSample is in
                            i = j - 1;
                            
                            break;
                        }
                    }
                }
            }
            
            //If you're looking at the last sample
            if ([heartRatesForDateRangeArray indexOfObject:sample] == [heartRatesForDateRangeArray count] - 1)
            {
                //If current sample is the last sample in results AND If endTime HR is above 100, then actual endTime HR is exactly what it says. Give credit based on that.
                
                if (sampleBPMDouble > 100)
                {
                    //Algo: (finalHRBPM - 100)/5 = additionalCreditToAdd*(workoutDurationInHours)
                    double additionalCreditToAdd = (sampleBPMDouble - 100)/5;
                    double workoutDurationInHours = [workoutArg duration]/60/60;
                    additionalCreditToAdd = 60*additionalCreditToAdd*workoutDurationInHours; //in seconds
                    
                    workoutCreditMultiplierDouble = workoutCreditMultiplierDouble + additionalCreditToAdd;
                    NSLog (@"Final Sample ended ABOVE, at %f, %f additional credit awarded", sampleBPMDouble, additionalCreditToAdd);
                }
                
                //OTHERWISE, If endTime HR is below 100, determine if its a false reading. If HR was above 100bpm within the last 5 minutes of the workout its a false reading.  Set endTime HR to the next highest HR reading before the end of the workout. Give credit on that HR.
                else
                {
                    NSLog (@"Final Sample ended BELOW 100");
                    HKQuantitySample *lastSample = [heartRatesForDateRangeArray objectAtIndex:[heartRatesForDateRangeArray count] - 1];
                    double lastSampleBPM = [[lastSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    //NSLog (@"workout ended with bpm lower than 100bpm, at %f", lastSampleBPM);
                    //determine position of sample closest to the 8min mark before the end of the workout
                    if ([workoutArg duration] > 480) //make sure workout duration is larger than 8 min
                    {
                        double lastEightMinMarkOfWorkout = [workoutArg duration] - 480; //number of seconds into the workout that's closest to 8min before the end

                        //iterate through heartRatesForDateRangeArray
                        for (HKQuantitySample *sample2 in heartRatesForDateRangeArray)
                        @autoreleasepool
                        {
                            double numOfSecondsIntoWorkoutFromSample2StartDate = [[sample2 startDate] timeIntervalSinceDate:[workoutArg startDate]];
                            
                            //find the value that's just less than the 8min mark
                            if (numOfSecondsIntoWorkoutFromSample2StartDate > lastEightMinMarkOfWorkout)
                            {
                                //take the sample at the 8min mark and find its position in the array
                                long int posOfSampleAtEightMinMarkFromEndOfWorkout = [heartRatesForDateRangeArray indexOfObject:sample2];
                                
                                //start iterating through heartRatesForDateRangeArray from the position determined above
                                for (int k = (int)posOfSampleAtEightMinMarkFromEndOfWorkout; k < [heartRatesForDateRangeArray count]; k++)
                                @autoreleasepool
                                {
                                    HKQuantitySample *sampleWithinFinalEightMinRange = [heartRatesForDateRangeArray objectAtIndex:k];
                                    double sampleWithinLastEightMinBPMDouble = [[sampleWithinFinalEightMinRange quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                                  
                                    //If 'sampleWithinLastEightMinBPMDouble' HR is above 100, then actual endTime HR the time stamp associated with this HR. Give credit based on that.
                                    if (sampleWithinLastEightMinBPMDouble > 100)
                                    {
                                        HKQuantitySample *sampleAtEightMinMark = sampleWithinFinalEightMinRange;
                                        double numOfSecInLastEightMinOfWorkout = [[workoutArg endDate] timeIntervalSinceDate:[sampleAtEightMinMark startDate]]; // in seconds
                                       // NSLog (@"numOfSecInLastEightMinOfWorkout = %f",numOfSecInLastEightMinOfWorkout);
                                        double numOfSecUpUntilLastEightMinOfWorkout = [workoutArg duration] - numOfSecInLastEightMinOfWorkout;

                                        //set 'workoutCreditMultiplierDouble' to the duration of the workout upto that sample's point.
                                        workoutCreditMultiplierDouble = numOfSecUpUntilLastEightMinOfWorkout;
                                        
                                        //Use the algo in the above 'if' block to determine how much credit to add onto 'workoutCreditMultiplierDouble'
                                        double additionalCreditToAdd = (sampleWithinLastEightMinBPMDouble - 100)/5;
                                        double workoutDurationInHours = [workoutArg duration]/60/60;
                                        additionalCreditToAdd = 60*additionalCreditToAdd*workoutDurationInHours; //in seconds
                                        //NSLog (@"final additionalCreditToAdd = %f", additionalCreditToAdd);
                                        
                                        workoutCreditMultiplierDouble = workoutCreditMultiplierDouble + additionalCreditToAdd;
                                       // NSLog (@"workoutCreditMultiplierDouble = %f", workoutCreditMultiplierDouble);
                                        //NSLog (@"additionalCreditToAdd = %f", additionalCreditToAdd);
                                        //NSLog (@"workout ended below 100bpm, final workout credit workoutCreditMultiplierDouble = %f", workoutCreditMultiplierDouble);

                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        NSLog (@"workoutCreditMultiplierDouble from workoutCreditMultiplier method = %f", workoutCreditMultiplierDouble/workoutArg.duration);
        
        completionHandler(YES, workoutCreditMultiplierDouble/workoutArg.duration, nil);
    }];
}
/*
-(void)localNotificationForWorkoutMotivation: (UIViewController*)viewControllerArg
{
    NSLog (@"HealthMethods localNotificationForWorkoutMotivation");
    
    //Schedule local notification using the above NSString
    NSString *messageToSend = [NSString stringWithFormat:@"Attribute your workout motivation to someone? We'll send them a notification."];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    [notification setAlertBody:messageToSend];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
*/
-(void)dialogueBoxForWorkoutMotivation: (UIViewController*)viewControllerArg
{
    NSLog (@"HealthMethods dialogueBoxForWorkoutMotivation");
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShowMotivationDialogueBox"];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Motivation"
                                                                   message:@"Nice workout! Care to attribute your motiviation to someone? We'll send them a notification."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   MotivationFriendsListViewController *motivationFriendsSubClass = [[MotivationFriendsListViewController alloc] init];
                                   //Show a new view controller which has a list of people that allows the user to select one to send the message to
                                   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:motivationFriendsSubClass];
                                   for (UIView *view in navController.navigationBar.subviews)
                                   {
                                       if (view.tag != 0)
                                       {
                                           [view removeFromSuperview];
                                       }
                                   }
                                   [viewControllerArg presentViewController:navController animated:YES completion:nil];
                                   NSLog (@"motivationFriendsSubClass should be presented");
                               }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [viewControllerArg dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:okAction];
    [alert addAction:noAction];
    [viewControllerArg presentViewController:alert animated:YES completion:nil];
}

-(void)queryWorkoutsForTheLastSixDays: (MeViewController*)viewController completion:(void (^)(double, NSError *))completionHandler
{
    //NSPredicate *predicate = [HKQuery predicateForWorkoutsWithWorkoutActivityType: HKWorkoutActivityTypeRunning];
    
    NSLog (@"queryWorkoutsForTheLastSixDays called!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for six days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-144];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];

    // Create a predicate to set start/end date bounds of the query
    NSPredicate *lastSixDays = [HKQuery predicateForSamplesWithStartDate:sixDaysAgoAtMidnight endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:lastSixDays, sourcesPredicate, wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error)
    {
        if (results == nil)
        {
            // Perform proper error handling here...
            NSLog(@"*** An error occurred while adding a sample to "
                  @"the workout: %@ ***",
                  error.localizedDescription);
            
            // abort();
        }
        else
        {
            //Save all workouts to lastSixDaysWorthOfWorkoutsArray
            [lastSixDaysWorthOfWorkoutsArray addObjectsFromArray:results];
            
            for (HKWorkout *result in lastSixDaysWorthOfWorkoutsArray)
            {
                [self workoutCreditMultiplier:result completion:^(double done, double multiplier, NSError *error)
                {
                    int totalMinutesOfRunning = 0;
                    
                    totalMinutesOfRunning += [result duration]/60;
                    
                    NSLog (@"Workout type = %@, Workout date = %@, Workout Calories Burned = %f, Duration = %f, Calculated Duration = %f", [self workoutString:result.workoutActivityType], [result startDate], [result.totalEnergyBurned doubleValueForUnit:[HKUnit calorieUnit]]/1000, [result duration]/60, [result duration]*multiplier/60);
                   
                    double workoutMultiplier = multiplier;
                    NSLog (@"multiplier = %f", multiplier);
                    NSLog (@"workoutMultiplier = %f", workoutMultiplier);
                    
                    //Save last workout result to Parse as a 'Workout' parse object
                    //NSLog (@"workoutCreditMultiplierDouble (min) = %f", workoutCreditMultiplierDouble/60);
                    //NSLog (@"lastWorkout workoutActivityType = %@", [self workoutString:result.workoutActivityType]);
                    PFObject *workoutParseObject = [PFObject objectWithClassName:@"Workouts"];
                    workoutParseObject[@"type"] = [NSString stringWithFormat: @"%@", [self workoutString:result.workoutActivityType]];
                    NSTimeInterval workoutDuration = workoutMultiplier*result.duration;
                    int workoutDurationInteger = workoutDuration;
                    NSNumber *workoutDurationNSNumber = [NSNumber numberWithInt:workoutDurationInteger];
                    workoutParseObject[@"Duration"] = workoutDurationNSNumber;
                    int caloriesBurnedInt = workoutMultiplier*([result.totalEnergyBurned doubleValueForUnit:[HKUnit calorieUnit]]/1000);
                    NSLog (@"caloriesBurnedInt! = %d", caloriesBurnedInt);
                    workoutParseObject[@"CaloriesBurned"] = [NSNumber numberWithInt:caloriesBurnedInt];
                    int workoutDistance = [result.totalDistance doubleValueForUnit:[HKUnit mileUnit]];
                    workoutParseObject[@"Distance"] = [NSNumber numberWithInt:workoutDistance];
                    workoutParseObject[@"WorkoutDate"] = result.startDate;
                    workoutParseObject[@"WorkoutSource"] = result.source.name;
                    workoutParseObject[@"WorkoutHealthKitUUID"] = result.UUID.UUIDString;
                    
                    if ([PFUser currentUser])
                        workoutParseObject[@"user"] = [PFUser currentUser];
                    
                    if ([PFUser currentUser])
                        workoutParseObject[@"userObjectId"] = [PFUser currentUser].objectId;
                    
                    // Query all parse Workout objects and save this workout ONLY if the UUIDString doesn't already exist in Parse and workout minutes is above 5minutes
                    if (workoutDurationInteger > 300) //if workout is greater than 5 minutes
                    {
                        PFQuery *query = [PFQuery queryWithClassName:@"Workouts"];
                        [query whereKey:@"WorkoutHealthKitUUID" equalTo:result.UUID.UUIDString];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                         {
                             if (!error)
                             {
                                 if ([objects count] > 0)
                                 {
                                     NSLog (@"workout already exists in parse so don't save it again!");
                                 }
                                 else
                                 {
                                     NSLog (@"HealthMethods saving workout");
                                 
                                     [workoutParseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                         
                                         //Save to NSUserDefaults the duration of the last workout saved to NSUserDefaults
                                         [[NSUserDefaults standardUserDefaults] setDouble:result.duration forKey:@"DurationOfLastWorkoutInSeconds"];
                                     }];
                                 }
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
            
            NotificationsView *subclass = [[NotificationsView alloc] init];
            [subclass.tableView reloadData];
            
            NSDate *now = [NSDate date];
            
            NSDate *todayAtMidnight = [NSDate date];
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
            todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
            
            [self queryMinutesOfWorkoutsForStartDate:todayAtMidnight endDate:now datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseToday" calBurnParseKeyToSaveTo:@"CaloriesBurnedToday" completion:^(double done, NSError *error)
            {
                //Call query to determine passive exercise minutes here;
                [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:todayAtMidnight endDate:now datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseToday" calBurnParseKeyToSaveTo:@"CaloriesBurnedToday" listRankingScoreParseKeyToSaveTo:@"listRankingScore" numOfStepsParseKeyToPullFrom:@"NumberOfStepsToday" completion:^(double done, NSError *error)
                {
                    if (done)
                        [viewController addColoredCircles];
                    
                    //Call method to calculate 'fitness_rating' here since all other health queries are now finished
                    [self calculateFitnessRating: viewController completion:^(double done, NSError *error)
                     {
                         
                     }];
                    
                    //Query for yesterdays exercise minutes
                    //Used to help NSDates at midnight
                    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
                    
                    //today at midnight
                    NSDate *todayAtMidnight = [NSDate date];
                    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
                    
                    //get NSDate for yesterday at midnight
                    NSCalendar *cal = [NSCalendar currentCalendar];
                    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
                    [components setHour:-24];
                    [components setMinute:0];
                    [components setSecond:0];
                    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
                    
                    [self queryMinutesOfWorkoutsForStartDate:yesterdayAtMidnight endDate:todayAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseOneDayAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedOneDayAgo" completion:^(double done, NSError *error)
                     {
                         //Call query to determine passive exercise minutes here;
                         [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:yesterdayAtMidnight endDate:todayAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseOneDayAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedOneDayAgo" listRankingScoreParseKeyToSaveTo:@"yesterdaysListRankingScore" numOfStepsParseKeyToPullFrom:@"NumberOfStepsOneDayAgo" completion:^(double done, NSError *error)
                          {
                              //Query for two days ago's minutes of exercise
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
                              
                              //yesterdayAtMidnight used to get todayPredicate
                              [components setHour:-24];
                              [components setMinute:0];
                              [components setSecond:0];
                              NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                              yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
                              
                              [self queryMinutesOfWorkoutsForStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseTwoDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedTwoDaysAgo" completion:^(double done, NSError *error)
                               {
                                   //Call query to determine passive exercise minutes here;
                                   [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseTwoDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedTwoDaysAgo" listRankingScoreParseKeyToSaveTo:@"listRankingScoreTwoDaysAgo" numOfStepsParseKeyToPullFrom:@"NumberOfStepsTwoDaysAgo" completion:^(double done, NSError *error)
                                    {
                                        //Used to help NSDates at midnight
                                        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                        NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
                                        
                                        //today at midnight
                                        NSDate *todayAtMidnight = [NSDate date];
                                        todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
                                        
                                        
                                        //get NSDate for three days ago at midnight
                                        NSCalendar *cal = [NSCalendar currentCalendar];
                                        NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
                                        [components setHour:-72];
                                        [components setMinute:0];
                                        [components setSecond:0];
                                        NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                        threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
                                        
                                        //yesterdayAtMidnight used to get todayPredicate
                                        [components setHour:-48];
                                        [components setMinute:0];
                                        [components setSecond:0];
                                        NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                        twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
                                        
                                        [self queryMinutesOfWorkoutsForStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseThreeDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedThreeDaysAgo" completion:^(double done, NSError *error)
                                         {
                                             //Call query to determine passive exercise minutes here;
                                             [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseThreeDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedThreeDaysAgo" listRankingScoreParseKeyToSaveTo:@"listRankingScoreThreeDaysAgo" numOfStepsParseKeyToPullFrom:@"NumberOfStepsThreeDaysAgo"  completion:^(double done, NSError *error)
                                              {
                                                  //today at midnight
                                                  NSDate *todayAtMidnight = [NSDate date];
                                                  todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
                                                  
                                                  
                                                  //get NSDate for four days ago at midnight
                                                  NSCalendar *cal = [NSCalendar currentCalendar];
                                                  NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
                                                  [components setHour:-96];
                                                  [components setMinute:0];
                                                  [components setSecond:0];
                                                  NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                  fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
                                                  
                                                  //yesterdayAtMidnight used to get todayPredicate
                                                  [components setHour:-72];
                                                  [components setMinute:0];
                                                  [components setSecond:0];
                                                  NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                  threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
                                                  
                                                  [self queryMinutesOfWorkoutsForStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseFourDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedFourDaysAgo" completion:^(double done, NSError *error)
                                                   {
                                                       //Call query to determine passive exercise minutes here;
                                                       [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseFourDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedFourDaysAgo" listRankingScoreParseKeyToSaveTo:@"listRankingScoreFourDaysAgo" numOfStepsParseKeyToPullFrom:@"NumberOfStepsFourDaysAgo"  completion:^(double done, NSError *error)
                                                        {
                                                            //Used to help NSDates at midnight
                                                            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                                            NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
                                                            
                                                            //today at midnight
                                                            NSDate *todayAtMidnight = [NSDate date];
                                                            todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
                                                            
                                                            
                                                            //get NSDate for five days ago at midnight
                                                            NSCalendar *cal = [NSCalendar currentCalendar];
                                                            NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
                                                            [components setHour:-120];
                                                            [components setMinute:0];
                                                            [components setSecond:0];
                                                            NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                            fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
                                                            
                                                            //yesterdayAtMidnight used to get todayPredicate
                                                            [components setHour:-96];
                                                            [components setMinute:0];
                                                            [components setSecond:0];
                                                            NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                            fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
                                                            
                                                            [self queryMinutesOfWorkoutsForStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseFiveDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedFiveDaysAgo" completion:^(double done, NSError *error)
                                                             {
                                                                 //Call query to determine passive exercise minutes here;
                                                                 [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseFiveDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedFiveDaysAgo" listRankingScoreParseKeyToSaveTo:@"listRankingScoreFiveDaysAgo" numOfStepsParseKeyToPullFrom:@"NumberOfStepsFiveDaysAgo" completion:^(double done, NSError *error)
                                                                  {
                                                                      //Used to help NSDates at midnight
                                                                      NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                                                      NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
                                                                      
                                                                      //today at midnight
                                                                      NSDate *todayAtMidnight = [NSDate date];
                                                                      todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
                                                                      
                                                                      //get NSDate for six days ago at midnight
                                                                      NSCalendar *cal = [NSCalendar currentCalendar];
                                                                      NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
                                                                      [components setHour:-144];
                                                                      [components setMinute:0];
                                                                      [components setSecond:0];
                                                                      NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                                      sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];
                                                                      
                                                                      //yesterdayAtMidnight used to get todayPredicate
                                                                      [components setHour:-120];
                                                                      [components setMinute:0];
                                                                      [components setSecond:0];
                                                                      NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
                                                                      fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];

                                                                      [self queryMinutesOfWorkoutsForStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseSixDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedSixDaysAgo" completion:^(double done, NSError *error)
                                                                       {
                                                                           //Call query to determine passive exercise minutes here;
                                                                           [self queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight datesWorkoutArray:lastSixDaysWorthOfWorkoutsArray viewController:viewController exerciseMinParseKeyToSaveTo:@"MinutesOfExerciseSixDaysAgo" calBurnParseKeyToSaveTo:@"CaloriesBurnedSixDaysAgo"  listRankingScoreParseKeyToSaveTo:@"listRankingScoreSixDaysAgo" numOfStepsParseKeyToPullFrom:@"NumberOfStepsSixDaysAgo"  completion:^(double done, NSError *error)
                                                                            {
                                                                                
                                                                                //Call method to calculate 'fitness_rating' here since all other health queries are now finished
                                                                                [self calculateRunningDailyAverageForChallenges: viewController completion:^(double done, NSError *error)
                                                                                 {

                                                                                 }];
                                                                            }];
                                                                       }];
                                                                  }];
                                                             }];
                                                        }];
                                                   }];
                                              }];
                                         }];
                                    }];
                               }];
                          }];
                     }];
                }];
            }];
        }
    }];
    
    [healthStore executeQuery:query];
}

-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

-(void)queryMinutesOfWorkoutsForStartDate:(NSDate*)startDateArg endDate:(NSDate*)endDateArg datesWorkoutArray:(NSMutableArray*)datesWorkoutArrayArg viewController:(MeViewController*)viewControllerArg exerciseMinParseKeyToSaveTo:(NSString*)exerciseMinParseKeyToSaveToArg calBurnParseKeyToSaveTo:(NSString*)calBurnParseKeyToSaveToArg completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryMinutesOfWorkoutsForStartDate called for %@", exerciseMinParseKeyToSaveToArg);

    //Save today's date to NSUserDefaults to mark when the query was last run
    NSLog (@"Date when health queries last run being saved to NSUserDefaults forKey: [self todaysDateFormatted] = %@", [viewControllerArg todaysDateFormatted]);
    [[NSUserDefaults standardUserDefaults] setObject:[viewControllerArg todaysDateFormatted] forKey:@"DateWhenHealthQueriesLastRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDateArg endDate:endDateArg options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:predicate, sourcesPredicate, wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //Reset this to 0. This value is carried over to use in the following passive query, but should be set at 0 otherwise
    todaysMinOfExercise = 0;
    todaysCaloriesBurned = 0;
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if (results == nil) {
            // Perform proper error handling here...
            NSLog(@"*** An error occurred while adding a sample to "
                  @"the workout: %@ ***",
                  error.localizedDescription);
            
            // abort();
        }
        else
        {
            //Add up the total minutes of exercise recorded from the days workouts
            for (HKWorkout *result in results)
            {
                NSLog (@"workout = %@", result);
                
                [self workoutCreditMultiplier:result completion:^(double done, double workoutCreditMultiplier, NSError *error)
                 {
                     NSLog (@"workoutCreditMultiplier in queryMinutesOfWorkoutsForStartDate = %f", workoutCreditMultiplier);
                     
                    todaysMinOfExercise += [result duration]/60;

                    todaysMinOfExercise = todaysMinOfExercise*workoutCreditMultiplier;
                     
                     todaysCaloriesBurned = todaysCaloriesBurned + ([[result totalEnergyBurned] doubleValueForUnit:[HKUnit calorieUnit]]/1000)*workoutCreditMultiplier;
                     
                     NSLog (@"todaysCaloriesBurned for workout = %f", todaysCaloriesBurned);
                     
                     //Call query to determine passive exercise minutes here
                     if ([PFUser currentUser])
                     {
                         [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                          {
                              NSLog (@"MinutesOfExerciseToday PFUser data save in background success = %i", succeeded);
                          }];
                     }
                     
                     //Save workout object to the days array
                     [datesWorkoutArrayArg addObject:result];
                }];
            }
            
            completionHandler(YES, nil);
        }
    }];
    
    [healthStore executeQuery:query];
}

-(void)queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate:(NSDate*)startDateArg endDate:(NSDate*)endDateArg datesWorkoutArray:(NSMutableArray*)datesWorkoutArrayArg viewController:(MeViewController*)viewControllerArg exerciseMinParseKeyToSaveTo:(NSString*)exerciseMinParseKeyToSaveToArg calBurnParseKeyToSaveTo:(NSString*)calBurnParseKeyToSaveToArg listRankingScoreParseKeyToSaveTo:(NSString*)listRankingScoreParseKeyToSaveToArg numOfStepsParseKeyToPullFrom:(NSString*)numOfStepsParseKeyToPullFromArg completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryMinutesOfPassiveExerciseToday called!");
    NSLog (@"queryMinutesOfPassiveExerciseAndTotalCalsBurnedForStartDate listRankingScoreParseKeyToSaveTo = %@", listRankingScoreParseKeyToSaveToArg);

    // Create a predicate to set start/end date bounds of the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDateArg endDate:endDateArg options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:predicate, sourcesPredicate, wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    // Run Query
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error)
                            {
                                NSInteger hourValueOfSampleBeingIterated = 0;
                                NSInteger minuteValueOfSampleBeingIterated = 0;
                                NSInteger minuteValueOfLastSampleBeingIterated = 0;
                                long int totalPassiveExerciseMinutes = 0;
                                float totalCalBurnedForCurrentMinute = 0;
                                long int lastMinuteExerciseMinAwarded = 0;
                                long int lastMinuteExerciseMinSubtracted = 0;
                                BOOL skipCurrentCalSample = NO;
                                long int minTimeStampToSkip = 1000; //set to 1000 since 1000 can't be a minute value
                                //Iterate through active calorie readings
                                //for (HKQuantitySample *sample in results)
                                
                                if ([results count] > 3)
                                {
                                    for (int i = 0; i < [results count] - 3; ++i)
                                    {
                                       // NSLog (@"active cal sample = %@", sample);
                                        
                                        if ([results count] > 0)
                                        {
                                            HKQuantitySample *sample = [results objectAtIndex: i];
                                            
                                            skipCurrentCalSample = NO;
                                            
                                            //IF the time stamp of this reading doesn't fall within the range of any workouts from today
                                            for (HKWorkout *workout in lastSixDaysWorthOfWorkoutsArray)
                                            {
                                                //Start time of date range for workout is the time stamp on the workout object
                                                NSDate *workoutStartTime = workout.startDate;
                                                //End time of the date range for workout is the startTime plus the duration
                                                NSDate *workoutEndTime = [workout.startDate dateByAddingTimeInterval:workout.duration];
                                                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                                //Determine minute value of sample being iterated over
                                                NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sample.startDate];
                                                hourValueOfSampleBeingIterated = [components hour]; //Minute value for sample's time stamp
                                                minuteValueOfSampleBeingIterated = [components minute]; //Minute value for sample's time stamp
                                                
                                                
                                                //Make sure current sample's startDate doesn't fall within a logged workout
                                                if ([self date:sample.startDate isBetweenDate:workoutStartTime andDate:workoutEndTime] == YES)
                                                {
                                                    skipCurrentCalSample = YES;
                                                }
                                            }
                                            
                                            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                            //Determine minute value of sample being iterated over
                                            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sample.startDate];
                                            hourValueOfSampleBeingIterated = [components hour]; //Minute value for sample's time stamp
                                            minuteValueOfSampleBeingIterated = [components minute]; //Minute value for sample's time stamp
                                            
                                            //If there are 3 or more active calorie readings for the minute value associated with the active calorie sample you're currently iterating over, log the minute a skip future active calorie samples with that minute value. If this sample is valid remember to reset that minute value to nil
                                            //Only check for new minTimeStampToSkip if min value of current calorie sample doesn't equal the previous minute time stamp to skip
                                            if (minuteValueOfSampleBeingIterated != minTimeStampToSkip)
                                            {
                                                //Start time of date range for active calorie sample after current one
                                                HKQuantitySample *sample2 = [results objectAtIndex: i + 1];
                                                NSCalendar *calendar2 = [NSCalendar autoupdatingCurrentCalendar];
                                                NSDateComponents *components2 = [calendar2 components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sample2.startDate];
                                                long int minuteValueOfSample2 = [components2 minute]; //Minute value for sample2's time stamp
                                                
                                                if (minuteValueOfSampleBeingIterated == minuteValueOfSample2)
                                                {
                                                    //Start time of date range for two active calorie samples after current one
                                                    HKQuantitySample *sample3 = [results objectAtIndex: i + 2];
                                                    NSCalendar *calendar3 = [NSCalendar autoupdatingCurrentCalendar];
                                                    NSDateComponents *components3 = [calendar3 components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sample3.startDate];
                                                    long int minuteValueOfSample3 = [components3 minute]; //Minute value for sample2's time stamp
                                                    
                                                    if (minuteValueOfSample3 == minuteValueOfSample2)
                                                    {
                                                        minTimeStampToSkip = minuteValueOfSample3;
                                                    }
                                                    else
                                                    {
                                                        minTimeStampToSkip = 1000;
                                                    }
                                                }
                                                else
                                                {
                                                    minTimeStampToSkip = 1000;
                                                }
                                            }
                                            
                                            if (skipCurrentCalSample == NO)
                                            {
                                                //Add the sample's calorie reading to todaysCaloriesBurned
                                                todaysCaloriesBurned = todaysCaloriesBurned + [[sample quantity] doubleValueForUnit:[HKUnit calorieUnit]]/1000;
                                            }
                                            
                                            if (skipCurrentCalSample == NO && minuteValueOfSampleBeingIterated != minTimeStampToSkip)
                                            {
                                                if (minuteValueOfSampleBeingIterated != minuteValueOfLastSampleBeingIterated)   //IF the current minute's sample is different than the minute for thre previously iterated sample...
                                                {
                                                    totalCalBurnedForCurrentMinute = 0; //... reset the totalCalBurnedForCurrentMinute
                                                }
                                                //...add the kcal of the sample to 'totalCalThisMinute'
                                                totalCalBurnedForCurrentMinute = totalCalBurnedForCurrentMinute + [[sample quantity] doubleValueForUnit:[HKUnit calorieUnit]]/1000;
                                                
                                                double calBurnedPerMinuteRewardThreshold = 0;
                                                if ([PFUser currentUser])
                                                {
                                                    double moveGoal = [[PFUser currentUser][@"moveGoal"] doubleValue];
                                                    //NSLog (@"moveGoal in HealthMethods = %f", moveGoal);
                                                    calBurnedPerMinuteRewardThreshold = 2.15*moveGoal/590.8;
                                                }
                                                
                                                //If 'totalCalBurnedForCurrentMinute' is above 2kcal then add a minute to var 'totalPassiveExerciseMinutes'
                                                if (totalCalBurnedForCurrentMinute >= calBurnedPerMinuteRewardThreshold && minuteValueOfSampleBeingIterated != lastMinuteExerciseMinAwarded)
                                                {
                                                 //   NSLog (@"adding totalPassiveExerciseMinutes, sample = %@", sample);
                                                    totalPassiveExerciseMinutes = totalPassiveExerciseMinutes + 1;
                                                    lastMinuteExerciseMinAwarded = minuteValueOfSampleBeingIterated;
                                                }
                                                //Only subtract an exericse min if it hasn't already been done for the current minute and totalCalBurnedForCurrentMinute is < calBurnedPerMinuteRewardThreshold
                                                if (totalCalBurnedForCurrentMinute < calBurnedPerMinuteRewardThreshold && lastMinuteExerciseMinAwarded == minuteValueOfSampleBeingIterated + 1 && lastMinuteExerciseMinSubtracted != minuteValueOfSampleBeingIterated)
                                                {
                                                    totalPassiveExerciseMinutes = totalPassiveExerciseMinutes - 1;
                                                }
                                                
                                                //Determine value of 'minuteValueOfLastSampleBeingIterated'
                                                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                                                NSDateComponents *lastSampleComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sample.startDate];
                                                minuteValueOfLastSampleBeingIterated = [lastSampleComponents minute];
                                            }
                                        }
                                    }
                                }
                                
                                todaysMinOfExercise = todaysMinOfExercise + totalPassiveExerciseMinutes;
                                //If there are no exercise minutes, -1 may be returned. Set it to 0
                                if (todaysMinOfExercise < 0)
                                    todaysMinOfExercise = 0;
                                
                                NSLog (@"%@ totalPassiveExerciseMinutes = %ld", exerciseMinParseKeyToSaveToArg, totalPassiveExerciseMinutes);
                                NSLog (@"%@ todaysMinOfExercise = %ld", exerciseMinParseKeyToSaveToArg, todaysMinOfExercise);
                                NSLog (@"%@ todaysCaloriesBurned = %f", calBurnParseKeyToSaveToArg, todaysCaloriesBurned);
                                NSNumber *totalMinutesOfRunningTodayNSNumber = [NSNumber numberWithInteger:todaysMinOfExercise];
                                NSNumber *totalCalBurnedTodayNSNumber = [NSNumber numberWithInteger:todaysCaloriesBurned];

                                //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                if ([meViewSubClass isFirstTimeHealthQueriesBeingRunToday] && [PFUser currentUser])
                                {
                                    //Write to Parse
                                    [[PFUser currentUser] setObject:totalMinutesOfRunningTodayNSNumber forKey:exerciseMinParseKeyToSaveToArg];
                                    [[PFUser currentUser] setObject:totalCalBurnedTodayNSNumber forKey:calBurnParseKeyToSaveToArg];
                                    
                                    if ([PFUser currentUser])
                                    {
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                         {
                                             // some logging code here
                                             NSLog (@"Minutes of Exercise PFUser data save in background success = %i", succeeded);
                                             
                                             [self calculateListRankingScore:numOfStepsParseKeyToPullFromArg exerciseMinsParseKey:exerciseMinParseKeyToSaveToArg calsBurnedParseKey:calBurnParseKeyToSaveToArg listRankingScoreDay:listRankingScoreParseKeyToSaveToArg];
                                         }];
                                    }
                                }
                                //Else if it's NOT the first time queries are being run today
                                else
                                {
                                    //Write to Parse
                                    if ([PFUser currentUser])
                                    {
                                        [[PFUser currentUser] setObject:totalMinutesOfRunningTodayNSNumber forKey:exerciseMinParseKeyToSaveToArg];
                                    }

                                    //Write to Parse
                                    if ([PFUser currentUser])
                                    {
                                        [[PFUser currentUser] setObject:totalCalBurnedTodayNSNumber forKey:calBurnParseKeyToSaveToArg];
                                    }
                                }
                                
                                //Write to NSUserDefaults. We want it written to NSUserDefaults every time so leave it out of the previous conditional tha writes only if it's the same day
                                [[NSUserDefaults standardUserDefaults] setObject:totalMinutesOfRunningTodayNSNumber forKey:exerciseMinParseKeyToSaveToArg];
                                [[NSUserDefaults standardUserDefaults] setObject:totalCalBurnedTodayNSNumber forKey:calBurnParseKeyToSaveToArg];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                [self calculateListRankingScore:numOfStepsParseKeyToPullFromArg exerciseMinsParseKey:exerciseMinParseKeyToSaveToArg calsBurnedParseKey:calBurnParseKeyToSaveToArg listRankingScoreDay:listRankingScoreParseKeyToSaveToArg];
                                
                                if ([PFUser currentUser])
                                {
                                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                     {
                                         // some logging code here
                                         NSLog (@"Minutes of Exercise PFUser data save in background success = %i", succeeded);
                                     }];
                                }
                               
                                completionHandler(YES, nil);
                            }];
    
    [healthStore executeQuery:query];
}

//Query for steps taken for today which starts a chain event which ends up logging the past 7 days worth of steps to Parse
-(void)queryTotalStepsForToday: (MeViewController*)viewController unit:(HKUnit *)unit {
    
    NSLog (@"queryTotalStepsForToday called!");
    
    //Zero out all health stats in parse first on the app's very first run in order to allow for stat shifting the next morning
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zeroOutAllHealthStatsInParse"] != YES)
    {
        NSLog (@"setting zeroOutAllHealthStatsInParse to YES for running the app for the first time ever");
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zeroOutAllHealthStatsInParse"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self zeroOutAllHealthStatsInParse];
    }
    
    //Upload user's height to Parse
    [self saveUsersHeightToParse];
    
    //Upload user's weight to Parse
    [self saveUsersWeightToParse];
    
    //calling usersAge will upload users age to Parse
    //MeViewController *subclass = [[MeViewController alloc] init];
    //[subclass usersAge];
    
    [self fetchSources:^(double done, NSError *error)
     {
         NSLog (@"dataSources count = %lu", (unsigned long)[dataSources count]);
         //Create NSSet with the two sources
         sourcesSet = [[NSSet alloc] init];
         sourcesSet = [NSSet setWithArray:dataSources];
         NSLog (@"sourcesSet count = %lu", (unsigned long)[sourcesSet count]);
    
         // Set your start and end date for your query of interest
         NSDate *now = [NSDate date];
         
         NSDate *todayAtMidnight = [NSDate date];
         NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
         NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
         todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
         
         // Use the sample type for step count
         HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
         
         // Create a predicate to set start/end date bounds of the query
         NSPredicate *todayPredicate = [HKQuery predicateForSamplesWithStartDate:todayAtMidnight endDate:now options:HKQueryOptionStrictStartDate];
         //Create compound predicate
         NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
         NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
         NSArray *predicatesArray = [NSArray arrayWithObjects:todayPredicate, sourcesPredicate, wasUserEnteredPredicate, nil];
         NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
         
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"StepsQueryCurrentlyRunning"] == NO)
        {            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"StepsQueryCurrentlyRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;

            HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                               quantitySamplePredicate:compoundPredicate
                                                                               options:sumOptions
                                                                     completionHandler:^(HKStatisticsQuery *query,
                                                                                         HKStatistics *result,
                                                                                         NSError *error)
                                        {
                                            HKQuantity *sum = [result sumQuantity];
                                            
                                            int numOfStepsToday = [sum doubleValueForUnit:[HKUnit countUnit]];
                                            NSLog (@"numOfStepsToday iVars = %i", numOfStepsToday);
                                            
                                            NSNumber *numOfStepsTodayNSNumber = [NSNumber numberWithInt:numOfStepsToday];
                                            
                                            //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                            MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                            if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                            {
                                                //Write to Parse
                                                [[PFUser currentUser] setObject:numOfStepsTodayNSNumber forKey:@"NumberOfStepsToday"];
                                                //Write to NSUserDefaults
                                                [[NSUserDefaults standardUserDefaults] setObject:numOfStepsTodayNSNumber forKey:@"numOfStepsTodayNSNumber"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                            //Else if it's NOT the first time queries are being run today
                                            else
                                            {
                                                //Make sure the queried value is LARGER than 0
                                                if ([numOfStepsTodayNSNumber integerValue] > 0)
                                                {
                                                    //Write to Parse
                                                    if ([PFUser currentUser])
                                                        [[PFUser currentUser] setObject:numOfStepsTodayNSNumber forKey:@"NumberOfStepsToday"];
                                                }
                                            }
                                            
                                            if ([PFUser currentUser])
                                            {
                                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    // some logging code here
                                                    NSLog (@"PFUser data save in background success = %i", succeeded);
                                                    
                                                    //Kick off the steps query for yesterday
                                                    [self queryTotalStepsForYesterday: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                                     {
                                                         
                                                     }];
                                                }];
                                            }
                                        }];
            // Execute the query
            [healthStore executeQuery:query];
        }
     }];
}

//Query for steps taken yesterday
-(void)queryTotalStepsForYesterday: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForYesterday");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for yesterday at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *yesterdayPredicate = [HKQuery predicateForSamplesWithStartDate:yesterdayAtMidnight endDate:todayAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:yesterdayPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //Check if calculation already exists in Parse
    /*
    PFQuery *querySteps = [PFUser query];
    [querySteps whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    //[querySteps whereKeyExists:@"]
    [querySteps getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (!error)
        {
            NSLog (@"Steps already calculated!");
            NSLog (@"steps object = %@", object[@"NumberOfStepsToday"]);
        }
    }];
     */
    //Set this to always run for the sake of the 'HomeView' always showing yesterday's health stats
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 0)
    {
        //See if data already exists
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                           quantitySamplePredicate:compoundPredicate
                                                                           options:sumOptions
                                                                 completionHandler:^(HKStatisticsQuery *query,
                                                                                     HKStatistics *result,
                                                                                     NSError *error)
                                    {
                                        HKQuantity *sum = [result sumQuantity];
                                        
                                        int numOfStepsYesterday = [sum doubleValueForUnit:[HKUnit countUnit]];
                                        NSLog(@"Total Steps Yesterday: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                        
                                        NSNumber *numOfStepsYesterdayNSNumber = [NSNumber numberWithInt:numOfStepsYesterday];
                                        
                                        //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                        MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                        if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                        {
                                            //Write to Parse
                                            [[PFUser currentUser] setObject:numOfStepsYesterdayNSNumber forKey:@"NumberOfStepsYesterday"];
                                            //Write to NSUserDefaults
                                            [[NSUserDefaults standardUserDefaults] setObject:numOfStepsYesterdayNSNumber forKey:@"numOfStepsYesterdayNSNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                        //Else if it's NOT the first time queries are being run today
                                        else
                                        {
                                            //Make sure the queried value is LARGER than 0
                                            if ([numOfStepsYesterdayNSNumber integerValue] > 0)
                                            {
                                                //Write to Parse
                                                if ([PFUser currentUser])
                                                    [[PFUser currentUser] setObject:numOfStepsYesterdayNSNumber forKey:@"NumberOfStepsYesterday"];
                                            }
                                        }
                                        
                                        if ([PFUser currentUser])
                                        {
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                // some logging code here
                                                NSLog (@"PFUser data save in background success = %i", succeeded);
                                                
                                                //Kick off the steps query for yesterday
                                                [self queryTotalStepsForTwoDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                                 {
                                                     
                                                 }];
                                            }];
                                        }
                                    }];
        
        // Execute the query
        [healthStore executeQuery:query];
    }
    //NumberOfStepsYesterday data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsYesterday already exist, just run queryTotalStepsForTwoDaysAgo");
        //Kick off the steps query for two days ago
        [self queryTotalStepsForTwoDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query for steps taken two days ago
-(void)queryTotalStepsForTwoDaysAgo: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForTwoDaysAgo called!");
    
    // Set your start and end date for your query of interest
    
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
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *twoDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:twoDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 2)
    {
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:compoundPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsTwoDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Two Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsTwoDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsTwoDaysAgo];
                                    
                                    //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                    MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                    if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                    {
                                        //Write to Parse
                                        [[PFUser currentUser] setObject:numOfStepsTwoDaysAgoNSNumber forKey:@"NumberOfStepsTwoDaysAgo"];
                                        //Write to NSUserDefaults
                                        [[NSUserDefaults standardUserDefaults] setObject:numOfStepsTwoDaysAgoNSNumber forKey:@"numOfStepsTwoDaysAgoNSNumber"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                    }
                                    //Else if it's NOT the first time queries are being run today
                                    else
                                    {
                                        //Make sure the queried value is LARGER than 0
                                        if ([numOfStepsTwoDaysAgoNSNumber integerValue] > 0)
                                        {
                                            //Write to Parse
                                            if ([PFUser currentUser])
                                                [[PFUser currentUser] setObject:numOfStepsTwoDaysAgoNSNumber forKey:@"NumberOfStepsTwoDaysAgo"];
                                        }
                                    }
                                    
                                    if ([PFUser currentUser])
                                    {
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            
                                            //Kick off the steps query for yesterday
                                            [self queryTotalStepsForThreeDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                             {
                                                 
                                             }];
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
    }
    //NumberOfStepsTwoDaysAgo data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsTwoDaysAgo already exist, just run queryTotalStepsForThreeDaysAgo");
        //Kick off the steps query for three days ago
        [self queryTotalStepsForThreeDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query for steps taken three days ago
-(void)queryTotalStepsForThreeDaysAgo: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForThreeDaysAgo called!");
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for three days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-48];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *threeDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:threeDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 3)
    {
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                           quantitySamplePredicate:compoundPredicate
                                                                           options:sumOptions
                                                                 completionHandler:^(HKStatisticsQuery *query,
                                                                                     HKStatistics *result,
                                                                                     NSError *error)
                                    {
                                        HKQuantity *sum = [result sumQuantity];
                                        
                                        int numOfStepsThreeDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                        NSLog(@"Total Steps Three Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                        
                                        NSNumber *numOfStepsThreeDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsThreeDaysAgo];
                                        
                                        //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                        MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                        if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                        {
                                            //Write to Parse
                                            [[PFUser currentUser] setObject:numOfStepsThreeDaysAgoNSNumber forKey:@"NumberOfStepsThreeDaysAgo"];
                                            //Write to NSUserDefaults
                                            [[NSUserDefaults standardUserDefaults] setObject:numOfStepsThreeDaysAgoNSNumber forKey:@"numOfStepsThreeDaysAgoNSNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                        //Else if it's NOT the first time queries are being run today
                                        else
                                        {
                                            //Make sure the queried value is LARGER than 0
                                            if ([numOfStepsThreeDaysAgoNSNumber integerValue] > 0)
                                            {
                                                //Write to Parse
                                                if ([PFUser currentUser])
                                                    [[PFUser currentUser] setObject:numOfStepsThreeDaysAgoNSNumber forKey:@"NumberOfStepsThreeDaysAgo"];
                                            }
                                        }

                                        if ([PFUser currentUser])
                                        {
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                // some logging code here
                                                NSLog (@"PFUser data save in background success = %i", succeeded);
                                                
                                                //Kick off the steps query for yesterday
                                                [self queryTotalStepsForFourDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                                 {
                                                     
                                                 }];
                                            }];
                                        }
                                    }];
        
        // Execute the query
        [healthStore executeQuery:query];
    }
    //NumberOfStepsThreeDaysAgo data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsThreeDaysAgo already exist, just run queryTotalStepsForFourDaysAgo");
        //Kick off the steps query for four days ago
        [self queryTotalStepsForFourDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query for steps taken four days ago
-(void)queryTotalStepsForFourDaysAgo: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForFourDaysAgo called!");
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for four days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fourDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fourDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 4)
    {
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                           quantitySamplePredicate:compoundPredicate
                                                                           options:sumOptions
                                                                 completionHandler:^(HKStatisticsQuery *query,
                                                                                     HKStatistics *result,
                                                                                     NSError *error)
                                    {
                                        HKQuantity *sum = [result sumQuantity];
                                        
                                        int numOfStepsFourDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                        NSLog(@"Total Steps Four Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                        
                                        NSNumber *numOfStepsFourDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsFourDaysAgo];
                                        
                                        //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                        MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                        if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                        {
                                            //Write to Parse
                                            [[PFUser currentUser] setObject:numOfStepsFourDaysAgoNSNumber forKey:@"NumberOfStepsFourDaysAgo"];
                                            //Write to NSUserDefaults
                                            [[NSUserDefaults standardUserDefaults] setObject:numOfStepsFourDaysAgoNSNumber forKey:@"numOfStepsFourDaysAgoNSNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                        //Else if it's NOT the first time queries are being run today
                                        else
                                        {
                                            //Make sure the queried value is LARGER than 0
                                            if ([numOfStepsFourDaysAgoNSNumber integerValue] > 0)
                                            {
                                                //Write to Parse
                                                if ([PFUser currentUser])
                                                    [[PFUser currentUser] setObject:numOfStepsFourDaysAgoNSNumber forKey:@"NumberOfStepsFourDaysAgo"];
                                            }
                                        }
                                        
                                        if ([PFUser currentUser])
                                        {
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                // some logging code here
                                                NSLog (@"PFUser data save in background success = %i", succeeded);
                                                
                                                //Kick off the steps query for yesterday
                                                [self queryTotalStepsForFiveDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                                 {
                                                     
                                                 }];
                                            }];
                                        }
                                    }];
        
        // Execute the query
        [healthStore executeQuery:query];
    }
    //NumberOfStepsFourDaysAgo data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsFourDaysAgo already exist, just run queryTotalStepsForFiveDaysAgo");
        //Kick off the steps query for five days ago
        [self queryTotalStepsForFiveDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query for steps taken five days ago
-(void)queryTotalStepsForFiveDaysAgo: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForFiveDaysAgo called!");
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for five days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fiveDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fiveDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 5)
    {
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                           quantitySamplePredicate:compoundPredicate
                                                                           options:sumOptions
                                                                 completionHandler:^(HKStatisticsQuery *query,
                                                                                     HKStatistics *result,
                                                                                     NSError *error)
                                    {
                                        HKQuantity *sum = [result sumQuantity];
                                        
                                        int numOfStepsFiveDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                        NSLog(@"Total Steps Five Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                        
                                        NSNumber *numOfStepsFiveDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsFiveDaysAgo];
                                        
                                        //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                        MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                        if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                        {
                                            //Write to Parse
                                            [[PFUser currentUser] setObject:numOfStepsFiveDaysAgoNSNumber forKey:@"NumberOfStepsFiveDaysAgo"];
                                            //Write to NSUserDefaults
                                            [[NSUserDefaults standardUserDefaults] setObject:numOfStepsFiveDaysAgoNSNumber forKey:@"numOfStepsFiveDaysAgoNSNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                        //Else if it's NOT the first time queries are being run today
                                        else
                                        {
                                            //Make sure the queried value is LARGER than 0
                                            if ([numOfStepsFiveDaysAgoNSNumber integerValue] > 0)
                                            {
                                                //Write to Parse
                                                if ([PFUser currentUser])
                                                    [[PFUser currentUser] setObject:numOfStepsFiveDaysAgoNSNumber forKey:@"NumberOfStepsFiveDaysAgo"];
                                            }
                                        }
                                        
                                        if ([PFUser currentUser])
                                        {
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                // some logging code here
                                                NSLog (@"PFUser data save in background success = %i", succeeded);
                                                
                                                //Kick off the steps query for yesterday
                                                [self queryTotalStepsForSixDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
                                                 {
                                                     
                                                 }];
                                            }];
                                        }
                                    }];
        
        // Execute the query
        [healthStore executeQuery:query];
    }
    //NumberOfStepsFiveDaysAgo data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsFiveDaysAgo already exist, just run queryTotalStepsForSixDaysAgo");
        //Kick off the steps query for six days ago
        [self queryTotalStepsForSixDaysAgo: viewController unit: [HKUnit countUnit] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query for steps taken six days ago
-(void)queryTotalStepsForSixDaysAgo: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryTotalStepsForSixDaysAgo called!");
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for six days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-144];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *sixDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:sixDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 6)
    {
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                           quantitySamplePredicate:compoundPredicate
                                                                           options:sumOptions
                                                                 completionHandler:^(HKStatisticsQuery *query,
                                                                                     HKStatistics *result,
                                                                                     NSError *error)
                                    {
                                        HKQuantity *sum = [result sumQuantity];
                                        
                                        int numOfStepsSixDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                        NSLog(@"Total Steps Six Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                        
                                        NSNumber *numOfStepsSixDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsSixDaysAgo];
                                        
                                        //If it's the first time being run today, then write the queried data to Parse.  Otherwise, make sure that the value of the queried data is LARGER than whats stored in NSUserDefaults before you write it to Parse
                                        MeViewController *meViewSubClass = [[MeViewController alloc] init];
                                        if ([PFUser currentUser] && [meViewSubClass isFirstTimeHealthQueriesBeingRunToday])
                                        {
                                            //Write to Parse
                                            [[PFUser currentUser] setObject:numOfStepsSixDaysAgoNSNumber forKey:@"NumberOfStepsSixDaysAgo"];
                                            //Write to NSUserDefaults
                                            [[NSUserDefaults standardUserDefaults] setObject:numOfStepsSixDaysAgoNSNumber forKey:@"numOfStepsSixDaysAgoNSNumber"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                        //Else if it's NOT the first time queries are being run today
                                        else
                                        {
                                            //Make sure the queried value is LARGER than 0
                                            if ([numOfStepsSixDaysAgoNSNumber integerValue] > 0)
                                            {
                                                //Write to Parse
                                                if ([PFUser currentUser])
                                                    [[PFUser currentUser] setObject:numOfStepsSixDaysAgoNSNumber forKey:@"NumberOfStepsSixDaysAgo"];
                                            }
                                        }
                                        
                                        if ([PFUser currentUser])
                                        {
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                // some logging code here
                                                NSLog (@"PFUser data save in background success = %i", succeeded);
                                                
                                                //query calories burned and exercise minutes for the last 6 days
                                                [self queryWorkoutsForTheLastSixDays:viewController completion:^(double done, NSError *error)
                                                {
                                                    
                                                }];
                                                
                                            }];
                                        }
                                    }];
        
        // Execute the query
        [healthStore executeQuery:query];
    }
    //NumberOfStepsSixDaysAgo data already exists in Parse just run the next query
    else
    {
        NSLog (@"NumberOfStepsSixDaysAgo already exist, just run queryTotalCaloriesBurnedForToday");
        
        //query calories burned and exercise minutes for the last 6 days
        [self queryWorkoutsForTheLastSixDays:viewController completion:^(double done, NSError *error)
         {
             
         }];
    }
}
/* Method Unused
-(void) queryAllWorkoutsForToday:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllWorkoutsForToday run!");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WorkoutsQueryCurrentlyRunning"] == NO)
    {
        NSLog (@"queryTotalStepsForToday");
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WorkoutsQueryCurrentlyRunning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        // Set your start and end date for your query of interest
        NSDate *now = [NSDate date];
        
        NSDate *todayAtMidnight = [NSDate date];
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
        todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
        
        // Use the sample type for calories burned type
        // Create a predicate to set start/end date bounds of the query
        NSPredicate *todayPredicate = [HKQuery predicateForSamplesWithStartDate:todayAtMidnight endDate:now options:HKQueryOptionStrictStartDate];
        
        
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:todayPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            
            if (results == nil)
            {
                 // Perform proper error handling here...
                 NSLog(@"*** An error occurred while adding a sample to "
                       @"the workout: %@ ***",
                       error.localizedDescription);             
             }
            else
            {
                int caloriesBurnedFromWorkouts = 0;
                
                for (HKWorkout *workout in results)
                {
                    NSLog (@"workout = %@", workout.totalEnergyBurned);
                    
                    int workoutCaloriesBurned = [workout.totalEnergyBurned doubleValueForUnit:[HKUnit calorieUnit]]/1000;

                    caloriesBurnedFromWorkouts = caloriesBurnedFromWorkouts + workoutCaloriesBurned;
                }
                
                NSLog (@"caloriesBurnedFromWorkouts = %i", caloriesBurnedFromWorkouts);
            }
         }];
        
        [healthStore executeQuery:query];
    }
}
*/
//Method - Calculates difference between two NSDates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(NSString*) convertToLocalTime: (NSDate*)dateArg
{
    NSDateFormatter *localFormat = [[NSDateFormatter alloc] init];
    [localFormat setTimeStyle:NSDateFormatterLongStyle];
    [localFormat setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
    NSString *localTime = [localFormat stringFromDate:dateArg];
    
    return localTime;
}

//Query yesterday's step samples
-(void)queryAllOfYesterdaysStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfYesterdaysStepSamples running!");
    
    // Set your start and end date for your query of interest
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for yesterday at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *yesterdayPredicate = [HKQuery predicateForSamplesWithStartDate:yesterdayAtMidnight endDate:todayAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:yesterdayPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for yesterday. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [yesterdaysStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [yesterdaysStepSamplesArray addObject:sample];
                }
                
                NSLog (@"yesterdaysStepSamplesArray count = %lu", (unsigned long)[yesterdaysStepSamplesArray count]);
                
                [self calculateYesterdaysRestingHR:viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query step samples from two days ago
-(void)queryAllOfTwoDaysAgoStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfTwoDaysAgoStepSamples running!");
    
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
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *twoDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight options:HKQueryOptionStrictStartDate];

    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:twoDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for two days ago. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [twoDaysAgoStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [twoDaysAgoStepSamplesArray addObject:sample];
                }
                
                //NSLog (@"twoDaysAgoStepSamplesArray count = %lu", (unsigned long)[twoDaysAgoStepSamplesArray count]);
                for (HKSample *sample in twoDaysAgoStepSamplesArray)
                {
                    NSLog (@"step sample = %@", [self convertToLocalTime:[sample startDate]]);
                }
                NSLog (@"twoDaysAgoStepSamplesArray count = %lu", (unsigned long)[twoDaysAgoStepSamplesArray count]);
                
                //Call calculateTwoDaysAgoRestingHR HERE due to async structure
                [self calculateTwoDaysAgoRestingHR: viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query step samples from three days ago
-(void)queryAllOfThreeDaysAgoStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfThreeDaysAgoStepSamples running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for three days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    //three days ago at midnight used to get todayPredicate
    [components setHour:-48];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *threeDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:threeDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for three days ago. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [threeDaysAgoStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [threeDaysAgoStepSamplesArray addObject:sample];
                }
                
                //NSLog (@"threeDaysAgoStepSamplesArray count = %lu", (unsigned long)[threeDaysAgoStepSamplesArray count]);
                for (HKSample *sample in threeDaysAgoStepSamplesArray)
                {
                    NSLog (@"step sample = %@", [self convertToLocalTime:[sample startDate]]);
                }
                NSLog (@"threeDaysAgoStepSamplesArray count = %lu", (unsigned long)[threeDaysAgoStepSamplesArray count]);
                
                //Call calculateThreeDaysAgoRestingHR HERE due to async structure
                [self calculateThreeDaysAgoRestingHR: viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query step samples from four days ago
-(void)queryAllOfFourDaysAgoStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfFourDaysAgoStepSamples running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for four days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    //four days ago at midnight used to get todayPredicate
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fourDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fourDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for four days ago. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [fourDaysAgoStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [fourDaysAgoStepSamplesArray addObject:sample];
                }
                
                //NSLog (@"fourDaysAgoStepSamplesArray count = %lu", (unsigned long)[fourDaysAgoStepSamplesArray count]);
                for (HKSample *sample in fourDaysAgoStepSamplesArray)
                {
                    NSLog (@"step sample = %@", [self convertToLocalTime:[sample startDate]]);
                }
                NSLog (@"fourDaysAgoStepSamplesArray count = %lu", (unsigned long)[fourDaysAgoStepSamplesArray count]);
                
                //Call calculateFourDaysAgoRestingHR HERE due to async structure
                [self calculateFourDaysAgoRestingHR: viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query step samples from five days ago
-(void)queryAllOfFiveDaysAgoStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfFiveDaysAgoStepSamples running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for five days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    //four days ago at midnight used to get todayPredicate
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fiveDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fiveDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for five days ago. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [fiveDaysAgoStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [fiveDaysAgoStepSamplesArray addObject:sample];
                }
                
                //NSLog (@"fiveDaysAgoStepSamplesArray count = %lu", (unsigned long)[fiveDaysAgoStepSamplesArray count]);
                for (HKSample *sample in fiveDaysAgoStepSamplesArray)
                {
                    NSLog (@"step sample = %@", [self convertToLocalTime:[sample startDate]]);
                }
                NSLog (@"fiveDaysAgoStepSamplesArray count = %lu", (unsigned long)[fiveDaysAgoStepSamplesArray count]);
                
                //Call calculateFiveDaysAgoRestingHR HERE due to async structure
                [self calculateFiveDaysAgoRestingHR: viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query step samples from five days ago
-(void)queryAllOfSixDaysAgoStepSamples: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfSixDaysAgoStepSamples running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for six days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-144];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];
    
    //five days ago at midnight used to get todayPredicate
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *sixDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:sixDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results)
        {
            NSLog(@"An error occured fetching the user's step samples for six days ago. In your app, try to handle this gracefully. The error was: %@.", error);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sixDaysAgoStepSamplesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [sixDaysAgoStepSamplesArray addObject:sample];
                }
                
                //NSLog (@"sixDaysAgoStepSamplesArray count = %lu", (unsigned long)[sixDaysAgoStepSamplesArray count]);
                for (HKSample *sample in sixDaysAgoStepSamplesArray)
                {
                    NSLog (@"step sample = %@", [self convertToLocalTime:[sample startDate]]);
                }
                NSLog (@"sixDaysAgoStepSamplesArray count = %lu", (unsigned long)[sixDaysAgoStepSamplesArray count]);
                
                //Call calculateSixDaysAgoRestingHR HERE due to async structure
                [self calculateSixDaysAgoRestingHR: viewController];
            });
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query all of yesterday's HR's
- (void)queryAllOfTodaysHeartRates:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfTodaysHeartRates running!");
    
    // Set your start and end date for your query of interest
    NSDate *now = [NSDate date];
    
    NSDate *todayAtMidnight = [NSDate date];;
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *todayPredicate = [HKQuery predicateForSamplesWithStartDate:todayAtMidnight endDate:now options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:todayPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        NSLog (@"Todays HR Query running!");
        if (!results)
        {
            NSLog(@"An error occured fetching the user's heart rate samples for today. In your app, try to handle this gracefully. The error was: %@.", error);
        }

        [todaysHeartRatesArray removeAllObjects];
        
        for (HKQuantitySample *sample in results)
        {
            [todaysHeartRatesArray addObject:sample];
        }
        
        //Save numOfTodaysHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:[todaysHeartRatesArray count] forKey:@"numOfTodaysHeartRateSamplesInt"];
        [defaults synchronize];
        
        completionHandler(YES, nil);
    }];
    
    [healthStore executeQuery:query];
}

//This method should ONLY be run the very first time queryAllOfYesterdaysHeartRates is called, EVER
-(void)zeroOutAllHealthStatsInParse
{
    NSLog (@"zeroOutAllHealthStatsInParse called!");
    
    //Zero out RHR values in Parse
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_6_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_5_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_4_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_3_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_2_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"RHR_1_day_ago"];

    
    //Zero out HRR values in Parse
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_6_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_5_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_4_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_3_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_2_days_ago"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"HRR_1_day_ago"];
    
    //Zero out steps
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsToday"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsYesterday"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsTwoDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsThreeDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsFourDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsFiveDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"NumberOfStepsSixDaysAgo"];

    //Zero out the 6 days of min-of-exercise values in Parse
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseToday"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseOneDayAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseTwoDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseThreeDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseFourDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseFiveDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"MinutesOfExerciseSixDaysAgo"];

    //Zero out the 6 days of calories-burned values in Parse
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedToday"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedOneDayAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedTwoDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedThreeDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedFourDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedFiveDaysAgo"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"CaloriesBurnedSixDaysAgo"];
    
    //Zero out the 6 day average number of steps, calroies burned, and minutes of exercise in Parse
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"sevenDayAvgNumOfSteps"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"sevenDayAvgNumOfMinOfExercise"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"sevenDayAvgNumOfCaloriesBurned"];

    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"Zero out RHR and HRR values in Parse in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
}

//Query all of yesterday's HR's
- (void)queryAllOfYesterdaysHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfYesterdaysHeartRates running!");
    
    if (allowHRRelatedQueries == YES)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HeartRatesQueryCurrentlyRunning"] == NO)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HeartRatesQueryCurrentlyRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zeroOutAllHealthStatsInParse"] != YES)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zeroOutAllHealthStatsInParse"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self zeroOutAllHealthStatsInParse];
            }    
            
            // Set your start and end date for your query of interest
            //Used to help NSDates at midnight
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
            
            //today at midnight
            NSDate *todayAtMidnight = [NSDate date];
            todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
            
            //get NSDate for yesterday at midnight
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
            [components setHour:-24];
            [components setMinute:0];
            [components setSecond:0];
            NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
            yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
            
            // Create a predicate to set start/end date bounds of the query
            NSPredicate *yesterdayPredicate = [HKQuery predicateForSamplesWithStartDate:yesterdayAtMidnight endDate:todayAtMidnight options:HKQueryOptionStrictStartDate];
            
            //Create compound predicate
            NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
            NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
            NSArray *predicatesArray = [NSArray arrayWithObjects:yesterdayPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
            NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
            
            HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            if ([PFUser currentUser][@"RHR_1_day_ago"])
                NSLog (@"RHR = %@", [[PFUser currentUser] objectForKey:@"RHR_1_day_ago"]);
            if ([PFUser currentUser][@"HRR_1_day_ago"])
                NSLog (@"HRR = %@", [[PFUser currentUser] objectForKey:@"HRR_1_day_ago"]);
            
            //Set this to always run for the sake of the 'HomeView' always showing yesterday's health stats
            if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 0)
            {
                HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                    if (!results)
                    {
                        NSLog(@"An error occured fetching the user's heart rate samples for yesterday. In your app, try to handle this gracefully. The error was: %@.", error);
                    }
                    else
                    {
                        [yesterdaysHeartRatesArray removeAllObjects];
                        
                        for (HKQuantitySample *sample in results)
                        {
                            [yesterdaysHeartRatesArray addObject:sample];
                        }
                        
                        NSLog (@"yesterdaysHeartRatesArray count = %lu", (unsigned long)[yesterdaysHeartRatesArray count]);

                        //Save numOfYesterdaysHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setInteger:[yesterdaysHeartRatesArray count] forKey:@"numOfYesterdaysHeartRateSamplesInt"];
                        [defaults synchronize];
                        
                        //Query yesterday's step samples in order to validate RHR readings
                        [self queryAllOfYesterdaysStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                         {
                             
                         }];
                    
                        [self queryAllOfTodaysHeartRates:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                         {
                             
                         }];
                    }
                }];
                
                [healthStore executeQuery:query];
            }
            //RHR_1_day_ago data already exists in Parse just run the next query
            else
            {
                NSLog (@"RHR_1_day_ago already exist, just run queryAllOfTwoDaysAgoHeartRates.");
                //Kick off the query for
                [self queryAllOfTwoDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
                
                //Run this so the info can be accessed in MeViewController
                [self queryAllOfTodaysHeartRates:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
            }
        }
    }
    //If allowHRRelatedQueries is NO then just skip all HR related queries and run the final fitnessCalculation query after you run the required queryAllOfTodaysHeartRates for the sake of MeViewController
    else
    {
        //Run this so the info can be accessed in MeViewController
        [self queryAllOfTodaysHeartRates:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             NSLog (@"calling calculateFitnessRating from queryAllOfYesterdaysHeartRates");
             //Call method to calculate 'fitness_rating' here since all other health queries are now finished
             [self calculateFitnessRating: viewController completion:^(double done, NSError *error)
              {
                  
              }];
         }];
    }
}


//Query all of yesterday's HR's
- (void)queryAllOfTwoDaysAgoHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfTwoDaysAgoHeartRates running!");
    
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
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *twoDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:twoDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 2)
    {
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results)
            {
                NSLog(@"An error occured fetching the user's heart rate samples for two days ago. In your app, try to handle this gracefully. The error was: %@.", error);
            }
            else
            {
              //  dispatch_async(dispatch_get_main_queue(), ^{
                    [twoDaysAgoHeartRatesArray removeAllObjects];
                    
                    for (HKQuantitySample *sample in results)
                    {
                        [twoDaysAgoHeartRatesArray addObject:sample];
                    }
                    
                    NSLog (@"twoDaysAgoHeartRatesArray count = %lu", (unsigned long)[twoDaysAgoHeartRatesArray count]);
                
                    //Save numOfTwoDaysAgoHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setInteger:[twoDaysAgoHeartRatesArray count] forKey:@"numOfTwoDaysAgoHeartRateSamples"];
                    [defaults synchronize];
                
                    //Start querying step data for two days ago
                    [self queryAllOfTwoDaysAgoStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                     {
                         
                     }];

                //});
            }
        }];
        
        [healthStore executeQuery:query];
    }
    //RHR_2_days_ago data already exists in Parse just run the next query
    else
    {
        NSLog (@"RHR_2_days_ago already exist, just run queryAllOfThreeDaysAgoHeartRates.");
        //Kick off the query for
        [self queryAllOfThreeDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query all of yesterday's HR's
- (void)queryAllOfThreeDaysAgoHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfThreeDaysAgoHeartRates running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for three days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    //two days ago at midnight used to get todayPredicate
    [components setHour:-48];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *threeDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:threeDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 3)
    {
        NSLog (@"HOLLA!");
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results)
            {
                NSLog(@"An error occured fetching the user's heart rate samples for three days ago. In your app, try to handle this gracefully. The error was: %@.", error);
            }
            else
            {
                //  dispatch_async(dispatch_get_main_queue(), ^{
                [threeDaysAgoHeartRatesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [threeDaysAgoHeartRatesArray addObject:sample];
                }
                
                NSLog (@"threeDaysAgoHeartRatesArray count = %lu", (unsigned long)[threeDaysAgoHeartRatesArray count]);
                
                //Save numOfThreeDaysAgoHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:[threeDaysAgoHeartRatesArray count] forKey:@"numOfThreeDaysAgoHeartRateSamples"];
                [defaults synchronize];
                
                //Start querying step data for three days ago
                [self queryAllOfThreeDaysAgoStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
                
                //});
            }
        }];
        
        [healthStore executeQuery:query];
    }
    //RHR_3_days_ago data already exists in Parse just run the next query
    else
    {
        NSLog (@"RHR_3_days_ago already exist, just run queryAllOfFourDaysAgoHeartRates.");
        //Kick off the query for
        [self queryAllOfFourDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query all of yesterday's HR's
- (void)queryAllOfFourDaysAgoHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfFourDaysAgoHeartRates running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for four days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    //three days ago at midnight used to get todayPredicate
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fourDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fourDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 4)
    {
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results)
            {
                NSLog(@"An error occured fetching the user's heart rate samples for four days ago. In your app, try to handle this gracefully. The error was: %@.", error);
            }
            else
            {
                //  dispatch_async(dispatch_get_main_queue(), ^{
                [fourDaysAgoHeartRatesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [fourDaysAgoHeartRatesArray addObject:sample];
                }
                
                NSLog (@"fourDaysAgoHeartRatesArray count = %lu", (unsigned long)[fourDaysAgoHeartRatesArray count]);
                
                //Save numOfFourDaysAgoHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:[fourDaysAgoHeartRatesArray count] forKey:@"numOfFourDaysAgoHeartRateSamples"];
                [defaults synchronize];
                
                //Start querying step data for four days ago
                [self queryAllOfFourDaysAgoStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
                
                //});
            }
        }];
        
        [healthStore executeQuery:query];
    }
    //RHR_4_days_ago data already exists in Parse just run the next query
    else
    {
        NSLog (@"RHR_4_days_ago already exist, just run queryAllOfFiveDaysAgoHeartRates.");
        //Kick off the query for
        [self queryAllOfFiveDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query all of yesterday's HR's
- (void)queryAllOfFiveDaysAgoHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfFiveDaysAgoHeartRates running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for four days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    //three days ago at midnight used to get todayPredicate
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fiveDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:fiveDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 5)
    {
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results)
            {
                NSLog(@"An error occured fetching the user's heart rate samples for five days ago. In your app, try to handle this gracefully. The error was: %@.", error);
            }
            else
            {
                //  dispatch_async(dispatch_get_main_queue(), ^{
                [fiveDaysAgoHeartRatesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [fiveDaysAgoHeartRatesArray addObject:sample];
                }
                
                NSLog (@"fiveDaysAgoHeartRatesArray count = %lu", (unsigned long)[fiveDaysAgoHeartRatesArray count]);
                
                //Save numOfFiveDaysAgoHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:[fiveDaysAgoHeartRatesArray count] forKey:@"numOfFiveDaysAgoHeartRateSamples"];
                [defaults synchronize];
                
                //Start querying step data for five days ago
                [self queryAllOfFiveDaysAgoStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
                
                //});
            }
        }];
        
        [healthStore executeQuery:query];
    }
    //RHR_5_days_ago data already exists in Parse just run the next query
    else
    {
        NSLog (@"RHR_5_days_ago already exist, just run queryAllOfSixDaysAgoHeartRates.");
        //Kick off the query for
        [self queryAllOfSixDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Query all of yesterday's HR's
- (void)queryAllOfSixDaysAgoHeartRates: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryAllOfSixDaysAgoHeartRates running!");
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for six days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-144];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];
    
    //five days ago at midnight used to get todayPredicate
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *sixDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //Create compound predicate
    NSPredicate *sourcesPredicate = [HKQuery predicateForObjectsFromSources:sourcesSet];
    NSPredicate *wasUserEnteredPredicate = [NSPredicate predicateWithFormat:@"metadata.%K != YES", HKMetadataKeyWasUserEntered];
    NSArray *predicatesArray = [NSArray arrayWithObjects:sixDaysAgoPredicate,sourcesPredicate,  wasUserEnteredPredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 6)
    {
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:compoundPredicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results)
            {
                NSLog(@"An error occured fetching the user's heart rate samples for six days ago. In your app, try to handle this gracefully. The error was: %@.", error);
            }
            else
            {
                //  dispatch_async(dispatch_get_main_queue(), ^{
                [sixDaysAgoHeartRatesArray removeAllObjects];
                
                for (HKQuantitySample *sample in results)
                {
                    [sixDaysAgoHeartRatesArray addObject:sample];
                }
                
                NSLog (@"sixDaysAgoHeartRatesArray count = %lu", (unsigned long)[sixDaysAgoHeartRatesArray count]);
                
                //Save numOfSixDaysAgoHeartRateSamples to NSUserDefaults so it can be accessed in MeViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:[sixDaysAgoHeartRatesArray count] forKey:@"numOfSixDaysAgoHeartRateSamples"];
                [defaults synchronize];
                
                //Start querying step data for six days ago
                [self queryAllOfSixDaysAgoStepSamples:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
                 {
                     
                 }];
                
                //});
            }
        }];
        
        [healthStore executeQuery:query];
    }
    //RHR_6_days_ago data already exists in Parse just run the next query to start finding yesterday's 1min HRR
    else
    {
        //Start querying yesterday's 1-minute HRR from here
        //Finished calculating yesterday's resting HR, now calculate two day's ago HRR
        [self queryForYesterdays1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

//Calculate resting HR
-(void) calculateYesterdaysRestingHR:(MeViewController*)viewController
{
    NSLog (@"calculateYesterdaysRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([yesterdaysHeartRatesArray count] > 0)
    {
        for (int i = 0; i < [yesterdaysHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [yesterdaysHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];

            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSLog (@"bpmValueBeingAnalyzed! = %f", [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]]);
                
                NSDate *date2 = [[yesterdaysHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[yesterdaysHeartRatesArray objectAtIndex:i] startDate];

                //make sure there are no Apple Watch readings for it for two minutes after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through yesterdaysHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [yesterdaysHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [yesterdaysHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[yesterdaysHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[yesterdaysHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [yesterdaysStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[yesterdaysStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [yesterdaysStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar yesterday = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar yesterday date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate yesterday stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *yesterdaysRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:yesterdaysRestingHeartRate forKey:@"RHR_1_day_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"yesterdaysRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
    
    //Finished calculating yesterday's resting HR, now calculate two day's ago resting HR
    [self queryAllOfTwoDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

-(void) calculateTwoDaysAgoRestingHR: (MeViewController*)viewController
{
    NSLog (@"calculateTwoDaysAgoRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([twoDaysAgoHeartRatesArray count] > 0)
    {
    
        for (int i = 0; i < [twoDaysAgoHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [twoDaysAgoHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSDate *date2 = [[twoDaysAgoHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[twoDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                //make sure there are no Apple Watch readings for it for two minutes before and after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through twoDaysAgoHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [twoDaysAgoHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [twoDaysAgoHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[twoDaysAgoHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[twoDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [twoDaysAgoStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[twoDaysAgoStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [twoDaysAgoStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar two days ago = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar two days ago date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate two days ago stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *twoDaysAgoRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:twoDaysAgoRestingHeartRate forKey:@"RHR_2_days_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"twoDaysAgoRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
    
    //Finished calculating yesterday's resting HR, now calculate two day's ago resting HR
    [self queryAllOfThreeDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

-(void) calculateThreeDaysAgoRestingHR: (MeViewController*)viewController
{
    NSLog (@"calculateThreeDaysAgoRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([threeDaysAgoHeartRatesArray count] > 0)
    {
    
        for (int i = 0; i < [threeDaysAgoHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [threeDaysAgoHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSDate *date2 = [[threeDaysAgoHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[threeDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                //make sure there are no Apple Watch readings for it for two minutes before and after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through threeDaysAgoHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [threeDaysAgoHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [threeDaysAgoHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[threeDaysAgoHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[threeDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [threeDaysAgoStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[threeDaysAgoStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [threeDaysAgoStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar three days ago = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar three days ago date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate three days ago stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *threeDaysAgoRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:threeDaysAgoRestingHeartRate forKey:@"RHR_3_days_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"threeDaysAgoRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
    
    //Finished calculating yesterday's resting HR, now calculate two day's ago resting HR
    [self queryAllOfFourDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

-(void) calculateFourDaysAgoRestingHR: (MeViewController*)viewController
{
    NSLog (@"calculateFourDaysAgoRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([fourDaysAgoHeartRatesArray count] > 0)
    {
        for (int i = 0; i < [fourDaysAgoHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [fourDaysAgoHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSDate *date2 = [[fourDaysAgoHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[fourDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                //make sure there are no Apple Watch readings for it for two minutes before and after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through fourDaysAgoHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [fourDaysAgoHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [fourDaysAgoHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[fourDaysAgoHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[fourDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [fourDaysAgoStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[fourDaysAgoStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [fourDaysAgoStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar four days ago = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar four days ago date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate four days ago stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *fourDaysAgoRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:fourDaysAgoRestingHeartRate forKey:@"RHR_4_days_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"fourDaysAgoRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
    
    //Finished calculating yesterday's resting HR, now calculate two day's ago resting HR
    [self queryAllOfFiveDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

-(void) calculateFiveDaysAgoRestingHR: (MeViewController*)viewController
{
    NSLog (@"calculateFiveDaysAgoRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([fiveDaysAgoHeartRatesArray count] > 0)
    {
        for (int i = 0; i < [fiveDaysAgoHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [fiveDaysAgoHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSDate *date2 = [[fiveDaysAgoHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[fiveDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                //make sure there are no Apple Watch readings for it for two minutes before and after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through fiveDaysAgoHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [fiveDaysAgoHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [fiveDaysAgoHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[fiveDaysAgoHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[fiveDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [fiveDaysAgoStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[fiveDaysAgoStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [fiveDaysAgoStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar five days ago = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar five days ago date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate five days ago stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *fiveDaysAgoRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:fiveDaysAgoRestingHeartRate forKey:@"RHR_5_days_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"fiveDaysAgoRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];
    
    //Finished calculating yesterday's resting HR, now calculate two day's ago resting HR
    [self queryAllOfSixDaysAgoHeartRates:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

-(void) calculateSixDaysAgoRestingHR: (MeViewController*)viewController
{
    NSLog (@"calculateSixDaysAgoRestingHR called!");
    
    double lowestHRAtIndex = 0;
    double lowestHRValueSoFar = 1000;
    double numberOfBPMMatches = 0;
    
    if ([sixDaysAgoHeartRatesArray count] > 0)
    {
        for (int i = 0; i < [sixDaysAgoHeartRatesArray count] - 1; i++)
            @autoreleasepool
        {
            HKQuantitySample *sample = [sixDaysAgoHeartRatesArray objectAtIndex:i];
            
            double bpmValueBeingAnalyzed = [[sample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
            
            //Find the lowest value
            if (bpmValueBeingAnalyzed < lowestHRValueSoFar)
            {
                NSDate *date2 = [[sixDaysAgoHeartRatesArray objectAtIndex:i + 1] startDate];
                NSDate *date1 = [[sixDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                //make sure there are no Apple Watch readings for it for two minutes before and after
                if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed > 0)
                {
                    //Now search through sixDaysAgoHeartRatesArray from i + 1 to see if there's another bpm within 1bpm of bpmValueBeingAnalyzed
                    for (int j = i + 1; j < [sixDaysAgoHeartRatesArray count] - 1; j++)
                        @autoreleasepool
                    {
                        HKQuantitySample *sample2 = [sixDaysAgoHeartRatesArray objectAtIndex:j];
                        
                        double bpmValueBeingAnalyzed2 = [[sample2 quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        
                        //Verify the second bpm is no larger than 1bpm of the first
                        if (bpmValueBeingAnalyzed2 <= bpmValueBeingAnalyzed + 1)
                        {
                            //Verify the new bpm doesn't have a reading located two ahead of it that has the same time stamp
                            NSDate *date2 = [[sixDaysAgoHeartRatesArray objectAtIndex:j + 1] startDate];
                            NSDate *date1 = [[sixDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                            
                            //make sure there are no Apple Watch readings for it for two minutes before and after
                            if ([date2 timeIntervalSinceDate:date1] >= 120 && bpmValueBeingAnalyzed2 > 0)
                            {
                                //Make sure that steps were taken within 45min before, or 45min after the time stamp for the bpm reading.
                                for (int k = 0; k < [sixDaysAgoStepSamplesArray count]; k++)
                                    @autoreleasepool
                                {
                                    NSDate *stepSampleDate = [[sixDaysAgoStepSamplesArray objectAtIndex:k] startDate];
                                    HKQuantitySample *steps = [sixDaysAgoStepSamplesArray objectAtIndex:k];
                                    double stepsValue = [[steps quantity] doubleValueForUnit:[HKUnit countUnit]];
                                    //This verifies that an adequate number of steps were taken 30 minutes before bpm sample time stamp
                                    if ([date1 timeIntervalSinceDate:stepSampleDate] <= 1500 && [date1 timeIntervalSinceDate:stepSampleDate] > 0 && stepsValue > 10)
                                    {
                                        lowestHRValueSoFar = bpmValueBeingAnalyzed;
                                        NSLog (@"NEW lowestHRValueSoFar six days ago = %f", lowestHRValueSoFar);
                                        NSLog (@"NEW lowestHRValueSoFar six days ago date1 = %@", [self convertToLocalTime:date1]);
                                        NSLog (@"NEW stepSampleDate six days ago stepSampleDate = %@", [self convertToLocalTime:stepSampleDate]);
                                        NSLog (@"[date1 timeIntervalSinceDate:stepSampleDate] = %f", [date1 timeIntervalSinceDate:stepSampleDate]);
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Write yesterday's resting heart rate to Parse
    NSNumber *sixDaysAgoRestingHeartRate = [NSNumber numberWithInteger:lowestHRValueSoFar];
    [[PFUser currentUser] setObject:sixDaysAgoRestingHeartRate forKey:@"RHR_6_days_ago"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // some logging code here
        NSLog (@"sixDaysAgoRestingHeartRate save in background success = %i", succeeded);
        NSLog (@"Error = %@", error);
    }];

    //Start querying yesterday's 1-minute HRR from here
    //Finished calculating yesterday's resting HR, now calculate two day's ago HRR
    [self queryForYesterdays1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
     {
         
     }];
}

- (void)queryForYesterdays1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForYesterdays1MinuteHRR called!");
    
    //Set this to always run for the sake of the 'HomeView' always showing yesterday's health stats
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 0)
    {
        int highestHRR = 0;
        
        if ([yesterdaysHeartRatesArray count] > 0)
        {
        //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [yesterdaysHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [yesterdaysHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[yesterdaysHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [yesterdaysHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[yesterdaysHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [yesterdaysHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [yesterdaysHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation
                        
                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"yesterdays currentSampleTimeStamp = %@", [self convertToLocalTime: currentSampleTimeStamp]);
                            NSLog (@"yesterdays nextSampleTimeStamp = %@", [self convertToLocalTime: nextSampleTimeStamp]);
                            NSLog (@"yesterdays currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"yesterdays nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"yesterdays timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"yesterdays new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write yesterday's 1-min HRR to parse
        NSNumber *yesterdaysHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:yesterdaysHRR forKey:@"HRR_1_day_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"yesterdaysHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
        
        //Start querying 2-days ago 1-minute HRR from here
        //Finished calculating yesterday's HRR, now calculate two day's ago HRR
        [self queryForTwoDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
    //HRR_1_day_ago already exists so just call queryForTwoDaysAgo1MinuteHRR
    else
    {
        [self queryForTwoDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

- (void)queryForTwoDaysAgo1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForTwoDaysAgo1MinuteHRR called!");
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 2)
    {
        int highestHRR = 0;
        
        if ([twoDaysAgoHeartRatesArray count] > 0)
        {
        
            //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [twoDaysAgoHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [twoDaysAgoHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[twoDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [twoDaysAgoHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[twoDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [twoDaysAgoHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [twoDaysAgoHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation
                        
                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"2daysAgo currentSampleTimeStamp = %@", currentSampleTimeStamp);
                            NSLog (@"2daysAgo nextSampleTimeStamp = %@", nextSampleTimeStamp);
                            NSLog (@"2daysAgo currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"2daysAgo nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"2daysAgo timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"2daysAgo new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write 2-days ago 1-min HRR to parse
        NSNumber *twoDaysAgoHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:twoDaysAgoHRR forKey:@"HRR_2_days_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"twoDaysAgoHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
        
        //Start querying 2-days ago 1-minute HRR from here
        //Finished calculating yesterday's HRR, now calculate two day's ago HRR
        [self queryForThreeDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
    //HRR_2_days_ago already exists so just call queryForThreeDaysAgo1MinuteHRR
    else
    {
        [self queryForThreeDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

- (void)queryForThreeDaysAgo1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForThreeDaysAgo1MinuteHRR called!");
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 3)
    {
        int highestHRR = 0;
        
        if ([threeDaysAgoHeartRatesArray count] > 0)
        {
        
            //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [threeDaysAgoHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [threeDaysAgoHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[threeDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [threeDaysAgoHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[threeDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [threeDaysAgoHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [threeDaysAgoHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation

                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"3daysAgo currentSampleTimeStamp = %@", [self convertToLocalTime: currentSampleTimeStamp]);
                            NSLog (@"3daysAgo nextSampleTimeStamp = %@", [self convertToLocalTime: nextSampleTimeStamp]);
                            NSLog (@"3daysAgo currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"3daysAgo nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"3daysAgo timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"3daysAgo new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write 3-days ago 1-min HRR to parse
        NSNumber *threeDaysAgoHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:threeDaysAgoHRR forKey:@"HRR_3_days_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"threeDaysAgoHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
        
        //Start querying 4-days ago 1-minute HRR from here
        //Finished calculating yesterday's HRR, now calculate two day's ago HRR
        [self queryForFourDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
    //HRR_3_days_ago already exists so just call queryForFourDaysAgo1MinuteHRR
    else
    {
        [self queryForFourDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

- (void)queryForFourDaysAgo1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForFourDaysAgo1MinuteHRR called!");
    
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 4)
    {
        int highestHRR = 0;
        
        if ([fourDaysAgoHeartRatesArray count] > 0)
        {
            //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [fourDaysAgoHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [fourDaysAgoHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[fourDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [fourDaysAgoHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[fourDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [fourDaysAgoHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [fourDaysAgoHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation
                        
                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"4daysAgo currentSampleTimeStamp = %@", [self convertToLocalTime: currentSampleTimeStamp]);
                            NSLog (@"4daysAgo nextSampleTimeStamp = %@", [self convertToLocalTime: nextSampleTimeStamp]);
                            NSLog (@"4daysAgo currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"4daysAgo nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"4daysAgo timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"4daysAgo new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write 4-days ago 1-min HRR to parse
        NSNumber *fourDaysAgoHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:fourDaysAgoHRR forKey:@"HRR_4_days_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"fourDaysAgoHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
        
        //Start querying 4-days ago 1-minute HRR from here
        //Finished calculating yesterday's HRR, now calculate two day's ago HRR
        [self queryForFiveDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
    //HRR_4_days_ago already exists so just call queryForFiveDaysAgo1MinuteHRR
    else
    {
        [self queryForFiveDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

- (void)queryForFiveDaysAgo1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForFiveDaysAgo1MinuteHRR called!");
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 5)
    {
        int highestHRR = 0;
        
        if ([fiveDaysAgoHeartRatesArray count] > 0)
        {
        
            //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [fiveDaysAgoHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [fiveDaysAgoHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[fiveDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [fiveDaysAgoHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[fiveDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [fiveDaysAgoHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [fiveDaysAgoHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];

                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation
                
                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"5daysAgo currentSampleTimeStamp = %@", [self convertToLocalTime: currentSampleTimeStamp]);
                            NSLog (@"5daysAgo nextSampleTimeStamp = %@", [self convertToLocalTime: nextSampleTimeStamp]);
                            NSLog (@"5daysAgo currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"5daysAgo nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"5daysAgo timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"5daysAgo new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write 5-days ago 1-min HRR to parse
        NSNumber *fiveDaysAgoHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:fiveDaysAgoHRR forKey:@"HRR_5_days_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"fiveDaysAgoHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
        }];
        
         //Start querying 4-days ago 1-minute HRR from here
         //Finished calculating yesterday's HRR, now calculate two day's ago HRR
         [self queryForSixDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
         
         }];
    }
    //HRR_5_days_ago already exists so just call queryForSixDaysAgo1MinuteHRR
    else
    {
        [self queryForSixDaysAgo1MinuteHRR:viewController unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double done, NSError *error)
         {
             
         }];
    }
}

- (void)queryForSixDaysAgo1MinuteHRR: (MeViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"queryForSixDaysAgo1MinuteHRR called!");
    
    //See if data already exists
    if ([self numberOfDaysBetweenQueryLastRunAndNow] >= 6)
    {
        int highestHRR = 0;
        
        if ([sixDaysAgoHeartRatesArray count] > 0)
        {
        
            //iterate from every sample for 6 samples after making sure the time stamps are as expected.
            for (int i = 0; i < [sixDaysAgoHeartRatesArray count] - 1; i++)
                @autoreleasepool
            {
                //BPM for current sample
                HKQuantitySample *currentSample = [sixDaysAgoHeartRatesArray objectAtIndex:i];
                int currentSampleBPM = [[currentSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                
                //-Declare next sample's time stamp.
                NSDate *nextSampleTimeStamp;
                
                //-Take currently iterated sample's time stamp including seconds
                NSDate *currentSampleTimeStamp = [[sixDaysAgoHeartRatesArray objectAtIndex:i] startDate];
                
                int timeDifferenceInSeconds = 0;
                
                //...then try the sample after that
                for (int j = i + 1; j < [sixDaysAgoHeartRatesArray count] - 2; j++)
                    @autoreleasepool
                {
                    nextSampleTimeStamp = [[sixDaysAgoHeartRatesArray objectAtIndex:j] startDate];
                    
                    //-Subtract the 2nd sample's time stamp from the currently iterated.
                    timeDifferenceInSeconds = [nextSampleTimeStamp timeIntervalSinceDate:currentSampleTimeStamp];
                    
                    //BPM for next sample
                    HKQuantitySample *nextSample = [sixDaysAgoHeartRatesArray objectAtIndex:j];
                    int nextSampleBPM = [[nextSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    //Make sure bpm of sample j is no greater than like 40bpm of j - 1
                    HKQuantitySample *sampleJMinusOne = [sixDaysAgoHeartRatesArray objectAtIndex:j - 1];
                    int sampleJMinusOneBPM = [[sampleJMinusOne quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    
                    if (sampleJMinusOneBPM > nextSampleBPM + 35)
                    {
                        break;
                    }
                    
                    //If the time difference between the two samples is greater than 70 seconds than break to save CPU cycles
                    if (timeDifferenceInSeconds > 70)
                    {
                        break;
                    }
                    
                    //-If the difference is more than 60 seconds and less than 75 seconds...
                    if (currentSampleBPM > 135 && timeDifferenceInSeconds > 60 && timeDifferenceInSeconds < 65)
                    {
                        //...then you have your two samples. proceed with 1-Minute HRR calculation

                        //If bpm of sample j is more than 1bpm higher than sample i then break out of this for loop
                        if (nextSampleBPM > currentSampleBPM)
                        {
                            break;
                        }
                        
                        int newHRR = currentSampleBPM - nextSampleBPM;
                        if (newHRR > highestHRR)
                        {
                            highestHRR = newHRR;
                            NSLog (@"6daysAgo currentSampleTimeStamp = %@", [self convertToLocalTime: currentSampleTimeStamp]);
                            NSLog (@"6daysAgo nextSampleTimeStamp = %@", [self convertToLocalTime: nextSampleTimeStamp]);
                            NSLog (@"6daysAgo currentSampleBPM = %i", currentSampleBPM);
                            NSLog (@"6daysAgo nextSampleBPM = %i", nextSampleBPM);
                            NSLog (@"6daysAgo timeDifferenceInSeconds = %i", timeDifferenceInSeconds);
                            NSLog (@"6daysAgo new highestHRR = %i", highestHRR);
                        }
                        
                        break;
                    }
                }
            }
        }
        
        //Write 6-days ago 1-min HRR to parse
        NSNumber *sixDaysAgoHRR = [NSNumber numberWithInteger:highestHRR];
        [[PFUser currentUser] setObject:sixDaysAgoHRR forKey:@"HRR_6_days_ago"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // some logging code here
            NSLog (@"sixDaysAgoHRR save in background success = %i", succeeded);
            NSLog (@"Error = %@", error);
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HeartRatesQueryCurrentlyRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        NSLog (@"calling calculateFitnessRating from queryForSixDaysAgo1MinuteHRR");
        //Call method to calculate 'fitness_rating' here since all other health queries are now finished
        [self calculateFitnessRating: viewController completion:^(double done, NSError *error)
         {
             
         }];
    }
    //HRR_6_days_ago already exists so just call queryForSixDaysAgo1MinuteHRR
    else
    {
        NSLog (@"calling calculateFitnessRating from queryForSixDaysAgo1MinuteHRR");
        //Call method to calculate 'fitness_rating' here since all other health queries are now finished
        [self calculateFitnessRating: viewController completion:^(double done, NSError *error)
         {
             
         }];
    }
}

// Path to the data file in the app's Documents directory
- (NSString *) pathForDataFile
{
    NSArray*	documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*	path = nil;
    
    if (documentDir) {
        path = [documentDir objectAtIndex:0];
    }
    
    return [NSString stringWithFormat:@"%@/%@", path, @"data.bin"];
}

- (NSString *) pathForData2File
{
    NSArray*	documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*	path = nil;
    
    if (documentDir) {
        path = [documentDir objectAtIndex:0];
    }
    
    return [NSString stringWithFormat:@"%@/%@", path, @"data2.bin"];
}

//Save ArchivedReading to disk for logging purposes
-(void) saveFriendsListRankingScoreToDisk: (void (^)(double, NSError *))completionHandler
{
    NSLog (@"saveFriendsFitnessRankingScoreToDisk running");
    NSString *path = [self pathForData2File];
    
    if ([PFUser currentUser])
    {
        //Query parse for all friend objects
        PFQuery *friendsQuery1 = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [friendsQuery1 whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [friendsQuery1 whereKey:@"saved_to_list" equalTo:@"Following"];
        //[query whereKey:@"FriendStatus" equalTo:@"Friends"];
        [friendsQuery1 whereKey:@"fromUserToUserSame" notEqualTo:@"YES"];
        [friendsQuery1 orderByDescending:@"toUserListRankingScore"];
        [friendsQuery1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             [archivedReadingsArray removeAllObjects];
             NSLog (@"archivedReadingsArray count should be 0 = %li", [archivedReadingsArray count]);
             
            for (PFObject *activityObject in objects)
            {
                NSLog (@"HealthMethods number of friends = %lu", (unsigned long)[objects count]);
                
                PFUser *userFetched = activityObject[@"toUser"];
                [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                 {
                     NSLog (@"saveFriendsListRankingScoreToDisk userFetched = %@", userFetched);

                    //Get user's stats in a saveable format
                    ArchivedReading *usersFitnessData = [[ArchivedReading alloc] init];
                    usersFitnessData.listRankingScore = [userFetched[@"listRankingScore"] floatValue];
                    usersFitnessData.yesterdaysListRankingScore = [userFetched[@"yesterdaysListRankingScore"] floatValue];
                    usersFitnessData.moveGoal = [userFetched[@"moveGoal"] floatValue];
                    usersFitnessData.lastUpdated = [userFetched updatedAt];
                    usersFitnessData.updatedToday = [self isNSDateToday:userFetched.updatedAt];
                    usersFitnessData.userObjectId = [userFetched objectId];
                    usersFitnessData.usersFullName = userFetched[@"full_name"];
                    
                    NSLog (@"reading.lastUpdated = %@", [userFetched updatedAt]);
                    NSLog (@"usersFitnessData.updatedToday = %i", [self isNSDateToday:userFetched.updatedAt]);
                    NSLog (@"reading.listRankingScore = %f", [userFetched[@"listRankingScore"] floatValue]);
                    NSLog (@"reading.yesterdaysListRankingScore = %f", [userFetched[@"yesterdaysListRankingScore"] floatValue]);
                    NSLog (@"reading.moveGoal = %f", [userFetched[@"moveGoal"] floatValue]);
                    NSLog (@"reading.userObjectId = %@", [userFetched objectId]);
                    NSLog (@"usersFitnessData.usersFullName = %@", userFetched[@"full_name"]);

                    //Add 'reading' to array
                    [archivedReadingsArray addObject: usersFitnessData];
                     
                     NSMutableArray *friendsObjectIdArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsObjectIdArray"];
                     NSLog (@"healthMethods friendsObjectIdArray count = %li", [friendsObjectIdArray count]);
                     NSLog (@"HealthMethods archivedReadingsArray count = %li", [archivedReadingsArray count]);
                     
                     if ([archivedReadingsArray count] == [friendsObjectIdArray count])
                     {
                         NSLog (@"HUZZAH!");
                         
                         //Make sure to reorder objects in both arrays so that the highest listRankingScores are on top
                         NSSortDescriptor *sortDescriptor;
                         sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listRankingScore" ascending:NO];
                         NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                         NSArray *sortedArray;
                         sortedArray = [archivedReadingsArray sortedArrayUsingDescriptors:sortDescriptors];
                         [archivedReadingsArray removeAllObjects];
                         [archivedReadingsArray addObjectsFromArray: sortedArray];
                         
                         NSArray *unmutableArchivedReadingsArray = [NSArray arrayWithArray: archivedReadingsArray];
                         
                         NSLog (@"sorting archivedReadingsArray count = %lu", (unsigned long)[archivedReadingsArray count]);
                         
                         NSLog (@"saving unmutableArchivedReadingsArray to disk!");
                         //Save array to disk
                         [NSKeyedArchiver archiveRootObject:unmutableArchivedReadingsArray toFile:path];
                         
                         [self readArchivedReadingsArrayFromDisk];
                     }
                 }];
            }
             
            completionHandler(YES, nil);
        }];
    }
}

//read archivedReadingsArray from disk
- (void) readArchivedReadingsArrayFromDisk
{
    NSLog (@"readArchivedReadingsArrayFromDisk called!");
    
    NSString *path = [self pathForData2File];
    
    NSArray *unmutableArchivedReadingsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSLog (@"readArchivedReadingsArrayFromDisk unmutableArchivedReadingsArray count = %li", [unmutableArchivedReadingsArray count]);
    
    [archivedReadingsArray addObjectsFromArray: unmutableArchivedReadingsArray];
    
    NSLog (@"readArchivedReadingsArrayFromDisk archivedReadingsArray count = %li", [archivedReadingsArray count]);
    
    for (ArchivedReading *archivedReadingObject in archivedReadingsArray)
    {
        NSLog (@"friends ranking order = %@", archivedReadingObject.usersFullName);
    }
    
//    [self sendAppropriateCompetitiveNotificationMessage];
}

//read archivedReadingsArray from disk
- (void) readArchivedReadingsArrayFromDisk: (NSDate*)dateArg
{
    NSLog (@"readArchivedReadingsArrayFromDisk called!");
    
    NSString *path = [self pathForData2File];
    
    NSArray *unmutableArchivedReadingsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSLog (@"readArchivedReadingsArrayFromDisk unmutableArchivedReadingsArray count = %li", [unmutableArchivedReadingsArray count]);
    
    [archivedReadingsArray addObjectsFromArray: unmutableArchivedReadingsArray];
    
    NSLog (@"readArchivedReadingsArrayFromDisk archivedReadingsArray count = %li", [archivedReadingsArray count]);
    
    for (ArchivedReading *archivedReadingObject in archivedReadingsArray)
    {
        NSLog (@"friends ranking order = %@", archivedReadingObject.usersFullName);
    }
    
 //   [self sendAppropriateCompetitiveNotificationMessage: dateArg];
}

-(NSDate *) convertToGlobalTime: (NSDate*)utcTimeArg
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: utcTimeArg];
    return [NSDate dateWithTimeInterval: seconds sinceDate: utcTimeArg];
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

-(BOOL) currentTimeFallsBetweenMidnightAnd3am
{
    //Create today at midnight NSDate
    NSDate *todayMidnight = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    
    //Create today at 3am NSDate
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:3];
    NSDate *today3am = [calendar dateFromComponents:components];
    
    if ( ([[NSDate date] compare:todayMidnight] == NSOrderedDescending) &&
        ([[NSDate date] compare:today3am] == NSOrderedAscending))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSString *)determineProperPushNotificationMessage:(NSArray*)newestFriendsFitnessDataArray
{
    NSLog (@"determineProperPushNotificationMessage called!");
    //Comparison algo:
    // Someone else is #1 congratulate them
    int currentUserOldArrayIndex = 0;
    int currentUserNewArrayIndex = 0;
    int userFormerlyUnderneathYouOldArrayIndex = 0;
    int userFormerlyUnderneathYouNewArrayIndex = 0;
    int userFormerlyAboveYouOldArrayIndex = 0;
    int userFormerlyAboveYouNewArrayIndex = 0;
    
    for (ArchivedReading *oldArrayObject in archivedReadingsArray)
    {
        if ([oldArrayObject.userObjectId isEqualToString:[PFUser currentUser].objectId])
        {
            currentUserOldArrayIndex = (int)[archivedReadingsArray indexOfObject:oldArrayObject];
        }
    }
    
    if (currentUserOldArrayIndex != [archivedReadingsArray count] - 1)
    {
        userFormerlyUnderneathYouOldArrayIndex = currentUserOldArrayIndex + 1;
    }
    
    if (currentUserOldArrayIndex > 0)
    {
        userFormerlyAboveYouOldArrayIndex = currentUserOldArrayIndex - 1;
    }
    
    //Now look through newArrayObject
    for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
    {
        //Get index of current user within the newestFriendsFitnessDataArray
        if ([newArrayObject.userObjectId isEqualToString:[PFUser currentUser].objectId])
        {
            currentUserNewArrayIndex = (int)[newestFriendsFitnessDataArray indexOfObject:newArrayObject];
        }
    }
    //Make sure you're not on the bottom of your friends list before you declare someone else to be ranked beneath you
    if (currentUserNewArrayIndex != [newestFriendsFitnessDataArray count] - 1 && userFormerlyUnderneathYouOldArrayIndex != 0)
    {
        userFormerlyUnderneathYouNewArrayIndex = currentUserNewArrayIndex + 1;
    }
    if (currentUserNewArrayIndex > 0)
    {
        userFormerlyAboveYouNewArrayIndex = currentUserNewArrayIndex - 1;
    }
    
    //Change the following to elicit different messages!
    //Current intension:
   /*
     currentUserOldArrayIndex = 1;
     currentUserNewArrayIndex = 2;
     userFormerlyUnderneathYouOldArrayIndex = 3;
     userFormerlyUnderneathYouNewArrayIndex = 2;
     userFormerlyAboveYouOldArrayIndex = 0;
     userFormerlyAboveYouNewArrayIndex = 0;
    */
    NSLog (@"currentUserOldArrayIndex = %i", currentUserOldArrayIndex);
    NSLog (@"currentUserNewArrayIndex = %i", currentUserNewArrayIndex);
    NSLog (@"userFormerlyUnderneathYouOldArrayIndex = %i", userFormerlyUnderneathYouOldArrayIndex);
    NSLog (@"userFormerlyUnderneathYouNewArrayIndex = %i", userFormerlyUnderneathYouNewArrayIndex);
    NSLog (@"userFormerlyAboveYouOldArrayIndex = %i", userFormerlyAboveYouOldArrayIndex);
    NSLog (@"userFormerlyAboveYouNewArrayIndex = %i", userFormerlyAboveYouNewArrayIndex);
    
    //If you're #1 on the list, say congratulations to yourself
    if  (currentUserNewArrayIndex == 0)
    {
        NSLog (@"Nice! You're #1 on your friends list for today so far");
        
        return [NSString stringWithFormat:@"Nice! You're #1 on your friends list for today so far"];
    }
    //If you're not #1...
    else if (currentUserNewArrayIndex != 0)
    {
        // Make it a 50-50 chance of sending a message saying someone is #1, or who is right above you
        bool sendCurrentTopRankedMessage = 0;
        sendCurrentTopRankedMessage = arc4random()%2;
        
        //Send a message saying someone else is #1 right now
        if (sendCurrentTopRankedMessage == 1)
        {
            ArchivedReading *currentTopRankedUser = [newestFriendsFitnessDataArray objectAtIndex:0];
            
            NSLog (@"%@ is #1 right now", currentTopRankedUser.usersFullName);
            
            return [NSString stringWithFormat:@"%@ is #1 right now", currentTopRankedUser.usersFullName];
        }
        //Send a message saying who is above you
        else
        {
            ArchivedReading *userAboveYou = [newestFriendsFitnessDataArray objectAtIndex:currentUserNewArrayIndex - 1];
            
            NSLog (@"%@ is right above you in today's rankings", userAboveYou.usersFullName);
            
            return [NSString stringWithFormat:@"%@ is right above you in today's rankings", userAboveYou.usersFullName];
        }
    }
    
    //If none of the above are returned then return this generic message
    return [NSString stringWithFormat:@"You're doing great today, keep it up!"];
}

/* This is the former advnaced push notification message.  Replacing it for a much simpler verison
-(NSString *)determineProperPushNotificationMessage:(NSArray*)newestFriendsFitnessDataArray
{
    NSLog (@"Determine message to send current user!");
    //Comparison algo:
    // Someone else is #1 congratulate them
    int currentUserOldArrayIndex = 0;
    int currentUserNewArrayIndex = 0;
    int userFormerlyUnderneathYouOldArrayIndex = 0;
    int userFormerlyUnderneathYouNewArrayIndex = 0;
    int userFormerlyAboveYouOldArrayIndex = 0;
    int userFormerlyAboveYouNewArrayIndex = 0;
    
    for (ArchivedReading *oldArrayObject in archivedReadingsArray)
    {
        if ([oldArrayObject.userObjectId isEqualToString:[PFUser currentUser].objectId])
        {
            currentUserOldArrayIndex = (int)[archivedReadingsArray indexOfObject:oldArrayObject];
        }
    }
    
    if (currentUserOldArrayIndex != [archivedReadingsArray count] - 1)
    {
        userFormerlyUnderneathYouOldArrayIndex = currentUserOldArrayIndex + 1;
    }
    
    if (currentUserOldArrayIndex > 0)
    {
        userFormerlyAboveYouOldArrayIndex = currentUserOldArrayIndex - 1;
    }
    
    //Now look through newArrayObject
    for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
    {
        //Get index of current user within the newestFriendsFitnessDataArray
        if ([newArrayObject.userObjectId isEqualToString:[PFUser currentUser].objectId])
        {
            currentUserNewArrayIndex = (int)[newestFriendsFitnessDataArray indexOfObject:newArrayObject];
        }
    }
    //Make sure you're not on the bottom of your friends list before you declare someone else to be ranked beneath you
    if (currentUserNewArrayIndex != [newestFriendsFitnessDataArray count] - 1 && userFormerlyUnderneathYouOldArrayIndex != 0)
    {
        userFormerlyUnderneathYouNewArrayIndex = currentUserNewArrayIndex + 1;
    }
    if (currentUserNewArrayIndex > 0)
    {
        userFormerlyAboveYouNewArrayIndex = currentUserNewArrayIndex - 1;
    }
    
    //Change the following to elicit different messages!
    //Current intension:
    
    // currentUserOldArrayIndex = 0;
    // currentUserNewArrayIndex = 0;
    // userFormerlyUnderneathYouOldArrayIndex = 0;
    // userFormerlyUnderneathYouNewArrayIndex = 0;
    // userFormerlyAboveYouOldArrayIndex = 0;
    // userFormerlyAboveYouNewArrayIndex = 0;
    
    NSLog (@"currentUserOldArrayIndex = %i", currentUserOldArrayIndex);
    NSLog (@"currentUserNewArrayIndex = %i", currentUserNewArrayIndex);
    NSLog (@"userFormerlyUnderneathYouOldArrayIndex = %i", userFormerlyUnderneathYouOldArrayIndex);
    NSLog (@"userFormerlyUnderneathYouNewArrayIndex = %i", userFormerlyUnderneathYouNewArrayIndex);
    NSLog (@"userFormerlyAboveYouOldArrayIndex = %i", userFormerlyAboveYouOldArrayIndex);
    NSLog (@"userFormerlyAboveYouNewArrayIndex = %i", userFormerlyAboveYouNewArrayIndex);
    
    //Loop through newestFriendsFitnessDataArray and see if everyone's been updated today
    bool allFriendsUpdated = YES;
    for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
    {
        //If a friend has not been updated today set allFriendsUpdated to NO
        if (!([self isNSDateToday:newArrayObject.lastUpdated]))
        {
            allFriendsUpdated = NO;
        }
    }
    
    //If message about yesterday's most active friend hasn't been sent yet and everyone's stats have been updated TODAY then send a message saying who was on top yesterday
    if (allFriendsUpdated == YES && [[NSUserDefaults standardUserDefaults] boolForKey:@"TopScoreAlreadyAnnounced"] == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TopScoreAlreadyAnnounced"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Arrange newestFriendsFitnessDataArray by yesterdays top scorer to find who was on top
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"yesterdaysListRankingScore" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *unsortedArray = [NSArray arrayWithArray:newestFriendsFitnessDataArray];
        NSArray *sortedArray;
        sortedArray = [unsortedArray sortedArrayUsingDescriptors:sortDescriptors];
        
        //Top scorer
        ArchivedReading *topScorer = [sortedArray objectAtIndex:0];
        
        //Send notifcation about top scorer
        return [NSString stringWithFormat:@"%@ finished #1 yesterday!", topScorer.usersFullName];
        
    }
    //If the person who was below you is now above you. Make sure top score has already been announced for today
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TopScoreAlreadyAnnounced"] == YES && (userFormerlyUnderneathYouOldArrayIndex > currentUserOldArrayIndex) && (userFormerlyUnderneathYouNewArrayIndex < currentUserNewArrayIndex))
    {
        //Send message to current user telling you the guy beneath them just moved above them
        NSLog (@"someone surpassed you!");
        ArchivedReading *otherUserNowAboveYou = [newestFriendsFitnessDataArray objectAtIndex:userFormerlyUnderneathYouNewArrayIndex];
        
        NSLog (@"%@ just surpassed you", otherUserNowAboveYou.usersFullName);
        
        return [NSString stringWithFormat:@"%@ just surpassed you", otherUserNowAboveYou.usersFullName];
    }
    //Congratulatons to you:
    //If the person who was above you is now below you.  Make sure top score has already been announced for today
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TopScoreAlreadyAnnounced"] == NO && (userFormerlyAboveYouOldArrayIndex < currentUserOldArrayIndex) && (currentUserNewArrayIndex < userFormerlyAboveYouNewArrayIndex) && (userFormerlyAboveYouOldArrayIndex != 0 && currentUserOldArrayIndex != 0))
    {
        //Send message to current user telling you that you just surpassed the guy who had previously been above you
        NSLog (@"you surpassed someone!");
        ArchivedReading *otherUserNowBeneathYou = [newestFriendsFitnessDataArray objectAtIndex:userFormerlyAboveYouNewArrayIndex];
        
        NSLog (@"You just surpassed %@!", otherUserNowBeneathYou.usersFullName);
        
        return [NSString stringWithFormat:@"You just surpassed %@!", otherUserNowBeneathYou.usersFullName];
    }
    //Congratulations to someone else:
    //If the person who was below you is still below you, OR if the person who was above you is still above you. If your friends list only consists of you and one other person and you are on top then clearly userFormerlyAboveYouOldArrayIndex will be 0 and currentUserOldArrayIndex will be 0 so consider that
    else if  (currentUserOldArrayIndex == currentUserNewArrayIndex && userFormerlyUnderneathYouOldArrayIndex == userFormerlyUnderneathYouNewArrayIndex && userFormerlyAboveYouOldArrayIndex == userFormerlyAboveYouNewArrayIndex)
    {
        //Send a message to current user congratulating someone else
        NSLog (@"ranking is the same!");
        //If you're first place then congratulate yourself
        if (currentUserNewArrayIndex == 0)
        {
            NSLog (@"Nice! You're #1 on your friends list for today so far");
            
            return [NSString stringWithFormat:@"Nice! You're #1 on your friends list for today so far"];
        }
        //If someone else is then congratulate that person
        else if (currentUserNewArrayIndex != 0)
        {
            //Determine if person in spot #1 has gone above and beyond with steps or calories burned. If so make a statement about it
            //ArchivedReading *currentTopRankedUser = [newestFriendsFitnessDataArray objectAtIndex:0];
            
            //If four or more times as many calories burned

            //If three times as many calories burned
            
            //If twice as many calories burned
            
            
            //If more than 40k steps taken

            //If more than 30k steps taken
            
            //If more than 20k steps taken
            
            
            
            // Make it a 50-50 chance of sending a message saying someone is #1, or who is right above you
            bool sendCurrentTopRankedMessage = 0;
            sendCurrentTopRankedMessage = arc4random()%2;
            
            //Send a message saying who is #1 or #2
            if (sendCurrentTopRankedMessage == 1)
            {
                //If friends list has 4 or more people then create a chance of sending a message stating who is #2
                if ([newestFriendsFitnessDataArray count] > 3)
                {
                    bool sendWhoIsNum1RightNow = 0;
                    sendWhoIsNum1RightNow = arc4random()%3;
                    
                    //Send who is #1 right now
                    if (sendWhoIsNum1RightNow == 0 || sendWhoIsNum1RightNow == 1)
                    {
                        ArchivedReading *currentTopRankedUser = [newestFriendsFitnessDataArray objectAtIndex:0];
                        
                        NSLog (@"%@ is #1 right now!", currentTopRankedUser.usersFullName);
                        
                        return [NSString stringWithFormat:@"%@ is #1 right now!", currentTopRankedUser.usersFullName];
                    }
                    //Send who is #2 right now
                    else
                    {
                        if (currentUserNewArrayIndex == 1)
                        {
                            NSLog (@"You are ranked #2 right now");
                            
                            return [NSString stringWithFormat:@"You are ranked #2 right now"];
                        }
                        else
                        {
                            ArchivedReading *currentSecondTopRankedUser = [newestFriendsFitnessDataArray objectAtIndex:1];
                            
                            NSLog (@"%@ is ranked #2 right now", currentSecondTopRankedUser.usersFullName);
                            
                            UILocalNotification *notification = [[UILocalNotification alloc]init];
                            notification.repeatInterval = NSDayCalendarUnit;
                            [notification setAlertBody: [NSString stringWithFormat:@"%@ is ranked #2 right now", currentSecondTopRankedUser.usersFullName]];
                            [notification setFireDate:[NSDate date]];
                            [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
                            [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                            [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                        }
                    }
                    
                }
                //or else just send a message saying who is #1 right now
                else
                {
                    ArchivedReading *currentTopRankedUser = [newestFriendsFitnessDataArray objectAtIndex:0];
                    
                    NSLog (@"%@ is #1 right now", currentTopRankedUser.usersFullName);
                    
                    return [NSString stringWithFormat:@"%@ is #1 right now", currentTopRankedUser.usersFullName];

                }
            }
            //Send a message saying who is above you
            else
            {
                ArchivedReading *userAboveYou = [newestFriendsFitnessDataArray objectAtIndex:currentUserNewArrayIndex - 1];
                
                NSLog (@"%@ is right above you in today's rankings", userAboveYou.usersFullName);
                
                return [NSString stringWithFormat:@"%@ is right above you in today's rankings", userAboveYou.usersFullName];
            }
        }
    }
 
    //If none of the above are returned then return this generic message
    return [NSString stringWithFormat:@"You're doing great today, keep it up!"];
}
*/
/*
-(void) sendAppropriateCompetitiveNotificationMessage
{
    NSLog (@"sendAppropriateCompetitiveNotificationMessage called!");
    
    NSLog (@"currentTimeFallsBetweenMidnightAnd3am = %i", [self currentTimeFallsBetweenMidnightAnd3am]);
    
   // if (![self currentTimeFallsBetweenMidnightAnd3am])
   // {
        //Grab archivedReadingsArray
            //If archivedReadingsArray is empty then just return nothing
        if ([archivedReadingsArray count] == 0)
        {
            return;
        }
        else
        {
            if ([PFUser currentUser])
            {
                
                NSMutableArray *newestFriendsFitnessDataArray = [[NSMutableArray alloc] init];
                //If archivedReadingsArray is full then run a query for all of your friends and their fitness stats and save it to another array
                //Query parse for all friend objects
                PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
                [query whereKey:@"saved_to_list" equalTo:@"Following"];
                [query whereKey:@"FriendStatus" equalTo: @"Friends"];
                [query orderByDescending:@"toUserListRankingScore"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                     for (PFObject *activityObject in objects)
                     {
                         NSLog (@"number of friends = %lu", (unsigned long)[objects count]);
                         
                         PFUser *userFetched = activityObject[@"toUser"];
                         [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                          {
                              NSLog (@"HealthMethods userFetched = %@", userFetched);
                              
                              ArchivedReading *usersFitnessData = [[ArchivedReading alloc] init];
                              usersFitnessData.listRankingScore = [userFetched[@"listRankingScore"] floatValue];
                              usersFitnessData.yesterdaysListRankingScore = [userFetched[@"yesterdaysListRankingScore"] floatValue];
                              usersFitnessData.moveGoal = [userFetched[@"moveGoal"] floatValue];
                              usersFitnessData.lastUpdated = [userFetched updatedAt];
                              usersFitnessData.updatedToday = [self isNSDateToday:userFetched.updatedAt];
                              usersFitnessData.userObjectId = [userFetched objectId];
                              usersFitnessData.usersFullName = userFetched[@"full_name"];
                              
                              NSLog (@"reading.lastUpdated = %@", [userFetched updatedAt]);
                              NSLog (@"reading.lastUpdated = %i", [self isNSDateToday:userFetched.updatedAt]);
                              NSLog (@"reading.listRankingScore = %f", [userFetched[@"listRankingScore"] floatValue]);
                              NSLog (@"reading.yesterdaysListRankingScore = %f", [userFetched[@"yesterdaysListRankingScore"] floatValue]);
                              NSLog (@"reading.moveGoal = %f", [userFetched[@"moveGoal"] floatValue]);
                              NSLog (@"reading.userObjectId = %@", [userFetched objectId]);
                              NSLog (@"usersFitnessData.usersFullName = %@", userFetched[@"full_name"]);
                              
                              //Add 'reading' to array
                              [newestFriendsFitnessDataArray addObject: usersFitnessData];
                              
                              NSLog (@"[newestFriendsFitnessDataArray count] = %li", [newestFriendsFitnessDataArray count]);
                              NSLog (@"[objects count] = %li", [objects count]);
                              if ([newestFriendsFitnessDataArray count] == [objects count])
                              {
                                  //Make sure to reorder objects in both arrays so that the highest listRankingScores are on top
                                  NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"updatedToday" ascending:NO];
                                  NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"listRankingScore" ascending:NO];
                                  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor1];
                                  NSArray *sortedArray;
                                  sortedArray = [newestFriendsFitnessDataArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
                                  [newestFriendsFitnessDataArray removeAllObjects];
                                  [newestFriendsFitnessDataArray addObjectsFromArray: sortedArray];
                                  
                                  for (ArchivedReading *oldArrayObject in archivedReadingsArray)
                                  {
                                      NSLog (@"oldArrayObject = %f", oldArrayObject.listRankingScore);
                                      NSLog (@"oldArrayObject name: %@ converted time: %@, is NSDate Today: %i, moveGoal = %f", oldArrayObject.usersFullName, [self convertToGlobalTime:oldArrayObject.lastUpdated], [self isNSDateToday:oldArrayObject.lastUpdated], oldArrayObject.moveGoal);
                                  }
                                  for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
                                  {
                                      NSLog (@"newUserArray name: %@ converted time: %@, is NSDate Today: %i, moveGoal = %f", newArrayObject.usersFullName, [self convertToGlobalTime:newArrayObject.lastUpdated], [self isNSDateToday:newArrayObject.lastUpdated], newArrayObject.moveGoal);
                                  }
                                  
                                  //Call method here
                                  NSString *messageToSend = [self determineProperPushNotificationMessage: newestFriendsFitnessDataArray];
                                  
                                  //Schedule local notification using the above NSString
                                  UILocalNotification *notification = [[UILocalNotification alloc] init];
                                  notification.fireDate = [NSDate date];
                                  [notification setAlertBody:messageToSend];
                                  notification.soundName = UILocalNotificationDefaultSoundName;
                                  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                              }
                          }];
                     }
                 }];
            }
        }
   // }
}
 */
/*
-(void) sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg
{
    NSLog (@"sendAppropriateCompetitiveNotificationMessage called!");
    
    NSLog (@"currentTimeFallsBetweenMidnightAnd3am = %i", [self currentTimeFallsBetweenMidnightAnd3am]);
    
 //   if (![self currentTimeFallsBetweenMidnightAnd3am])
 //   {
        //Grab archivedReadingsArray
        //If archivedReadingsArray is empty then just return nothing
        if ([archivedReadingsArray count] == 0)
        {
            return;
        }
        else
        {
            if ([PFUser currentUser])
            {
                
                NSMutableArray *newestFriendsFitnessDataArray = [[NSMutableArray alloc] init];
                //If archivedReadingsArray is full then run a query for all of your friends and their fitness stats and save it to another array
                //Query parse for all friend objects
                PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
                [query whereKey:@"saved_to_list" equalTo:@"Following"];
                [query whereKey:@"FriendStatus" equalTo: @"Friends"];
                [query orderByDescending:@"toUserListRankingScore"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                     for (PFObject *activityObject in objects)
                     {
                         NSLog (@"number of friends = %lu", (unsigned long)[objects count]);
                         
                         PFUser *userFetched = activityObject[@"toUser"];
                         [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                          {
                              NSLog (@"HealthMethods userFetched = %@", userFetched);
                              
                              ArchivedReading *usersFitnessData = [[ArchivedReading alloc] init];
                              usersFitnessData.listRankingScore = [userFetched[@"listRankingScore"] floatValue];
                              usersFitnessData.yesterdaysListRankingScore = [userFetched[@"yesterdaysListRankingScore"] floatValue];
                              usersFitnessData.moveGoal = [userFetched[@"moveGoal"] floatValue];
                              usersFitnessData.lastUpdated = [userFetched updatedAt];
                              usersFitnessData.userObjectId = [userFetched objectId];
                              usersFitnessData.usersFullName = userFetched[@"full_name"];
                              
                              NSLog (@"reading.lastUpdated = %@", [userFetched updatedAt]);
                              NSLog (@"reading.listRankingScore = %f", [userFetched[@"listRankingScore"] floatValue]);
                              NSLog (@"reading.yesterdaysListRankingScore = %f", [userFetched[@"yesterdaysListRankingScore"] floatValue]);
                              NSLog (@"reading.moveGoal = %f", [userFetched[@"moveGoal"] floatValue]);
                              NSLog (@"reading.userObjectId = %@", [userFetched objectId]);
                              NSLog (@"usersFitnessData.usersFullName = %@", userFetched[@"full_name"]);
                              
                              //Add 'reading' to array
                              [newestFriendsFitnessDataArray addObject: usersFitnessData];
                              
                              
                              NSLog (@"[newestFriendsFitnessDataArray count] = %li", [newestFriendsFitnessDataArray count]);
                              NSLog (@"[objects count] = %li", [objects count]);
                              if ([newestFriendsFitnessDataArray count] == [objects count])
                              {
                                  //Make sure to reorder objects in both arrays so that the highest listRankingScores are on top
                                  NSSortDescriptor *sortDescriptor;
                                  sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listRankingScore" ascending:NO];
                                  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                                  NSArray *sortedArray;
                                  sortedArray = [newestFriendsFitnessDataArray sortedArrayUsingDescriptors:sortDescriptors];
                                  [newestFriendsFitnessDataArray removeAllObjects];
                                  [newestFriendsFitnessDataArray addObjectsFromArray: sortedArray];
                                  
                                  for (ArchivedReading *oldArrayObject in archivedReadingsArray)
                                  {
                                      NSLog (@"oldArrayObject = %f", oldArrayObject.listRankingScore);
                                      NSLog (@"oldArrayObject name: %@ converted time: %@, is NSDate Today: %i, moveGoal = %f", oldArrayObject.usersFullName, [self convertToGlobalTime:oldArrayObject.lastUpdated], [self isNSDateToday:oldArrayObject.lastUpdated], oldArrayObject.moveGoal);
                                  }
                                  for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
                                  {
                                      NSLog (@"newUserArray name: %@ converted time: %@, is NSDate Today: %i, moveGoal = %f", newArrayObject.usersFullName, [self convertToGlobalTime:newArrayObject.lastUpdated], [self isNSDateToday:newArrayObject.lastUpdated], newArrayObject.moveGoal);
                                  }
                                  
                                  //Call method here
                                  NSString *messageToSend = [self determineProperPushNotificationMessage: newestFriendsFitnessDataArray];
                                  
                                  //Schedule local notification using the above NSString
                                  UILocalNotification *notification = [[UILocalNotification alloc] init];
                                  notification.fireDate = dateArg;
                                  [notification setAlertBody:messageToSend];
                                  notification.soundName = UILocalNotificationDefaultSoundName;
                                  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                              }
                          }];
                     }
                 }];
            }
        }
    //}
}
*/
/*
//Overloaded method of the one above
-(void) sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg
{
    NSLog (@"sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg called!");
    
    NSLog (@"currentTimeFallsBetweenMidnightAnd3am = %i", [self currentTimeFallsBetweenMidnightAnd3am]);
    
    if (!([self currentTimeFallsBetweenMidnightAnd3am]))
    {
        //Grab archivedReadingsArray
        //If archivedReadingsArray is empty then just return nothing
        if ([archivedReadingsArray count] == 0)
        {
            NSLog (@"[archivedReadingsArray count] == 0 so returning out of sendAppropriateCompetitiveNotificationMessage");
            
            return;
        }
        else
        {
            NSMutableArray *newestFriendsFitnessDataArray = [[NSMutableArray alloc] init];
            //If archivedReadingsArray is full then run a query for all of your friends and their fitness stats and save it to another array
            //Query parse for all friend objects
            PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [query whereKey:@"saved_to_list" equalTo:@"Following"];
            [query whereKey:@"FriendStatus" equalTo: @"Friends"];
            [query orderByDescending:@"toUserListRankingScore"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 for (PFObject *activityObject in objects)
                 {
                     NSLog (@"number of friends in sendAppropriateCompetitiveNotificationMessage = %lu", (unsigned long)[objects count]);
                     
                     PFUser *userFetched = activityObject[@"toUser"];
                     [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                      {
                          NSLog (@"HealthMethods userFetched = %@", userFetched);
                          
                          ArchivedReading *usersFitnessData = [[ArchivedReading alloc] init];
                          usersFitnessData.listRankingScore = [userFetched[@"listRankingScore"] floatValue];
                          usersFitnessData.yesterdaysListRankingScore = [userFetched[@"yesterdaysListRankingScore"] floatValue];
                          usersFitnessData.lastUpdated = [userFetched updatedAt];
                          usersFitnessData.userObjectId = [userFetched objectId];
                          usersFitnessData.usersFullName = userFetched[@"full_name"];
                          
                          NSLog (@"reading.lastUpdated = %@", [userFetched updatedAt]);
                          NSLog (@"reading.listRankingScore = %f", [userFetched[@"listRankingScore"] floatValue]);
                          NSLog (@"reading.yesterdaysListRankingScore = %f", [userFetched[@"yesterdaysListRankingScore"] floatValue]);
                          NSLog (@"reading.userObjectId = %@", [userFetched objectId]);
                          NSLog (@"usersFitnessData.usersFullName = %@", userFetched[@"full_name"]);
                          
                          //Add 'reading' to array
                          [newestFriendsFitnessDataArray addObject: usersFitnessData];
                          
                          
                          NSLog (@"[newestFriendsFitnessDataArray count] = %li", [newestFriendsFitnessDataArray count]);
                          NSLog (@"[objects count] = %li", [objects count]);
                          if ([newestFriendsFitnessDataArray count] == [objects count])
                          {
                              //Make sure to reorder objects in both arrays so that the highest listRankingScores are on top
                              NSSortDescriptor *sortDescriptor;
                              sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listRankingScore" ascending:NO];
                              NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                              NSArray *sortedArray;
                              sortedArray = [newestFriendsFitnessDataArray sortedArrayUsingDescriptors:sortDescriptors];
                              [newestFriendsFitnessDataArray removeAllObjects];
                              [newestFriendsFitnessDataArray addObjectsFromArray: sortedArray];
                              
                              for (ArchivedReading *oldArrayObject in archivedReadingsArray)
                              {
                                  NSLog (@"oldArrayObject = %f", oldArrayObject.listRankingScore);
                                  NSLog (@"oldArrayObject name: %@ converted time: %@, is NSDate Today: %i", oldArrayObject.usersFullName, [self convertToGlobalTime:oldArrayObject.lastUpdated], [self isNSDateToday:oldArrayObject.lastUpdated]);
                              }
                              for (ArchivedReading *newArrayObject in newestFriendsFitnessDataArray)
                              {
                                  NSLog (@"newUserArray name: %@ converted time: %@, is NSDate Today: %i", newArrayObject.usersFullName, [self convertToGlobalTime:newArrayObject.lastUpdated], [self isNSDateToday:newArrayObject.lastUpdated]);
                              }
                              
                              NSLog (@"Scheduling notification in sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg");
                              
                              //Call method here
                              NSString *messageToSend = [self determineProperPushNotificationMessage: newestFriendsFitnessDataArray];
                              
                              NSLog (@"Scheduling notification within sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg for %@", dateArg);

                              
                              //Schedule local notification using the above NSString
                              UILocalNotification *notification = [[UILocalNotification alloc] init];
                              notification.fireDate = dateArg;
                              [notification setAlertBody:messageToSend];
                              notification.soundName = UILocalNotificationDefaultSoundName;
                              notification.repeatInterval = NSCalendarUnitDay;
                              [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                          }
                      }];
                 }
             }];
        }
    }
}
*/

-(void)zeroOutParseHealthStatsIfNilOrUnnecessaryForCalculation
{
    //Zero out Challenge stats for all days ahead of the current one
    
    if ([PFUser currentUser])
    {
        //Zero out all nil values that you access to keep the app from crashing
        //Today's
        if (![PFUser currentUser][@"NumberOfStepsToday"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsToday"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseToday"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseToday"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedToday"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedToday"];
        }
        
        //Yesterday's
        if (![PFUser currentUser][@"NumberOfStepsYesterday"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsYesterday"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseOneDayAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseOneDayAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedOneDayAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedOneDayAgo"];
        }
        
        //Two Day's Ago
        if (![PFUser currentUser][@"NumberOfStepsTwoDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsTwoDaysAgo"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseTwoDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseTwoDaysAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedTwoDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedTwoDaysAgo"];
        }
        //Three Day's Ago
        if (![PFUser currentUser][@"NumberOfStepsThreeDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsThreeDaysAgo"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseThreeDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseThreeDaysAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedThreeDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedThreeDaysAgo"];
        }
        //Four Day's Ago
        if (![PFUser currentUser][@"NumberOfStepsFourDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsFourDaysAgo"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseFourDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseFourDaysAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedFourDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedFourDaysAgo"];
        }
        //Five Day's Ago
        if (![PFUser currentUser][@"NumberOfStepsFiveDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsFiveDaysAgo"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseFiveDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseFiveDaysAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedFiveDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedFiveDaysAgo"];
        }
        //Six Day's Ago
        if (![PFUser currentUser][@"NumberOfStepsSixDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"NumberOfStepsSixDaysAgo"];
        }
        if (![PFUser currentUser][@"MinutesOfExerciseSixDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"MinutesOfExerciseSixDaysAgo"];
        }
        if (![PFUser currentUser][@"CaloriesBurnedSixDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"CaloriesBurnedSixDaysAgo"];
        }
        //List ranking scores
        if (![PFUser currentUser][@"listRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"listRankingScore"];
        }
        if (![PFUser currentUser][@"yesterdaysListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"yesterdaysListRankingScore"];
        }
        if (![PFUser currentUser][@"listRankingScoreTwoDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"listRankingScoreTwoDaysAgo"];
        }
        if (![PFUser currentUser][@"listRankingScoreThreeDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"listRankingScoreThreeDaysAgo"];
        }
        if (![PFUser currentUser][@"listRankingScoreFourDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"listRankingScoreFourDaysAgo"];
        }
        if (![PFUser currentUser][@"listRankingScoreFiveDaysAgo"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"listRankingScoreFiveDaysAgo"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay1ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay1ListRankingScore"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay2ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay2ListRankingScore"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay3ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay3ListRankingScore"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay4ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay4ListRankingScore"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay5ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay5ListRankingScore"];
        }
        
        if (![PFUser currentUser][@"ChallengeDay6ListRankingScore"])
        {
            NSNumber *zeroNSNumber = [NSNumber numberWithInteger:0];
            [[PFUser currentUser] setObject:zeroNSNumber forKey:@"ChallengeDay6ListRankingScore"];
        }
    }
}

//Return NumberOfSteps parse key
-(NSString*) numberOfStepsParseKeyForDayOfWeek: (int)dayOfWeekYouWantArg currentDayOfWeek:(int)currentDayOfWeekArg
{
    int differenceInt = currentDayOfWeekArg - dayOfWeekYouWantArg;
    
    if (differenceInt == 0)
    {
        return [NSString stringWithFormat:@"NumberOfStepsToday"];
    }
    else if (differenceInt == 1)
    {
        return [NSString stringWithFormat:@"NumberOfStepsYesterday"];
    }
    else if (differenceInt == 2)
    {
        return [NSString stringWithFormat:@"NumberOfStepsTwoDaysAgo"];
    }
    else if (differenceInt == 3)
    {
        return [NSString stringWithFormat:@"NumberOfStepsThreeDaysAgo"];
    }
    else if (differenceInt == 4)
    {
        return [NSString stringWithFormat:@"NumberOfStepsFourDaysAgo"];
    }
    else if (differenceInt == 5)
    {
        return [NSString stringWithFormat:@"NumberOfStepsFiveDaysAgo"];
    }
    else if (differenceInt == 6)
    {
        return [NSString stringWithFormat:@"NumberOfStepsSixDaysAgo"];
    }
    
    return 0;
}

//Return ExerciseMInutes Parse Key
-(NSString*) minutesOfExerciseParseKeyForDayOfWeek: (int)dayOfWeekYouWantArg currentDayOfWeek:(int)currentDayOfWeekArg
{
    int differenceInt = currentDayOfWeekArg - dayOfWeekYouWantArg;
    
    if (differenceInt == 0)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseToday"];
    }
    else if (differenceInt == 1)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseOneDayAgo"];
    }
    else if (differenceInt == 2)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseTwoDaysAgo"];
    }
    else if (differenceInt == 3)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseThreeDaysAgo"];
    }
    else if (differenceInt == 4)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseFourDaysAgo"];
    }
    else if (differenceInt == 5)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseFiveDaysAgo"];
    }
    else if (differenceInt == 6)
    {
        return [NSString stringWithFormat:@"MinutesOfExerciseSixDaysAgo"];
    }
    
    return 0;
}

//Return CaloriesBurned Parse Key
-(NSString*) caloriesBurnedParseKeyForDayOfWeek: (int)dayOfWeekYouWantArg currentDayOfWeek:(int)currentDayOfWeekArg
{
    int differenceInt = currentDayOfWeekArg - dayOfWeekYouWantArg;
    
    if (differenceInt == 0)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedToday"];
    }
    else if (differenceInt == 1)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedOneDayAgo"];
    }
    else if (differenceInt == 2)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedTwoDaysAgo"];
    }
    else if (differenceInt == 3)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedThreeDaysAgo"];
    }
    else if (differenceInt == 4)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedFourDaysAgo"];
    }
    else if (differenceInt == 5)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedFiveDaysAgo"];
    }
    else if (differenceInt == 6)
    {
        return [NSString stringWithFormat:@"CaloriesBurnedSixDaysAgo"];
    }
    
    return 0;
}

//Return listRankingScore Parse Key
-(NSString*) listRankingScoreParseKeyForDayOfWeek: (int)dayOfWeekYouWantArg currentDayOfWeek:(int)currentDayOfWeekArg
{
    int differenceInt = currentDayOfWeekArg - dayOfWeekYouWantArg;
    
    if (differenceInt == 0)
    {
        return [NSString stringWithFormat:@"listRankingScore"];
    }
    else if (differenceInt == 1)
    {
        return [NSString stringWithFormat:@"yesterdaysListRankingScore"];
    }
    else if (differenceInt == 2)
    {
        return [NSString stringWithFormat:@"listRankingScoreTwoDaysAgo"];
    }
    else if (differenceInt == 3)
    {
        return [NSString stringWithFormat:@"listRankingScoreThreeDaysAgo"];
    }
    else if (differenceInt == 4)
    {
        return [NSString stringWithFormat:@"listRankingScoreFourDaysAgo"];
    }
    else if (differenceInt == 5)
    {
        return [NSString stringWithFormat:@"listRankingScoreFiveDaysAgo"];
    }
    else if (differenceInt == 6)
    {
        return [NSString stringWithFormat:@"listRankingScoreSixDaysAgo"];
    }
    
    return 0;
}

//Return listRankingScore Parse Key
-(NSString*) challengeStepsParseKeyForDayOfWeek: (int)dayOfWeekYouWantArg currentDayOfWeek:(int)currentDayOfWeekArg
{
    int differenceInt = currentDayOfWeekArg - dayOfWeekYouWantArg;
    
    if (differenceInt == 0)
    {
        return [NSString stringWithFormat:@"listRankingScore"];
    }
    else if (differenceInt == 1)
    {
        return [NSString stringWithFormat:@"yesterdaysListRankingScore"];
    }
    else if (differenceInt == 2)
    {
        return [NSString stringWithFormat:@"listRankingScoreTwoDaysAgo"];
    }
    else if (differenceInt == 3)
    {
        return [NSString stringWithFormat:@"listRankingScoreThreeDaysAgo"];
    }
    else if (differenceInt == 4)
    {
        return [NSString stringWithFormat:@"listRankingScoreFourDaysAgo"];
    }
    else if (differenceInt == 5)
    {
        return [NSString stringWithFormat:@"listRankingScoreFiveDaysAgo"];
    }
    else if (differenceInt == 6)
    {
        return [NSString stringWithFormat:@"listRankingScoreSixDaysAgo"];
    }
    
    return 0;
}

-(void) calculateRunningDailyAverageForChallenges: (MeViewController*)viewController completion:(void (^)(double, NSError *))completionHandler
{
    if ([PFUser currentUser])
    {
        NSLog (@"calculateRunningDailyAverageForChallenges called!");
        
        //Determine day of the week
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
        int dayOfTheWeek = (int)[comps weekday];
        
        //DEBUG:set to 6 to force friday calculation
        //dayOfTheWeek = 7;

        NSLog (@"dayOfTheWeek = %i", dayOfTheWeek);
        
        [self zeroOutParseHealthStatsIfNilOrUnnecessaryForCalculation];
        
        
        if (dayOfTheWeek == 1) //Sunday
        {
            //Calculate all of the last 6 day's ChallengeDay RankingScores
            dayOfTheWeek = 7;   //Set this to have it calculate all the days of the week
        }
        if (dayOfTheWeek >= 2) //Monday or Sunday
        {
            //First day of challenges so just save todays steps, minutes, and calories stats to like: ChallengeStepsDay1, ExerciseMinsDay2, CalsBurnedDay1
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay1"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay1"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay1"];
            
            
            //Save today's challenge's list ranking score to ChallengeDay1ListRankingScore
            NSNumber *challengeDay1ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay1" exerciseMinsParseKey:@"ChallengeExerciseMinsDay1" calsBurnedParseKey:@"ChallengeCalsBurnedDay1"]];
            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay1ListRankingScore"];
            
            //Copy steps, exericse minutes, calories burned, and challengeDayListRankingScore to all future days to avoid having people show up as 0's if they haven't updated that day. Only winners who have updated since Sunday will be counted
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay2"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay3"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay4"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay5"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeStepsDay6"];
            
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay2"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay3"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay4"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay5"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeExerciseMinsDay6"];
            
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay2"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay3"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay4"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay5"];
            [[PFUser currentUser] setObject:[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] forKey:@"ChallengeCalsBurnedDay6"];

            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay2ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay3ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay4ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay5ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay1ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
            
            [[PFUser currentUser] saveInBackground];
        }
        if (dayOfTheWeek >= 3) //Tuesday or Sunday
        {
            //Average today's stats and yesterday's stats:
            NSLog (@"Calculating Challenge averages for day 3");
            
            //Average steps value
            NSNumber *stepsTodayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int stepsTodayInt = [stepsTodayNSNumber integerValue];
            
            NSNumber *stepsYesterdayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int stepsYesterdayInt = [stepsYesterdayNSNumber integerValue];
            
            int stepsTwoDayAvgInt = 0;
            
            //Only average today and yesterdays out if todays is larger than yesterdays
            if (stepsTodayInt >= stepsYesterdayInt)
            {
                stepsTwoDayAvgInt = (int)(stepsTodayInt + stepsYesterdayInt)/2;
            }
            else
            {
                stepsTwoDayAvgInt = (int)(stepsYesterdayInt);
            }
            NSNumber *stepsTwoDayAvgNSNumber = [NSNumber numberWithInt:stepsTwoDayAvgInt];
            [[PFUser currentUser] setObject:stepsTwoDayAvgNSNumber forKey:@"ChallengeStepsDay2"];
            
            //Average exercise minutes value
            NSNumber *minOfExerciseTodayNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int minOfExerciseTodayInt = [minOfExerciseTodayNSNumber integerValue];
            
            NSNumber *minOfExerciseYesterdayNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int minOfExerciseYesterdayInt = [minOfExerciseYesterdayNSNumber integerValue];
            
            //Only average today and yesterdays out if todays is larger than yesterdays
            long int minOfExerciseTwoDayAvgInt = 0;
            if (minOfExerciseTodayInt >= minOfExerciseYesterdayInt)
            {
                minOfExerciseTwoDayAvgInt = (int)(minOfExerciseTodayInt + minOfExerciseYesterdayInt)/2;
            }
            else
            {
                minOfExerciseTwoDayAvgInt = minOfExerciseYesterdayInt;
            }
            NSNumber *exerciseMinsTwoDayAvgNSNumber = [NSNumber numberWithInteger:minOfExerciseTwoDayAvgInt];
            [[PFUser currentUser] setObject:exerciseMinsTwoDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay2"];
            
            //Average cals burned value
            NSNumber *calsBurnedTodayNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedTodayInt = [calsBurnedTodayNSNumber integerValue];
            
            NSNumber *calsBurnedYesterdayNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedYesterdayInt = [calsBurnedYesterdayNSNumber integerValue];
            
            long int calsBurnedTwoDayAvgInt = 0;
            if (calsBurnedTodayInt >= calsBurnedYesterdayInt)
            {
                calsBurnedTwoDayAvgInt = (int)(calsBurnedTodayInt + calsBurnedYesterdayInt)/2;
            }
            else
            {
                calsBurnedTwoDayAvgInt = calsBurnedYesterdayInt;
            }
            NSLog (@"calsBurnedTwoDayAvgInt = %li", calsBurnedTwoDayAvgInt);
            NSNumber *calsBurnedTwoDayAvgNSNumber = [NSNumber numberWithInteger:calsBurnedTwoDayAvgInt];
            [[PFUser currentUser] setObject:calsBurnedTwoDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay2"];
            
            
            //Save today's challenge's list ranking score to ChallengeDay2ListRankingScore
            NSNumber *challengeDay2ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay2" exerciseMinsParseKey:@"ChallengeExerciseMinsDay2" calsBurnedParseKey:@"ChallengeCalsBurnedDay2"]];
            [[PFUser currentUser] setObject:challengeDay2ListRankingScore forKey:@"ChallengeDay2ListRankingScore"];
            
            //Copy steps, exericse minutes, calories burned, and challengeDayListRankingScore to all future days to avoid having people show up as 0's if they haven't updated that day. Only winners who have updated since Sunday will be counted
            [[PFUser currentUser] setObject:stepsTwoDayAvgNSNumber forKey:@"ChallengeStepsDay3"];
            [[PFUser currentUser] setObject:stepsTwoDayAvgNSNumber forKey:@"ChallengeStepsDay4"];
            [[PFUser currentUser] setObject:stepsTwoDayAvgNSNumber forKey:@"ChallengeStepsDay5"];
            [[PFUser currentUser] setObject:stepsTwoDayAvgNSNumber forKey:@"ChallengeStepsDay6"];
            
            [[PFUser currentUser] setObject:exerciseMinsTwoDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay3"];
            [[PFUser currentUser] setObject:exerciseMinsTwoDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay4"];
            [[PFUser currentUser] setObject:exerciseMinsTwoDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay5"];
            [[PFUser currentUser] setObject:exerciseMinsTwoDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay6"];
            
            [[PFUser currentUser] setObject:calsBurnedTwoDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay3"];
            [[PFUser currentUser] setObject:calsBurnedTwoDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay4"];
            [[PFUser currentUser] setObject:calsBurnedTwoDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay5"];
            [[PFUser currentUser] setObject:calsBurnedTwoDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay6"];
            
            [[PFUser currentUser] setObject:challengeDay2ListRankingScore forKey:@"ChallengeDay3ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay2ListRankingScore forKey:@"ChallengeDay4ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay2ListRankingScore forKey:@"ChallengeDay5ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay2ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
            
            [[PFUser currentUser] saveInBackground];
        }
        if (dayOfTheWeek >= 4) //Wednesday or Sunday
        {
            //Average today and last 2 days stats:
            
            //Average step stats from yesterday and day before that
            NSNumber *stepsYesterdayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int stepsYesterdayInt = [stepsYesterdayNSNumber integerValue];
            
            NSNumber *stepsTwoDaysAgoNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int stepsTwoDaysAgoInt = [stepsTwoDaysAgoNSNumber integerValue];
            
            long int challengeStepsDay2Int = (int)(stepsYesterdayInt + stepsTwoDaysAgoInt)/2;
            NSNumber *challengeStepsDay2NSNumber = [NSNumber numberWithInteger:challengeStepsDay2Int];
            [[PFUser currentUser] setObject:challengeStepsDay2NSNumber forKey:@"ChallengeStepsDay2"];
            
            //Get today's step count
            NSNumber *stepsTodayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int stepsTodayInt = [stepsTodayNSNumber integerValue];
            NSLog (@"challengeStepsDay2Int = %li, stepsTodayInt = %li", challengeStepsDay2Int, stepsTodayInt);
            //Only average today with the last two days if todays is larger than the average of the last two days
            long int stepsThreeDayAvgInt = 0;
            if (stepsTodayInt >= challengeStepsDay2Int)
            {
                stepsThreeDayAvgInt = (int)(stepsTodayInt + stepsYesterdayInt + stepsTwoDaysAgoInt)/3;
            }
            else
            {
                stepsThreeDayAvgInt = challengeStepsDay2Int;
            }
            //Save 3 day step count average to parse
            NSNumber *stepsThreeDayAvgNSNumber = [NSNumber numberWithInteger:stepsThreeDayAvgInt];
            [[PFUser currentUser] setObject:stepsThreeDayAvgNSNumber forKey:@"ChallengeStepsDay3"];

            //Average exercise minutes from yesterday and day before that
            NSNumber *minOfExerciseOneDayAgoNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int minOfExerciseOneDayAgoInt = [minOfExerciseOneDayAgoNSNumber integerValue];
            NSNumber *minOfExerciseTwoDaysAgoNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int minOfExerciseTwoDaysAgoInt = [minOfExerciseTwoDaysAgoNSNumber integerValue];
            //Get the avg between yesterday and two days ago
            long int challengeExerciseMinsDay2Int = (minOfExerciseOneDayAgoInt + minOfExerciseTwoDaysAgoInt)/2;
            NSNumber *challengeExerciseMinsDay2NSNumber = [NSNumber numberWithInteger:challengeExerciseMinsDay2Int];
            [[PFUser currentUser] setObject:challengeExerciseMinsDay2NSNumber forKey:@"ChallengeExerciseMinsDay2"];
            
            //Get today's exercise minute count
            NSNumber *exerciseMinsTodayNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int exerciseMinsTodayInt = [exerciseMinsTodayNSNumber integerValue];
            
            //Only average today with the last two days if todays is larger than the average of the last two days
            long int exerciseMinsThreeDayAvgInt = 0;
            if (exerciseMinsTodayInt >= challengeExerciseMinsDay2Int)
            {
                exerciseMinsThreeDayAvgInt = (int)(exerciseMinsTodayInt + minOfExerciseOneDayAgoInt + minOfExerciseTwoDaysAgoInt)/3;
            }
            else
            {
                exerciseMinsThreeDayAvgInt = challengeExerciseMinsDay2Int;
            }
            NSNumber *exerciseMinsThreeDayAvgNSNumber = [NSNumber numberWithInteger:exerciseMinsThreeDayAvgInt];
            [[PFUser currentUser] setObject:exerciseMinsThreeDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay3"];

            //Get the average cal burn stats from yesterday and two days before that
            NSNumber *calsBurnedOneDayAgoNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedOneDayAgoInt = [calsBurnedOneDayAgoNSNumber integerValue];
            NSNumber *calsBurnedTwoDaysAgoNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedTwoDaysAgoInt = [calsBurnedTwoDaysAgoNSNumber integerValue];
            //Get the avg between yesterday and two days ago
            long int challengeCalsBurnedDay2Int = (calsBurnedOneDayAgoInt + calsBurnedTwoDaysAgoInt)/2;
            NSNumber *challengeCalsBurnedDay2NSNumber = [NSNumber numberWithInteger:challengeCalsBurnedDay2Int];
            [[PFUser currentUser] setObject:challengeCalsBurnedDay2NSNumber forKey:@"ChallengeCalsBurnedDay2"];

            //Get today's cals burned
            NSNumber *calsBurnedTodayNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedTodayInt = [calsBurnedTodayNSNumber integerValue];
            
            //Only average today with the last two days if todays is larger than the average of the last two days
            long int calsBurnedThreeDayAvgInt = 0;
            if (calsBurnedTodayInt >= challengeCalsBurnedDay2Int)
            {
                calsBurnedThreeDayAvgInt = (calsBurnedTodayInt + calsBurnedOneDayAgoInt + calsBurnedTwoDaysAgoInt)/3;
            }
            else
            {
                calsBurnedThreeDayAvgInt = challengeCalsBurnedDay2Int;
            }
            NSNumber *calsBurnedThreeDayAvgNSNumber = [NSNumber numberWithInteger:calsBurnedThreeDayAvgInt];
            [[PFUser currentUser] setObject:calsBurnedThreeDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay3"];
            
            //Save today's challenge's list ranking score to ChallengeDay3ListRankingScore
            NSNumber *challengeDay3ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay3" exerciseMinsParseKey:@"ChallengeExerciseMinsDay3" calsBurnedParseKey:@"ChallengeCalsBurnedDay3"]];
            [[PFUser currentUser] setObject:challengeDay3ListRankingScore forKey:@"ChallengeDay3ListRankingScore"];
            
            //Copy steps, exericse minutes, calories burned, and challengeDayListRankingScore to all future days to avoid having people show up as 0's if they haven't updated that day. Only winners who have updated since Sunday will be counted
            [[PFUser currentUser] setObject:stepsThreeDayAvgNSNumber forKey:@"ChallengeStepsDay4"];
            [[PFUser currentUser] setObject:stepsThreeDayAvgNSNumber forKey:@"ChallengeStepsDay5"];
            [[PFUser currentUser] setObject:stepsThreeDayAvgNSNumber forKey:@"ChallengeStepsDay6"];
            
            [[PFUser currentUser] setObject:exerciseMinsThreeDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay4"];
            [[PFUser currentUser] setObject:exerciseMinsThreeDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay5"];
            [[PFUser currentUser] setObject:exerciseMinsThreeDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay6"];
            
            [[PFUser currentUser] setObject:calsBurnedThreeDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay4"];
            [[PFUser currentUser] setObject:calsBurnedThreeDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay5"];
            [[PFUser currentUser] setObject:calsBurnedThreeDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay6"];
            
            [[PFUser currentUser] setObject:challengeDay3ListRankingScore forKey:@"ChallengeDay4ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay3ListRankingScore forKey:@"ChallengeDay5ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay3ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
            
            [[PFUser currentUser] saveInBackground];
        }
        if (dayOfTheWeek >= 5) //Thursday or Sunday
        {
            //Average today and last 3 days stats:
            
            //Average step stats from yesterday, two days ago, and three days ago
            NSNumber *stepsYesterdayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int stepsYesterdayInt = [stepsYesterdayNSNumber integerValue];
            NSNumber *stepsTwoDaysAgoNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int stepsTwoDaysAgoInt = [stepsTwoDaysAgoNSNumber integerValue];
            NSNumber *stepsThreeDaysAgoNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int stepsThreeDaysAgoInt = [stepsThreeDaysAgoNSNumber integerValue];
            long int challengeStepsDay3Int = (stepsYesterdayInt + stepsTwoDaysAgoInt + stepsThreeDaysAgoInt)/3;
            
            //Get today's step count
            NSNumber *stepsTodayNSNumber = [PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]];
            long int stepsTodayInt = [stepsTodayNSNumber integerValue];

            long int stepsFourDayAvgInt = 0;
            //Only add todays step count to the going average if its larger than the last 3 day avg
            if (stepsTodayInt >= challengeStepsDay3Int)
            {
                stepsFourDayAvgInt = (stepsTodayInt + stepsYesterdayInt + stepsTwoDaysAgoInt + stepsThreeDaysAgoInt)/4;
            }
            else
            {
                stepsFourDayAvgInt = challengeStepsDay3Int;
            }
            //Save 4 day step count average to parse
            NSNumber *stepsFourDayAvgNSNumber = [NSNumber numberWithInteger:stepsFourDayAvgInt];
            [[PFUser currentUser] setObject:stepsFourDayAvgNSNumber forKey:@"ChallengeStepsDay4"];
        
            //Get the average exercise min stats from yesterday, two days ago, and three days ago
            NSNumber *exerciseMinsYesterdayNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int exerciseMinsYesterdayInt = [exerciseMinsYesterdayNSNumber integerValue];
            NSNumber *exerciseMinsTwoDaysAgoNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int exerciseMinsTwoDaysAgoInt = [exerciseMinsTwoDaysAgoNSNumber integerValue];
            NSNumber *exerciseMinsThreeDaysAgoNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int exerciseMinsThreeDaysAgoInt = [exerciseMinsThreeDaysAgoNSNumber integerValue];
            long int challengeExerciseMinsDay3Int = (exerciseMinsYesterdayInt + exerciseMinsTwoDaysAgoInt + exerciseMinsThreeDaysAgoInt)/3;
            
            //Get today's exercise minute count
            NSNumber *exerciseMinsTodayNSNumber = [PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]];
            long int exerciseMinsTodayInt = [exerciseMinsTodayNSNumber integerValue];
            
            //Only add todays step count to the going average if its larger than the last 3 day avg
            long int exerciseMinsFourDayAvgInt = 0;
            if (exerciseMinsTodayInt >= challengeExerciseMinsDay3Int)
            {
                exerciseMinsFourDayAvgInt = (exerciseMinsTodayInt + exerciseMinsYesterdayInt + exerciseMinsTwoDaysAgoInt + exerciseMinsThreeDaysAgoInt)/4;
            }
            else
            {
                exerciseMinsFourDayAvgInt = challengeExerciseMinsDay3Int;
            }
            NSNumber *exerciseMinsFourDayAvgNSNumber = [NSNumber numberWithInteger:exerciseMinsFourDayAvgInt];
            [[PFUser currentUser] setObject:exerciseMinsFourDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay4"];
            
            
            //Get the average cal burn stats from yesterday and three days before that
            NSNumber *calsBurnedOneDayAgoNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedOneDayAgoInt = [calsBurnedOneDayAgoNSNumber integerValue];
            NSNumber *calsBurnedTwoDaysAgoNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedTwoDaysAgoInt = [calsBurnedTwoDaysAgoNSNumber integerValue];
            NSNumber *calsBurnedThreeDaysAgoNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedThreeDaysAgoInt = [calsBurnedThreeDaysAgoNSNumber integerValue];
            long int challengeCalsBurnedDay3Int = (calsBurnedOneDayAgoInt + calsBurnedTwoDaysAgoInt + calsBurnedThreeDaysAgoInt)/3;
            
            NSNumber *calsBurnedTodayNSNumber = [PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]];
            long int calsBurnedTodayInt = [calsBurnedTodayNSNumber integerValue];
            
            //Only add todays cals burned to the going average if its larger than the last 3 day avg
            long int calsBurnedFourDayAvgInt = 0;
            if (calsBurnedTodayInt >= challengeCalsBurnedDay3Int)
            {
                calsBurnedFourDayAvgInt = (calsBurnedTodayInt + calsBurnedOneDayAgoInt + calsBurnedTwoDaysAgoInt + calsBurnedThreeDaysAgoInt)/4;
            }
            else
            {
                calsBurnedFourDayAvgInt = challengeCalsBurnedDay3Int;
            }
            
            NSNumber *calsBurnedFourDayAvgNSNumber = [NSNumber numberWithInteger:calsBurnedFourDayAvgInt];
            [[PFUser currentUser] setObject:calsBurnedFourDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay4"];
            
            //Save today's challenge's list ranking score to ChallengeDay4ListRankingScore
            NSNumber *challengeDay4ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay4" exerciseMinsParseKey:@"ChallengeExerciseMinsDay4" calsBurnedParseKey:@"ChallengeCalsBurnedDay4"]];
            [[PFUser currentUser] setObject:challengeDay4ListRankingScore forKey:@"ChallengeDay4ListRankingScore"];
            
            //Copy steps, exericse minutes, calories burned, and challengeDayListRankingScore to all future days to avoid having people show up as 0's if they haven't updated that day. Only winners who have updated since Sunday will be counted
            [[PFUser currentUser] setObject:stepsFourDayAvgNSNumber forKey:@"ChallengeStepsDay5"];
            [[PFUser currentUser] setObject:stepsFourDayAvgNSNumber forKey:@"ChallengeStepsDay6"];
            
            [[PFUser currentUser] setObject:exerciseMinsFourDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay5"];
            [[PFUser currentUser] setObject:exerciseMinsFourDayAvgNSNumber forKey:@"ChallengeExerciseMinsDay6"];
            
            [[PFUser currentUser] setObject:calsBurnedFourDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay5"];
            [[PFUser currentUser] setObject:calsBurnedFourDayAvgNSNumber forKey:@"ChallengeCalsBurnedDay6"];
            
            [[PFUser currentUser] setObject:challengeDay4ListRankingScore forKey:@"ChallengeDay5ListRankingScore"];
            [[PFUser currentUser] setObject:challengeDay4ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
            
            [[PFUser currentUser] saveInBackground];
        }
        if (dayOfTheWeek >= 6) //Friday or Sunday
        {
            //Grab the top 4 performing days between M-F and average those out
            
            //Grab Todays and previous 4 days listRankingScores, get them as NSNumbers
            NSNumber *listRankingScoreTodayNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreOneDayAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreTwoDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreThreeDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreFourDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];

            //Put them in an array
            NSMutableArray *listRankingScoreUnorderedArray = [[NSMutableArray alloc] init];
            [listRankingScoreUnorderedArray addObject:listRankingScoreTodayNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreOneDayAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreTwoDaysAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreThreeDaysAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreFourDaysAgoNSNumber];

            NSLog (@"listRankingScoreArray BEFORE arranging");
            for (NSNumber *number in listRankingScoreUnorderedArray)
            {
                NSLog (@"listRankingScore object value = %f", [number floatValue]);
            }
            
            //Copy unordered array to another array
            NSMutableArray *listRankingScoreOrderedArray = [[NSMutableArray alloc] init];
            [listRankingScoreOrderedArray addObjectsFromArray:listRankingScoreUnorderedArray];
            
            //Arrange by largest on top
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [listRankingScoreOrderedArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            
            NSLog (@"listRankingScoreArray AFTER arranging");
            for (NSNumber *number in listRankingScoreOrderedArray)
            {
                NSLog (@"listRankingScore object value = %f", [number floatValue]);
            }
            
            NSMutableArray *dayNumberForHighestListRankingScoreHighestToLowestArray = [[NSMutableArray alloc] init];
            
            //For the top 4 listRankingScores, take the value and see which day it equates with
            for (NSNumber *numberFromOrdered in listRankingScoreOrderedArray)
            {
                for (NSNumber *numberFromUnordered in listRankingScoreUnorderedArray)
                {
                    if ([numberFromOrdered floatValue] == [numberFromUnordered floatValue])
                    {
                        NSLog (@"[numberFromOrdered floatValue] = %f, [numberFromUnordered floatValue] = %f", [numberFromOrdered floatValue], [numberFromUnordered floatValue]);
                        
                        NSNumber *dayValueNSNumber = [NSNumber numberWithInteger:[listRankingScoreUnorderedArray indexOfObject:numberFromUnordered]];
                        [dayNumberForHighestListRankingScoreHighestToLowestArray addObject:dayValueNSNumber];
                    }
                }
            }
            
            NSLog (@"dayNumberForHighestListRankingScoreHighestToLowestArray order");
            for (NSNumber *number in dayNumberForHighestListRankingScoreHighestToLowestArray)
            {
                NSLog (@"dayNumberForHighestListRankingScoreHighestToLowest object value = %ld", (long)[number integerValue]);
            }
            
            long int numOfSteps4DayAvg = 0;
            long int exerciseMins4DayAvg = 0;
            long int calsBurned4DayAvg = 0;
            
            //Grab the stats from the 4 best fitness days between today and the last 4 days
            for (int i = 0; i < [dayNumberForHighestListRankingScoreHighestToLowestArray count] - 1; i++)
            {
                NSNumber *dayNumber = [dayNumberForHighestListRankingScoreHighestToLowestArray objectAtIndex: i];
                
                if ([dayNumber integerValue] == 0)
                {
                    numOfSteps4DayAvg = numOfSteps4DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins4DayAvg = exerciseMins4DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned4DayAvg = calsBurned4DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 1)
                {
                    numOfSteps4DayAvg = numOfSteps4DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins4DayAvg = exerciseMins4DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned4DayAvg = calsBurned4DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 2)
                {
                    numOfSteps4DayAvg = numOfSteps4DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins4DayAvg = exerciseMins4DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned4DayAvg = calsBurned4DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 3)
                {
                    numOfSteps4DayAvg = numOfSteps4DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins4DayAvg = exerciseMins4DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned4DayAvg = calsBurned4DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 4)
                {
                    numOfSteps4DayAvg = numOfSteps4DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins4DayAvg = exerciseMins4DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned4DayAvg = calsBurned4DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                
                NSLog (@"numOfSteps4DayAvg = %li", numOfSteps4DayAvg);
            }
            
            //Divide the running steps, exericse minutes, and cals burned total by 4
            numOfSteps4DayAvg = numOfSteps4DayAvg/4;
            exerciseMins4DayAvg = exerciseMins4DayAvg/4;
            calsBurned4DayAvg = calsBurned4DayAvg/4;
            
            //convert to NSNumbers
            NSNumber *numOfSteps4DayAvgNSNumber = [NSNumber numberWithInteger:numOfSteps4DayAvg];
            NSNumber *exerciseMins4DayAvgNSNumber = [NSNumber numberWithInteger:exerciseMins4DayAvg];
            NSNumber *calsBurned4DayAvgNSNumber = [NSNumber numberWithInteger:calsBurned4DayAvg];
            
            //Save the average steps, exericse minutes, and cals burned to Parse as the 'ChallengeDays' stats for each respective stat
            [[PFUser currentUser] setObject:numOfSteps4DayAvgNSNumber forKey:@"ChallengeStepsDay5"];
            [[PFUser currentUser] setObject:exerciseMins4DayAvgNSNumber forKey:@"ChallengeExerciseMinsDay5"];
            [[PFUser currentUser] setObject:calsBurned4DayAvgNSNumber forKey:@"ChallengeCalsBurnedDay5"];
            
            NSLog (@"ChallengeStepsDay5 = %li", [[PFUser currentUser][@"ChallengeStepsDay5"] integerValue]);
            NSLog (@"ChallengeExerciseMinsDay5 = %li", [[PFUser currentUser][@"ChallengeExerciseMinsDay5"] integerValue]);
            NSLog (@"ChallengeCalsBurnedDay5 = %li", [[PFUser currentUser][@"ChallengeCalsBurnedDay5"] integerValue]);
            
            //Save today's challenge's list ranking score to ChallengeDay5ListRankingScore
            NSNumber *challengeDay5ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay5" exerciseMinsParseKey:@"ChallengeExerciseMinsDay5" calsBurnedParseKey:@"ChallengeCalsBurnedDay5"]];
            [[PFUser currentUser] setObject:challengeDay5ListRankingScore forKey:@"ChallengeDay5ListRankingScore"];

            //Copy steps, exericse minutes, calories burned, and challengeDayListRankingScore to all future days to avoid having people show up as 0's if they haven't updated that day. Only winners who have updated since Sunday will be counted
            [[PFUser currentUser] setObject:numOfSteps4DayAvgNSNumber forKey:@"ChallengeStepsDay6"];
            
            [[PFUser currentUser] setObject:exerciseMins4DayAvgNSNumber forKey:@"ChallengeExerciseMinsDay6"];
            
            [[PFUser currentUser] setObject:calsBurned4DayAvgNSNumber forKey:@"ChallengeCalsBurnedDay6"];
            
            [[PFUser currentUser] setObject:challengeDay5ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
            
            [[PFUser currentUser] saveInBackground];
        }
        else if (dayOfTheWeek == 7) //Saturday or Sunday
        {
            //Grab the top 4 performing days between M-Sat and average those out
            
            //Grab Todays and previous 5 days listRankingScores, get them as NSNumbers
            NSNumber *listRankingScoreTodayNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:7 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreOneDayAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreTwoDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreThreeDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreFourDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]];
            NSNumber *listRankingScoreFiveDaysAgoNSNumber = [PFUser currentUser][[self listRankingScoreParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]];
            
            //Put them in an array
            NSMutableArray *listRankingScoreUnorderedArray = [[NSMutableArray alloc] init];
            [listRankingScoreUnorderedArray addObject:listRankingScoreTodayNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreOneDayAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreTwoDaysAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreThreeDaysAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreFourDaysAgoNSNumber];
            [listRankingScoreUnorderedArray addObject:listRankingScoreFiveDaysAgoNSNumber];
            
            NSLog (@"listRankingScoreArray BEFORE arranging");
            for (NSNumber *number in listRankingScoreUnorderedArray)
            {
                NSLog (@"listRankingScore object value = %f", [number floatValue]);
            }
            
            //Copy unordered array to another array
            NSMutableArray *listRankingScoreOrderedArray = [[NSMutableArray alloc] init];
            [listRankingScoreOrderedArray addObjectsFromArray:listRankingScoreUnorderedArray];
            
            //Arrange by largest on top
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [listRankingScoreOrderedArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            
            NSLog (@"listRankingScoreArray AFTER arranging");
            for (NSNumber *number in listRankingScoreOrderedArray)
            {
                NSLog (@"listRankingScore object value = %f", [number floatValue]);
            }
            
            NSMutableArray *dayNumberForHighestListRankingScoreHighestToLowestArray = [[NSMutableArray alloc] init];
            
            //For the top 4 listRankingScores, take the value and see which day it equates with
            for (NSNumber *numberFromOrdered in listRankingScoreOrderedArray)
            {
                for (NSNumber *numberFromUnordered in listRankingScoreUnorderedArray)
                {
                    if ([numberFromOrdered floatValue] == [numberFromUnordered floatValue])
                    {
                        NSLog (@"[numberFromOrdered floatValue] = %f, [numberFromUnordered floatValue] = %f", [numberFromOrdered floatValue], [numberFromUnordered floatValue]);
                        
                        NSNumber *dayValueNSNumber = [NSNumber numberWithInteger:[listRankingScoreUnorderedArray indexOfObject:numberFromUnordered]];
                        [dayNumberForHighestListRankingScoreHighestToLowestArray addObject:dayValueNSNumber];
                    }
                }
            }
            
            NSLog (@"dayNumberForHighestListRankingScoreHighestToLowestArray order");
            for (NSNumber *number in dayNumberForHighestListRankingScoreHighestToLowestArray)
            {
                NSLog (@"dayNumberForHighestListRankingScoreHighestToLowest object value = %ld", (long)[number integerValue]);
            }
            
            long int numOfSteps5DayAvg = 0;
            long int exerciseMins5DayAvg = 0;
            long int calsBurned5DayAvg = 0;
            
            //Grab the stats from the 4 best fitness days between today and the last 4 days
            for (int i = 0; i < [dayNumberForHighestListRankingScoreHighestToLowestArray count] - 2; i++)
            {
                NSNumber *dayNumber = [dayNumberForHighestListRankingScoreHighestToLowestArray objectAtIndex: i];

                if ([dayNumber integerValue] == 0)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:7 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:7 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:7 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 1)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:6 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 2)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:5 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 3)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:4 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 4)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:3 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
                else if ([dayNumber integerValue] == 5)
                {
                    numOfSteps5DayAvg = numOfSteps5DayAvg + [[PFUser currentUser][[self numberOfStepsParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    exerciseMins5DayAvg = exerciseMins5DayAvg + [[PFUser currentUser][[self minutesOfExerciseParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                    calsBurned5DayAvg = calsBurned5DayAvg + [[PFUser currentUser][[self caloriesBurnedParseKeyForDayOfWeek:2 currentDayOfWeek:dayOfTheWeek]] integerValue];
                }
            }
            
            //Divide the running steps, exericse minutes, and cals burned total by 4
            numOfSteps5DayAvg = numOfSteps5DayAvg/4;
            exerciseMins5DayAvg = exerciseMins5DayAvg/4;
            calsBurned5DayAvg = calsBurned5DayAvg/4;
            
            //convert to NSNumbers
            NSNumber *numOfSteps5DayAvgNSNumber = [NSNumber numberWithInteger:numOfSteps5DayAvg];
            NSNumber *exerciseMins5DayAvgNSNumber = [NSNumber numberWithInteger:exerciseMins5DayAvg];
            NSNumber *calsBurned5DayAvgNSNumber = [NSNumber numberWithInteger:calsBurned5DayAvg];
            
            //Save the average steps, exericse minutes, and cals burned to Parse as the 'ChallengeDays' stats for each respective stat
            [[PFUser currentUser] setObject:numOfSteps5DayAvgNSNumber forKey:@"ChallengeStepsDay6"];
            [[PFUser currentUser] setObject:exerciseMins5DayAvgNSNumber forKey:@"ChallengeExerciseMinsDay6"];
            [[PFUser currentUser] setObject:calsBurned5DayAvgNSNumber forKey:@"ChallengeCalsBurnedDay6"];
            
            NSLog (@"ChallengeStepsDay6 = %li", [[PFUser currentUser][@"ChallengeStepsDay6"] integerValue]);
            NSLog (@"ChallengeExerciseMinsDay6 = %li", [[PFUser currentUser][@"ChallengeExerciseMinsDay6"] integerValue]);
            NSLog (@"ChallengeCalsBurnedDay6 = %li", [[PFUser currentUser][@"ChallengeCalsBurnedDay6"] integerValue]);
            
            //Save today's challenge's list ranking score to ChallengeDay6ListRankingScore
            NSNumber *challengeDay6ListRankingScore = [NSNumber numberWithFloat: [self challengeListRankingScore:@"ChallengeStepsDay6" exerciseMinsParseKey:@"ChallengeExerciseMinsDay6" calsBurnedParseKey:@"ChallengeCalsBurnedDay6"]];
            [[PFUser currentUser] setObject:challengeDay6ListRankingScore forKey:@"ChallengeDay6ListRankingScore"];
        }
        
        NSArray *facebookFriendsObjectIdsNSArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookFriendsObjectIdsArray"];
        NSMutableArray *facebookFriendsObjectIdsMutableArray = [[NSMutableArray alloc] init];
        [facebookFriendsObjectIdsMutableArray addObjectsFromArray:facebookFriendsObjectIdsNSArray];
        
        //Add your objectId to the array so it shows up on the Friends Challenge list
        NSString *yourObjectId = (NSString*)[PFUser currentUser].objectId;
        [facebookFriendsObjectIdsMutableArray addObject:yourObjectId];
        
        NSLog (@"facebookFriendsObjectIdsArray count = %li", [facebookFriendsObjectIdsMutableArray count]);
        
        for (NSString *objectId in facebookFriendsObjectIdsMutableArray)
        {
            NSLog (@"facebookFriendObjectId = %@", objectId);
        }
        
        PFQuery *query;
        //Show friends only since we're removing the segment control
        query = [PFUser query];
        [query whereKeyExists:@"NumberOfStepsToday"];
        [query whereKey:@"objectId" containedIn:facebookFriendsObjectIdsMutableArray];
        
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
        
        ChallengesViewController *challengesViewSubClass = [[ChallengesViewController alloc] init];

        NSString *challengeDayListRankingScoreString = @"ChallengeDay1ListRankingScore";
        
        if ([challengesViewSubClass dayOfTheWeek] == 1)
        {
            challengeDayListRankingScoreString = @"ChallengeDay1ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        else if ([challengesViewSubClass dayOfTheWeek] == 2)
        {
            challengeDayListRankingScoreString = @"ChallengeDay2ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        else if ([challengesViewSubClass dayOfTheWeek] == 3)
        {
            challengeDayListRankingScoreString = @"ChallengeDay3ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        else if ([challengesViewSubClass dayOfTheWeek] == 4)
        {
            challengeDayListRankingScoreString = @"ChallengeDay4ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        else if ([challengesViewSubClass dayOfTheWeek] == 5)
        {
            challengeDayListRankingScoreString = @"ChallengeDay5ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        else
        {
            challengeDayListRankingScoreString = @"ChallengeDay6ListRankingScore";
            [query orderByDescending:challengeDayListRankingScoreString];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                // The find succeeded.
                NSLog(@"You have %li friends", (unsigned long)objects.count - 1);
                
                //Create an array and copy 'objects' NSArray into it
                NSMutableArray *sortedFacebookFriendsArray = [[NSMutableArray alloc] init];
                
                //Order the objects in the new array by their current day's ChallengeListRankingScore
                //Make sure to reorder objects in both arrays so that the highest listRankingScores are on top
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:challengeDayListRankingScoreString ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [objects sortedArrayUsingDescriptors:sortDescriptors];
                [sortedFacebookFriendsArray removeAllObjects];
                [sortedFacebookFriendsArray addObjectsFromArray: sortedArray];
                
                long int yourRank = 0;
                
                for (PFObject *object in sortedFacebookFriendsArray)
                {
                    if ([object.objectId isEqualToString:[PFUser currentUser].objectId])
                    {
                        yourRank = [sortedFacebookFriendsArray indexOfObject:object] + 1;
                    }
                }
                
                
                NSLog (@"yourRank = %li, totalNumOfChallengers = %lu", yourRank, (unsigned long)[sortedFacebookFriendsArray count]);
                
                [[NSUserDefaults standardUserDefaults] setInteger:yourRank forKey:@"yourRank"];
                
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.repeatInterval = NSDayCalendarUnit;
                [notification setAlertBody: [NSString stringWithFormat:@"You are currently ranked %li of %lu among your Facebook friends", yourRank, (unsigned long)[sortedFacebookFriendsArray count]]];
                [notification setFireDate:[NSDate date]];
                [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
                notification.soundName = UILocalNotificationDefaultSoundName;
                [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
            else
            {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [[PFUser currentUser] saveInBackground];
        
        completionHandler(YES, nil);
    }
}

-(void) calculateFitnessRating: (MeViewController*)viewController completion:(void (^)(double, NSError *))completionHandler
{
    NSLog (@"calculateFitnessRating running!");
    
    //Grab 'resting_heart_rate' from Parse
    PFQuery *query= [PFUser query];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        /*
        //Determine resting heart rate target based on age
        
        //Determine 7-day RHR by averaging the 3rd and 4th lowest RHR's for the last 6 days and subtracting 4 from them.
        NSMutableArray *rhrArray = [[NSMutableArray alloc] init];

        NSNumber *rhr1DayAgo = [object objectForKey:@"RHR_1_day_ago"];
        NSLog (@"RHR_1_day_ago = %li", [rhr1DayAgo integerValue]);
        NSNumber *rhr2DaysAgo = [object objectForKey:@"RHR_2_days_ago"];
        NSLog (@"RHR_2_days_ago = %li", [rhr2DaysAgo integerValue]);
        NSNumber *rhr3DaysAgo = [object objectForKey:@"RHR_3_days_ago"];
        NSLog (@"RHR_3_days_ago = %li", [rhr3DaysAgo integerValue]);
        NSNumber *rhr4DaysAgo = [object objectForKey:@"RHR_4_days_ago"];
        NSLog (@"RHR_4_days_ago = %li", [rhr4DaysAgo integerValue]);
        NSNumber *rhr5DaysAgo = [object objectForKey:@"RHR_5_days_ago"];
        NSLog (@"RHR_5_days_ago = %li", [rhr5DaysAgo integerValue]);
        NSNumber *rhr6DaysAgo = [object objectForKey:@"RHR_6_days_ago"];
        NSLog (@"RHR_6_days_ago = %li", [rhr6DaysAgo integerValue]);
        if ([rhr1DayAgo integerValue] > 0 && [rhr1DayAgo integerValue] < 1000)
            [rhrArray addObject: rhr1DayAgo];
        if ([rhr2DaysAgo integerValue] > 0 && [rhr2DaysAgo integerValue] < 1000)
            [rhrArray addObject: rhr2DaysAgo];
        if ([rhr3DaysAgo integerValue] > 0 && [rhr3DaysAgo integerValue] < 1000)
            [rhrArray addObject: rhr3DaysAgo];
        if ([rhr4DaysAgo integerValue] > 0 && [rhr4DaysAgo integerValue] < 1000)
            [rhrArray addObject: rhr4DaysAgo];
        if ([rhr5DaysAgo integerValue] > 0 && [rhr5DaysAgo integerValue] < 1000)
            [rhrArray addObject: rhr5DaysAgo];
        if ([rhr6DaysAgo integerValue] > 0 && [rhr6DaysAgo integerValue] < 1000)
            [rhrArray addObject: rhr6DaysAgo];
        //If Grab the 3rd and 4th lowest RHR's in the array, get the avg of them, and then subtract 2
        //Only remove the lowest and 2nd lowest RHR's if the rhrArray count is greater than or equal to 4
        NSNumber *avgRHR = [NSNumber numberWithInteger:1000];
        */
        /*
        if ([rhrArray count] >= 4)
        {
            NSNumber *lowestRHR = [NSNumber numberWithInt: 1000];
            int indexOfLowestRHR = 0;
            //Remove lowest RHR
            for (int i = 0; i < [rhrArray count]; ++i)
            {
                if ([[rhrArray objectAtIndex:i] integerValue] < [lowestRHR integerValue] && [[rhrArray objectAtIndex:i] integerValue] > 0)
                {
                    lowestRHR = [rhrArray objectAtIndex:i];
                    indexOfLowestRHR = i;
                }
            }
            [rhrArray removeObjectAtIndex:indexOfLowestRHR];
            
            //Grab value of 2nd lowest RHR
            NSNumber *secondLowestRHR = [NSNumber numberWithInt: 1000];
            int indexOfSecondLowestRHR = 0;
            for (int i = 0; i < [rhrArray count]; ++i)
            {
                if ([[rhrArray objectAtIndex:i] integerValue] < [secondLowestRHR integerValue])
                {
                    secondLowestRHR = [rhrArray objectAtIndex:i];
                    indexOfSecondLowestRHR = i;
                }
            }
            //Remove second lowest RHR
            [rhrArray removeObjectAtIndex:indexOfSecondLowestRHR];
        }
        //Only grab the 3rd and 4th lowest RHR if the [rhrArray count] is greater than or equal to 2
        if ([rhrArray count] >= 2)
        {
            //Grab value of 3rd lowest RHR
            NSNumber *thirdLowestRHR = [NSNumber numberWithInt: 1000];
            int indexOfThirdLowestRHR = 0;
            for (int i = 0; i < [rhrArray count]; ++i)
            {
                if ([[rhrArray objectAtIndex:i] integerValue] < [thirdLowestRHR integerValue])
                {
                    thirdLowestRHR = [rhrArray objectAtIndex:i];
                    indexOfThirdLowestRHR = i;
                }
            }
            //Remove third lowest RHR
            [rhrArray removeObjectAtIndex:indexOfThirdLowestRHR];
        
            //Grab value of 4th lowest RHR
            NSNumber *fourthLowestRHR = [NSNumber numberWithInt: 1000];
            for (int i = 0; i < [rhrArray count]; ++i)
            {
                if ([[rhrArray objectAtIndex:i] integerValue] < [fourthLowestRHR integerValue])
                {
                    fourthLowestRHR = [rhrArray objectAtIndex:i];
                }
            }
            //Add 3rd and 4th lowest RHR, divide them by 2, and then minus 2 to get 'RHR'
            avgRHR = [NSNumber numberWithInt: (int)([thirdLowestRHR integerValue] + [fourthLowestRHR integerValue])/2 - 2];
            //Save avgRHR to parse
            [[PFUser currentUser] setObject:avgRHR forKey:@"avg_RHR"];
        }
        else if ([rhrArray count] == 1)
        {
            avgRHR = [NSNumber numberWithInt: (int)[[rhrArray lastObject] integerValue]];
            [[PFUser currentUser] setObject:avgRHR forKey:@"avg_RHR"];
        }
        */
        /*
        //Save the lowest RHR in rhrArray to avg_RHR in Parse
        for (NSNumber *rhr in rhrArray)
        {
            if ([rhr integerValue] < [avgRHR integerValue])
            {
                avgRHR = rhr;
            }
        }
        
        //Save lowestRHR to Parse
        [[PFUser currentUser] setObject:avgRHR forKey:@"avg_RHR"];

        //Determine 7-day 'heart_rate_recovery'
        //Determine 7-day HRR by averaging the 3rd and 4th highest HRR's for the last 6 days
        NSMutableArray *hrrArray = [[NSMutableArray alloc] init];
        
        NSNumber *hrr1DayAgo = [object objectForKey:@"HRR_1_day_ago"];
        NSLog (@"HRR_1_day_ago = %li", [hrr1DayAgo integerValue]);
        NSNumber *hrr2DaysAgo = [object objectForKey:@"HRR_2_days_ago"];
        NSLog (@"HRR_2_days_ago = %li", [hrr2DaysAgo integerValue]);
        NSNumber *hrr3DaysAgo = [object objectForKey:@"HRR_3_days_ago"];
        NSLog (@"HRR_3_days_ago = %li", [hrr3DaysAgo integerValue]);
        NSNumber *hrr4DaysAgo = [object objectForKey:@"HRR_4_days_ago"];
        NSLog (@"HRR_4_days_ago = %li", [hrr4DaysAgo integerValue]);
        NSNumber *hrr5DaysAgo = [object objectForKey:@"HRR_5_days_ago"];
        NSLog (@"HRR_5_days_ago = %li", [hrr5DaysAgo integerValue]);
        NSNumber *hrr6DaysAgo = [object objectForKey:@"HRR_6_days_ago"];
        NSLog (@"HRR_6_days_ago = %li", [hrr6DaysAgo integerValue]);
        NSLog (@"[hrrArray count] = %li", [hrrArray count]);

        if ([hrr1DayAgo integerValue] > 0)
            [hrrArray addObject: hrr1DayAgo];
        if ([hrr2DaysAgo integerValue] > 0)
            [hrrArray addObject: hrr2DaysAgo];
        if ([hrr3DaysAgo integerValue] > 0)
            [hrrArray addObject: hrr3DaysAgo];
        if ([hrr4DaysAgo integerValue] > 0)
            [hrrArray addObject: hrr4DaysAgo];
        if ([hrr5DaysAgo integerValue] > 0)
            [hrrArray addObject: hrr5DaysAgo];
        if ([hrr6DaysAgo integerValue] > 0)
            [hrrArray addObject: hrr6DaysAgo];
        
        NSNumber *avgHRR;
        //Grab the 3rd and 4th highest HRR's in the array, get the avg of them
        if ([hrrArray count] >= 4)
        {
            //Remove highest HRR
            NSNumber *highestHRR = [NSNumber numberWithInt: 0];
            int indexOfHighestHRR = 0;
            //Remove highest HRR
            for (int i = 0; i < [hrrArray count]; ++i)
            {
                if ([[hrrArray objectAtIndex:i] integerValue] > [highestHRR integerValue])
                {
                    highestHRR = [hrrArray objectAtIndex:i];
                    indexOfHighestHRR = i;
                }
            }
            [hrrArray removeObjectAtIndex:indexOfHighestHRR];
            
            //Remove 2nd highest HRR
            NSNumber *secondHighestHRR = [NSNumber numberWithInt: 0];
            int indexOfSecondHighestHRR = 0;
            for (int i = 0; i < [hrrArray count]; ++i)
            {
                if ([[hrrArray objectAtIndex:i] integerValue] > [secondHighestHRR integerValue])
                {
                    secondHighestHRR = [hrrArray objectAtIndex:i];
                    indexOfSecondHighestHRR = i;
                }
            }
            [hrrArray removeObjectAtIndex:indexOfSecondHighestHRR];
        }

        if ([hrrArray count] >= 2)
        {
            //Grab value of 3rd highest HRR
            NSNumber *thirdHighestHRR = [NSNumber numberWithInt: 0];
            int indexOfThirdHighestHRR = 0;
            for (int i = 0; i < [hrrArray count]; ++i)
            {
                if ([[hrrArray objectAtIndex:i] integerValue] > [thirdHighestHRR integerValue])
                {
                    thirdHighestHRR = [hrrArray objectAtIndex:i];
                    indexOfThirdHighestHRR = i;
                }
            }
            //Remove third highest HRR
            [hrrArray removeObjectAtIndex:indexOfThirdHighestHRR];
            NSLog (@"thirdHighestHRR = %li", [thirdHighestHRR integerValue]);
          
            //Grab value of 4rd highest HRR
            NSNumber *fourthHighestHRR = [NSNumber numberWithInt: 0];
            int indexOfFourthHighestHRR = 0;
            for (int i = 0; i < [hrrArray count]; ++i)
            {
                if ([[hrrArray objectAtIndex:i] integerValue] > [fourthHighestHRR integerValue])
                {
                    fourthHighestHRR = [hrrArray objectAtIndex:i];
                    indexOfThirdHighestHRR = i;
                }
            }
            //Remove fourth highest HRR
            [hrrArray removeObjectAtIndex:indexOfFourthHighestHRR];
            NSLog (@"fourthHighestHRR = %li", [fourthHighestHRR integerValue]);

            //Add 3rd and 4th highest HRR, divide them by 2
            avgHRR = [NSNumber numberWithInt: (int)([fourthHighestHRR integerValue] + [thirdHighestHRR integerValue])/2];
            //Save avgHRR to parse
            [[PFUser currentUser] setObject:avgHRR forKey:@"avg_HRR"];
        }
        else if ([hrrArray count] == 1)
        {
            avgHRR = [NSNumber numberWithInt: (int)[[hrrArray lastObject] integerValue]];
            [[PFUser currentUser] setObject:avgHRR forKey:@"avg_HRR"];
        }

        //Calculate 'fitness_rating' from those and upload to parse
        //fitness rating = 10 - (RHR - 45)*(0.1)*2 - (50 - HRR)*(0.1)
        NSNumber *fitnessRatingNSNumber;
        NSString *genderFromParse = [[PFUser currentUser] objectForKey:@"gender"];;
        int usersAge = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"usersAge"];
        int idealRHRForMales = 49;
        int idealRHRForFemales = 54;
        int idealHRRForMales = 52;
        int idealHRRForFemales = 39;
        float idealHRROffset = ((usersAge - 20)/4)*2;
        
        if (avgRHR != nil && avgHRR != nil)
        {
            float fitnessRating;
            //If user is male
            if ([genderFromParse isEqualToString: @"male"])
            {
                NSLog (@"user is MALE");
                fitnessRating = 10 - ([avgRHR floatValue] - idealRHRForMales)*(0.1)*2 - ((idealHRRForMales - idealHRROffset) - [avgHRR floatValue])*(0.1);
            }
            //If user is female
            else
            {
                NSLog (@"user is FEMALE");
                fitnessRating = 10 - ([avgRHR floatValue] - idealRHRForFemales)*(0.1)*2 - ((idealHRRForFemales - idealHRROffset) - [avgHRR floatValue])*(0.1);
            }
            
            fitnessRatingNSNumber = [NSNumber numberWithFloat: fitnessRating];
            [[PFUser currentUser] setObject:fitnessRatingNSNumber forKey:@"fitness_rating"];
            NSLog (@"fitness_rating = %f", fitnessRating);
        }
        else
        {
            fitnessRatingNSNumber = [NSNumber numberWithFloat: 0];
            [[PFUser currentUser] setObject:fitnessRatingNSNumber forKey:@"fitness_rating"];
            NSLog (@"fitness_rating is zero!");
        }
        
        NSLog (@"users age for Fitness Level Calculation = %i", usersAge);
        NSLog (@"avgRHR for Fitness Level Calculation = %f", [avgRHR floatValue]);
        NSLog (@"avgHRR for Fitness Level Calculation = %f", [avgHRR floatValue]);

        //Save fitnessRating to NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:fitnessRatingNSNumber forKey:@"fitnessRating"];
        [defaults synchronize];
        
        
        NSLog (@"7 Days of Steps logged, yesterdays calories logged, and fitness rating calculated and logged!");
        //Call MeViewController method to refresh dashBoard here
        [viewController.dashboardView removeFromSuperview];
        */
        
        //If user has shared all health data then add the dashboard and populate it
        if ([viewController allHealthDataSharedByUser])
        {            
            [viewController addDashboardView];
            
            //Add add the colored circles and bar graphs
            //[viewController addFitnessLevelBar:viewController.userObject];
            //[viewController addFitnessLevelDelimiterLabel:viewController.userObject];

            [viewController.progressIndicator stopAnimating];
            viewController.askToShareData.hidden = YES;
            viewController.calculatingFitnessRatingLabel.hidden = YES;
            
            //MeViewController's addColoredCircles method is called once the number of steps, minutes of exercise, or calories burned is actually downloaded from Parse
            [viewController addColoredCircles];
            
            //Making appropriate label on MeViewController visible
            viewController.dashboardView.todayDelimiterLabel.hidden = NO;
            viewController.dashboardView.updatingLabel.hidden = YES;
        }
        //If not then remove the approrpriate indicate and labels and tell the user to share all data
        else
        {
            NSLog (@"from HealthMethods: user has not shared all health data");
            
            [viewController.progressIndicator stopAnimating];
            viewController.calculatingFitnessRatingLabel.hidden = YES;
            
            //Create label asking user to share all data
            [viewController displayShareDataRequest];
            
            [viewController addDashboardView];
        }
        
        /*
        [self saveFriendsListRankingScoreToDisk: ^(double done, NSError *error)
        {
            completionHandler(YES, nil);
        }];
         */
    }];
    
    MeViewController *meViewSubClass = [[MeViewController alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"all6DaysWorthOfHealthMethodsAlreadyRunForFirstTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Save steps, exercise minutes, and calories six day averages
    [meViewSubClass sevenDayAvgNumOfSteps:[PFUser currentUser]];
    [meViewSubClass sevenDayAvgCaloriesBurned:[PFUser currentUser]];
    [meViewSubClass sevenDayAvgMinutesOfExercise:[PFUser currentUser]];
    
    /*
    //If list ranking score is greater than 0.5, allow user to send a motivational message to someone
    if ([self calculateListRankingScore:@"NumberOfStepsToday" exerciseMinsParseKey:@"MinutesOfExerciseToday" calsBurnedParseKey:@"CaloriesBurnedToday" listRankingScoreDay:@"listRankingScore"])   //returns a float value
    {
        //Don't call dialogueBoxForWorkoutMotivation directly it won't run. Something about the view being deallocated
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowMotivationDialogueBox"];
    }
    */
    
    [viewController setTodaysActivityLabel];
    
    //Calculate yesterdays listRankingScore
    [self calculateYesterdaysListRankingScore];
}

//Used to announce who did the best yesterday
-(float)calculateYesterdaysListRankingScore
{
    NSLog (@"calculateYesterdaysListRankingScore called!");
    
    //Formula: (avgSteps/stepsGoal + avgMinExercise/minExericseGoal + avgCalBurn/calBurnGoal)/3
    float yourAvgSteps = [[PFUser currentUser][@"NumberOfStepsYesterday"] floatValue];
    float yourStepsGoal = 10000;
    
    float yourAvgMinExericse = [[PFUser currentUser][@"MinutesOfExerciseOneDayAgo"] floatValue];
    float yourMinExerciseGoal = 60;
    
    float yourAvgCaloriesBurned = [[PFUser currentUser][@"CaloriesBurnedOneDayAgo"] floatValue];
    float yourCaloriesBurnedGoal = [[PFUser currentUser][@"moveGoal"] floatValue];
    
    float yesterdaysListRankingScore = (yourAvgSteps/yourStepsGoal + yourAvgMinExericse/yourMinExerciseGoal + yourAvgCaloriesBurned/yourCaloriesBurnedGoal)/3;
    
    //Save listRankingScore to parse
    [[PFUser currentUser] setObject: [NSNumber numberWithFloat:yesterdaysListRankingScore] forKey:@"yesterdaysListRankingScore"];
    [[PFUser currentUser] saveInBackground];
    
    
    if ([PFUser currentUser])
    {
        //Save your listRankingScore to the appropriate Activity objects in Parse for later use in determing list order for friends/followers lists
        PFQuery *fromUserQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [fromUserQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        
        PFQuery *toUserQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [toUserQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromUserQuery,toUserQuery]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
         {
             for (PFObject *object in results)
             {
                 NSLog (@"object to user = %@", object[@"toUser"]);
                 NSLog (@"[PFUser currentUser].objectId] = %@", [PFUser currentUser]);
                 
                 PFUser *toUser = object[@"toUser"];
                 
                 if ([toUser.objectId isEqualToString: [PFUser currentUser].objectId])
                 {
                     NSLog (@"writing to toUserYesterdaysListRankingScore");
                     [object setObject:[NSNumber numberWithFloat:yesterdaysListRankingScore] forKey:@"toUserYesterdaysListRankingScore"];
                     [object saveInBackground];
                 }
                 else
                 {
                     NSLog (@"writing to fromUserYesterdaysListRankingScore");
                     [object setObject:[NSNumber numberWithFloat:yesterdaysListRankingScore] forKey:@"fromUserYesterdaysListRankingScore"];
                     [object saveInBackground];
                 }
             }
         }];
    }
    
    return yesterdaysListRankingScore;
}

-(void)calculateTimeRelativeToUserListRankingScore
{
    NSLog (@"calculateTimeRelativeToUserListRankingScore called!");
    
    if ([PFUser currentUser])
    {
        //Query all Activities where you are in the fromUser
        PFQuery *fromUserQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [fromUserQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        [fromUserQuery whereKey:@"FriendStatus" equalTo:@"Friends"];
        [fromUserQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
         {
             for (PFObject *object in results)
             {
                 PFUser *userFetched = object[@"toUser"];
                 [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
                  {
                      //If toUser's stats haven't been updated today
                      if (!([self isNSDateToday:[userFetched updatedAt]]))
                      {
                          NSLog (@"timeRelativeToUserListRankingScore: user HASN'T updated stats today!");
                          //then save their listRankingScore * 0.001 to their timeRelativeToUserListRankingScore in Activities
                          float userFetchedTimeRelativeToUserListRankingScore = [userFetched[@"listRankingScore"] floatValue]*0.001;
                          [object setObject:[NSNumber numberWithFloat:userFetchedTimeRelativeToUserListRankingScore] forKey:@"timeRelativeToUserListRankingScore"];
                          [object saveInBackground];
                      }
                      else
                      {
                          NSLog (@"timeRelativeToUserListRankingScore: user HAS updated stats today!");
                          float userFetchedTimeRelativeToUserListRankingScore = [userFetched[@"listRankingScore"] floatValue];
                          [object setObject:[NSNumber numberWithFloat:userFetchedTimeRelativeToUserListRankingScore] forKey:@"timeRelativeToUserListRankingScore"];
                          [object saveInBackground];
                      }
                  }];
             }
             
             HomeView *homeViewSubClass = [[HomeView alloc] init];
             [homeViewSubClass loadObjects];
         }];
    }
}

//This number is used to choose the order of the people on your friends/following list
-(float) challengeListRankingScore: (NSString*)numOfStepsParseKeyArg exerciseMinsParseKey:(NSString *)exerciseMinsParseKeyArg calsBurnedParseKey:(NSString *)calsBurnedParseKeyArg
{
    NSLog (@"challengeListRankingScore called!");
    
    //Formula: (avgSteps/stepsGoal + avgMinExercise/minExericseGoal + avgCalBurn/calBurnGoal)/3
    float yourAvgSteps = [[PFUser currentUser][numOfStepsParseKeyArg] floatValue];
    float yourStepsGoal = 10000;
    
    float yourAvgMinExericse = [[PFUser currentUser][exerciseMinsParseKeyArg] floatValue];
    float yourMinExerciseGoal = 60;
    
    float yourAvgCaloriesBurned = [[PFUser currentUser][calsBurnedParseKeyArg] floatValue];
    float yourCaloriesBurnedGoal = [[PFUser currentUser][@"moveGoal"] floatValue];
    
    float listRankingScore = (yourAvgSteps/yourStepsGoal + yourAvgMinExericse/yourMinExerciseGoal + yourAvgCaloriesBurned/yourCaloriesBurnedGoal)/3;
    
    return listRankingScore;
}

//This number is used to choose the order of the people on your friends/following list
-(float)calculateListRankingScore: (NSString*)numOfStepsParseKeyArg exerciseMinsParseKey:(NSString *)exerciseMinsParseKeyArg calsBurnedParseKey:(NSString *)calsBurnedParseKeyArg listRankingScoreDay:(NSString *)listRankingScoreDayArg
{
    NSLog (@"calculateListRankingScore for %@", listRankingScoreDayArg);
    
    //Formula: (avgSteps/stepsGoal + avgMinExercise/minExericseGoal + avgCalBurn/calBurnGoal)/3
    float yourAvgSteps = [[PFUser currentUser][numOfStepsParseKeyArg] floatValue];
    float yourStepsGoal = 10000;
    
    float yourAvgMinExericse = [[PFUser currentUser][exerciseMinsParseKeyArg] floatValue];
    float yourMinExerciseGoal = 60;
    
    float yourAvgCaloriesBurned = [[PFUser currentUser][calsBurnedParseKeyArg] floatValue];
    float yourCaloriesBurnedGoal = [[PFUser currentUser][@"moveGoal"] floatValue];
    
    float listRankingScore = (yourAvgSteps/yourStepsGoal + yourAvgMinExericse/yourMinExerciseGoal + yourAvgCaloriesBurned/yourCaloriesBurnedGoal)/3;
    
    NSLog (@"final listRankingScore for %@ = %f", listRankingScoreDayArg, listRankingScore);
    
    if ([PFUser currentUser])
    {
        //Save listRankingScore to parse
        [[PFUser currentUser] setObject: [NSNumber numberWithFloat:listRankingScore] forKey:listRankingScoreDayArg];
        [[PFUser currentUser] saveInBackground];
        
        //Save your listRankingScore to the appropriate Activity objects in Parse for later use in determing list order for friends/followers lists
        PFQuery *fromUserQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [fromUserQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        
        PFQuery *toUserQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [toUserQuery whereKey:@"saved_to_list" equalTo:@"Following"];
        
        if ([listRankingScoreDayArg isEqualToString:@"listRankingScore"])
        {
            PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromUserQuery,toUserQuery]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
            {
                for (PFObject *object in results)
                {
                    NSLog (@"object to user = %@", object[@"toUser"]);
                    NSLog (@"[PFUser currentUser].objectId] = %@", [PFUser currentUser]);
                    
                    PFUser *toUser = object[@"toUser"];
                    
                    if ([toUser.objectId isEqualToString: [PFUser currentUser].objectId])
                    {
                        NSLog (@"writing to toUserListRankingScore");
                        [object setObject:[NSNumber numberWithFloat:listRankingScore] forKey:@"toUserListRankingScore"];
                        [object saveInBackground];
                    }
                    else
                    {
                        NSLog (@"writing to fromUserListRankingScore");
                        [object setObject:[NSNumber numberWithFloat:listRankingScore] forKey:@"fromUserListRankingScore"];
                        [object saveInBackground];
                    }
                }
                
                //[self calculateTimeRelativeToUserListRankingScore];

                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StepsQueryCurrentlyRunning"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WorkoutsQueryCurrentlyRunning"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        }
    }
    
    return listRankingScore;
}

//This method should be run at the app's launch.  Later on, find a way to run it when the height changes.
-(void)saveUsersHeightToParse
{
    NSLog (@"HealthMethods saveUsersHeightToParse");
    
    // Fetch user's default height unit in inches.
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        
        NSLog (@"User's height block running");
        
        if (!mostRecentQuantity)
        {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
            
            NSLog (@"User's height not available");
            
            //Upload 0 to PFUser's height field
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"heightInCM"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 // some logging code here
                 if (succeeded)
                 {
                     NSLog (@"Successfully saved user's height as 0 to Parse (since they didn't provide a height to HealthKit)");
                 }
                 if (error)
                 {
                     NSLog (@"Error saving user's height as 0 to Parse");
                 }
             }];
        }
        else
        {
            // Determine the height in the required unit.
            HKUnit *heightUnit = [HKUnit inchUnit];
            double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
            
            //Upload usersHeight*2.54 to PFUser's height field
            //Upload 0 to PFUser's height field
            [[PFUser currentUser] setObject:[NSNumber numberWithDouble:usersHeight*2.54] forKey:@"heightInCM"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 // some logging code here
                 if (succeeded)
                 {
                     NSLog (@"Successfully saved user's height to Parse");
                 }
                 if (error)
                 {
                     NSLog (@"Error saving user's height to Parse");
                 }
             }];
            
            //Save user's height to NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setDouble:usersHeight*2.54 forKey:@"heightInCM"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)saveUsersWeightToParse {
    
    NSLog (@"HealthMethods saveUsersWeightToParse");
    
    // Fetch the user's default weight unit in kg.

    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity)
        {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
            NSLog (@"User's weight not available");
            
            //Upload 0 to PFUser's height field
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"weightInKG"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 // some logging code here
                 if (succeeded)
                 {
                     NSLog (@"Successfully saved user's weight as 0 to Parse (since they didn't provide a weight to HealthKit)");
                 }
                 if (error)
                 {
                     NSLog (@"Error saving user's height as 0 to Parse");
                 }
             }];
        }
        else
        {
            // Determine the weight in the required unit.
            HKUnit *weightUnit = [HKUnit poundUnit];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            //Upload usersHeight*2.54 to PFUser's height field
            //Upload 0 to PFUser's height field
            [[PFUser currentUser] setObject:[NSNumber numberWithDouble:usersWeight*0.453592] forKey:@"weightInKG"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 // some logging code here
                 if (succeeded)
                 {
                     NSLog (@"Successfully saved user's weight to Parse");
                 }
                 if (error)
                 {
                     NSLog (@"Error saving user's weight to Parse");
                 }
             }];
            
            //Save user's weight to NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setDouble:usersWeight*0.453592 forKey:@"weightInKG"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}


@end
