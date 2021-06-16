//
//  PageContentViewController.m
//  Fitness
//
//  Created by Long Le on 10/15/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "PageContentViewController.h"

//Create object to hold bpm and timestamp
@interface HRReading : NSObject <NSCoding>
{
    double bpm;
    NSDate *startDate;
}
@property(nonatomic) double bpm;
@property(nonatomic) NSDate *startDate;
@end

@implementation HRReading
@synthesize bpm, startDate;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:bpm forKey:@"bpm"];
    [encoder encodeObject:startDate forKey:@"startDate"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.bpm = [coder decodeDoubleForKey:@"bpm"];
    self.startDate = [coder decodeObjectForKey:@"startDate"];
    return self;
}

@end





@interface PageContentViewController ()

@end

@implementation PageContentViewController

@synthesize wholeDayHeartRatesArray;
@synthesize oneMinuteHRR;
@synthesize lowBPMAverageTimeStampPairsArray;
@synthesize elementsToRemoveArray;
@synthesize numElementToDeleteTo;
@synthesize hrrIVar;
@synthesize archivedReadingsArray;
@synthesize fitnessLevelNum;
@synthesize index;
@synthesize title;
@synthesize currentHeartRateSumAverageHigh;
@synthesize currentHeartRateSumAverageLow;
@synthesize newHighestHRR;
@synthesize wholeDayHeartRatesToDeleteArray;
/*
- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog (@"PageContentViewController viewDidLoad called!");
    
   // index = 1;
    title = [NSString stringWithFormat: @"Cardio Data"];
    
    // Do any additional setup after loading the view.
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    
    //Init and alloc array
    wholeDayHeartRatesArray = [[NSMutableArray alloc] init];
    wholeDayHeartRatesToDeleteArray = [[NSMutableArray alloc] init];
    lowBPMAverageTimeStampPairsArray = [[NSMutableArray alloc] init];
    archivedReadingsArray = [[NSMutableArray alloc] init];
    
    //Load 'archivedReadingsArray' from disk
    [self readArchivedReadingsArrayFromDisk];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:UIApplicationDidBecomeActiveNotification object:nil];
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
-(void) saveArchivedReadingToHistoryLog: (int)maxHRArg minHR:(int)minHRArg hrr:(int)hrrArg startDate:(NSDate*)startDateArg
{
    NSLog (@"saveArchivedReadingToHistoryLog running");
    
    NSString *path = [self pathForData2File];
    
    ArchivedReading *reading = [[ArchivedReading alloc] init];
    reading.highbpm = maxHRArg;
    reading.lowbpm = minHRArg;
    reading.hrr = hrrArg;
    reading.startDate = startDateArg;
    
    NSLog (@"reading.highbpm = %f", reading.highbpm);
    NSLog (@"reading.lowbpm = %f", reading.lowbpm);
    NSLog (@"reading.hrr = %f", reading.hrr);
    
    
    //Add 'reading' to array
    [archivedReadingsArray addObject: reading];
    
    NSArray *unmutableArchivedReadingsArray = [NSArray arrayWithArray: archivedReadingsArray];
    
    //NSLog (@"archivedReadingsArray count = %lu", (unsigned long)[archivedReadingsArray count]);
    
    //Save array to disk
    [NSKeyedArchiver archiveRootObject:unmutableArchivedReadingsArray toFile:path];
}

//read archivedReadingsArray from disk
- (void) readArchivedReadingsArrayFromDisk
{
    NSString *path = [self pathForData2File];
    
    NSArray *unmutableArchivedReadingsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSLog (@"readArchivedReadingsArrayFromDisk unmutableArchivedReadingsArray count = %li", [unmutableArchivedReadingsArray count]);
    
    if ([unmutableArchivedReadingsArray count] > 0 && [[unmutableArchivedReadingsArray objectAtIndex:0] highbpm] != 0 && [[unmutableArchivedReadingsArray objectAtIndex:0] lowbpm] != 0)
        [archivedReadingsArray addObjectsFromArray: unmutableArchivedReadingsArray];
    
    NSLog (@"readArchivedReadingsArrayFromDisk archivedReadingsArray count = %li", [archivedReadingsArray count]);
}

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

//save wholeDayHeartRatesArray to disk for later use
- (void) saveWholeDayHeartRatesArrayToDisk
{
    NSString *path = [self pathForDataFile];

    //Go through wholeDayHeartRatesArray and remove all readings whose startDates are not today's
    for (int i = 0; i < [wholeDayHeartRatesArray count]; i++)
        @autoreleasepool
    {
        if (i >= 1)
        {
            //Iterate through wholeDayHeartRatesArray and add readings whose time stamp days aren't today's
            NSDate *todaysDate = [NSDate date];
            
            //If reading's startDate day is less than current day then add it to wholeDayHeartRatesToDeleteArray
            NSDate *readingsStartDate = [[wholeDayHeartRatesArray objectAtIndex:i] startDate];
            
            NSLog(@"Difference in date components:%li", [self daysBetweenDate:readingsStartDate andDate:todaysDate]);
            
            if ([self daysBetweenDate:readingsStartDate andDate:todaysDate] >= 1)
            {
                NSLog (@"add to wholeDayHeartRatesToDeleteArray");
                [wholeDayHeartRatesToDeleteArray addObject: [wholeDayHeartRatesArray objectAtIndex: i]];
            }
        }
    }
    
    NSLog (@"wholeDayHeartRatesArray size BEFORE wholeDayHeartRatesToDeleteArray removed = %li", [wholeDayHeartRatesArray count]);
    //Delete all readings that don't have a time stamp day for the current day
    [wholeDayHeartRatesArray removeObjectsInArray: wholeDayHeartRatesToDeleteArray];
    NSLog (@"wholeDayHeartRatesArray size AFTER wholeDayHeartRatesToDeleteArray removed = %li", [wholeDayHeartRatesArray count]);
    
    
    NSArray *unmutableWholeDayHeartRatesArray = [NSArray arrayWithArray: wholeDayHeartRatesArray];
    
    NSLog (@"saveWholeDayHeartRatesArrayToDisk unmutableWholeDayHeartRatesArray count = %li", [unmutableWholeDayHeartRatesArray count]);
    
    [NSKeyedArchiver archiveRootObject:unmutableWholeDayHeartRatesArray toFile:path];
}

//read wholeDayHeartRatesArray to disk
- (void) readWholeDayHeartRatesArrayFromDisk
{
    NSString *path = [self pathForDataFile];
    
    NSArray *unmutableWholeDayHeartRatesArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSLog (@"readWholeDayHeartRatesArrayFromDisk unmutableWholeDayHeartRatesArray count = %li", [unmutableWholeDayHeartRatesArray count]);
    
    //Make sure there's valid data in unmutableWholeDayHeartRatesArray before you copy it to wholeDayHeartRatesArray.  Note: When app is run for the first time, unmutableWholeDayHeartRatesArray count returns 1.  Attempting to read the object's bpm or date crashes the app.
    if ([unmutableWholeDayHeartRatesArray count] > 1)
        [wholeDayHeartRatesArray addObjectsFromArray: unmutableWholeDayHeartRatesArray];
    
    NSLog (@"readWholeDayHeartRatesArrayFromDisk wholeDayHeartRatesArray count = %li", [wholeDayHeartRatesArray count]);
}

//Refresh heart rate data
- (void)refreshStatistics {
    
    NSLog (@"refreshStatistics running");
    
    HKQuantityType *maxHeartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *minHeartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    // Fetch ax heart rate sample from HealthKit. .
    [self queryMaxHeartRateForToday:maxHeartRateType unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double maxHeartRateForToday, NSError *error)
    {
        
        // Update the UI with all of the fetched values.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.maxHeartRate = maxHeartRateForToday;
            
            self.maxHeartRateLabel.text = [NSString stringWithFormat: @"%.0f", self.maxHeartRate];
        });
    }];
    
    // Fetch the min heart rate sample from HealthKit. .
    [self queryMinHeartRateForToday:minHeartRateType unit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] completion:^(double minHeartRateForToday, NSError *error)
    {
        
        // Update the UI with all of the fetched values.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.minHeartRate = minHeartRateForToday;
            
            self.minHeartRateLabel.text = [NSString stringWithFormat: @"%.0f", self.minHeartRate];
        });
    }];
 
    // Fetch all heart rate samples from HealthKit and put them into an array
     //Determine number of seconds from start of this day to now
    [self queryAllHeartRatesSinceLastAnchor:heartRateType unit:[HKUnit countUnit] completion:^(double done, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             NSLog (@"queryAllHeartRatesSinceLastAnchor dispatch called!");
            [self updateLowestAndHighestHeartRatesInArray: wholeDayHeartRatesArray];
         });
     }];
    
 
    //Call observer query
    [self observerQueryToUpdateUI: heartRateType unit: [HKUnit countUnit] completion:^(double done, NSError *error)
     {
         // Fetch all heart rate samples from HealthKit and put them into an array
         //Determine number of seconds from start of this day to now
         [self queryAllHeartRatesSinceLastAnchor:heartRateType unit:[HKUnit countUnit] completion:^(double done, NSError *error)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  
                  NSLog (@"Updating low, high HRs and UI through observer");
                  [self updateLowestAndHighestHeartRatesInArray:wholeDayHeartRatesArray];
              });
          }];
     }];
 
    //Enable backgrounding
 
    [healthStore enableBackgroundDeliveryForType:heartRateType frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            
            // Fetch all heart rate samples from HealthKit and put them into an array
            //Determine number of seconds from start of this day to now
            [self queryAllHeartRatesSinceLastAnchor:heartRateType unit:[HKUnit countUnit] completion:^(double done, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSLog (@"Updating low, high HRs and UI through background delivery");
                     [self updateLowestAndHighestHeartRatesInArray:wholeDayHeartRatesArray];
                 });
             }];
        }
    }];
}

//Obtain current day
- (NSPredicate *)predicateForSamplesToday {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *startDate = [calendar startOfDayForDate:[NSDate date]];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

//Obtain time range
-(NSPredicate *)predicateForSamplesFromStartTime: (int)seconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *startDate = [calendar startOfDayForDate:[NSDate date]];
    startDate = [startDate dateByAddingTimeInterval: seconds];
    NSDate *endDate = [startDate dateByAddingTimeInterval: 10];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

//Query to obtain max heart rate from healthkit
- (void)queryMaxHeartRateForToday:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSPredicate *predicate = [self predicateForSamplesToday];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionDiscreteMax completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *max = [result maximumQuantity];
        
        if (completionHandler) {
            double value = [max doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [healthStore executeQuery:query];
}

//Query to obtain min heart rate from healthkit
- (void)queryMinHeartRateForToday:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesToday];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionDiscreteMin completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *min = [result minimumQuantity];
        
        if (completionHandler) {
            double value = [min doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [healthStore executeQuery:query];
}

-(NSPredicate*) sevenDaysAgoPredicate
{
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-7];
    NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:currentDate endDate:sevenDaysAgo options:HKQueryOptionNone];
    
    return predicate;
}

//Query to obtain the heart rates last anchor
- (void)queryAllHeartRatesSinceLastAnchor:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryAllHeartRatesSinceLastAnchor running!");

    //Retrieve wholeDayHeartRatesArray from disk
    [self readWholeDayHeartRatesArrayFromDisk];
    
    self.lastAnchor = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastAnchor"];
    NSLog (@"lastAnchor = %li", [self lastAnchor]);
    
    HKAnchoredObjectQuery *query;
    query = [[HKAnchoredObjectQuery alloc] initWithType:quantityType predicate:[self predicateForSamplesToday] anchor:self.lastAnchor limit:HKObjectQueryNoLimit completionHandler:^(HKAnchoredObjectQuery *query, NSArray *results, NSUInteger newAnchor, NSError *error) {
        
        if (completionHandler) {
            
            NSLog (@"queryAllHeartRatesSinceLastAnchor completionHandler called!");
            
            double done = 1;
            
            NSLog (@"results count = %li", [results count]);
            
            //Uncomment the following to have contents of wholeDayHeartRatesArray be deleted every time the the data readings page is loaded
            //[wholeDayHeartRatesArray removeAllObjects];
            
            //Convert all objects in 'results' array into HRReading and place them into new array
            [self convertHKUnitToHRReadingAndCopyToNewArray:results newArray:wholeDayHeartRatesArray];
            
            NSLog (@"wholeDayHeartRatesArray after copy = %li", [wholeDayHeartRatesArray count]);
            
            self.lastAnchor = newAnchor;
            [[NSUserDefaults standardUserDefaults] setInteger:self.lastAnchor forKey:@"LastAnchor"];
            NSLog (@"After lastAnchor = %li", self.lastAnchor);

            completionHandler(done, error);
        }
    }];

    [healthStore executeQuery:query];
}

//Setup and run observer query
- (void)observerQueryToUpdateUI:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    {
        NSLog (@"observerQueryToUpdateUI called!");
        
        //Retrieve wholeDayHeartRatesArray from disk
        [self readWholeDayHeartRatesArrayFromDisk];
        
        HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        self.lastAnchor = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastAnchor"];
        NSLog (@"Before lastAnchor from user defaults in observerQuery = %li", self.lastAnchor);
        
        
        HKObserverQuery *query;
        query = [[HKObserverQuery alloc] initWithSampleType:quantityType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            
            if (error)
            {
                //Perform proper error handling here
                NSLog (@"An error occurred while using observer query to run calculations and update UI.  %@", error.localizedDescription);
                abort();
            }
            
            //Otherwise pull data, run calculations, and update UI.  This may involve executing other queries
            // Fetch all heart rate samples from HealthKit and put them into an array
            //Determine number of seconds from start of this day to now
            [self queryAllHeartRatesSinceLastAnchor:heartRateType unit:[HKUnit countUnit] completion:^(double done, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self updateLowestAndHighestHeartRatesInArray:wholeDayHeartRatesArray];
                 });
             }];
        }];
        
        [healthStore executeQuery:query];
    }
}

- (void) updateCalculatingLabel {
    
    //Accessing UI Thread
    
    //Do any updates to your label here
   // self.calculatingStatusLabel.text = [NSString  stringWithFormat: @"Calculating... %i%%", (100 * elementsIterated)/totalElementsToIterate];
}

-(NSString*) convertToLocalTime: (NSDate*)dateArg
{
    NSDateFormatter *localFormat = [[NSDateFormatter alloc] init];
    [localFormat setTimeStyle:NSDateFormatterLongStyle];
    [localFormat setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
    NSString *localTime = [localFormat stringFromDate:dateArg];
    
    return localTime;
}

-(BOOL) verifySamplesAreChronologicallyContiguous: (int)loopBeginArg numOfIterations:(int)numOfIterationsArg array:(NSMutableArray*)arrayArg
{
    if ([arrayArg count] > 180)
    {
        for (int j = loopBeginArg; j < loopBeginArg + numOfIterationsArg - 1; ++j)
        @autoreleasepool {
        
            //Make sure the i-value's time stamp is no more than 5 seconds apart from the next 120 i-value's time stamps or else break
            NSDate *dateA = [[arrayArg objectAtIndex:j] startDate];
            NSDate *dateB = [[arrayArg objectAtIndex:j + 1] startDate];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *timeDifference = [calendar components:NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                           fromDate:dateA
                                                             toDate:dateB
                                                            options:0];
            
            //NSLog(@"Difference in date components: %li/%li/%li/%li/%li", timeDifference.second, timeDifference.minute, timeDifference.day, timeDifference.month, timeDifference.year);
            if (timeDifference.day > 0 || timeDifference.hour > 0 || timeDifference.minute > 0 || timeDifference.second > 5)
            {
                return false;
            }
        }
    }
    
    return true;
}

-(void) convertHKUnitToHRReadingAndCopyToNewArray: (NSArray*)oldArrayArg newArray:(NSMutableArray*)newArrayArg
{
    //NSLog (@"running convertHKUnitToHRReadingAndCopyToNewArray");
    
    //NSLog (@"Starting copy: Old Array Count = %lu", (unsigned long)[oldArrayArg count]);
    
    HRReading *hrReading;
    
    
    for (int i = 0; i < [oldArrayArg count]; i++)
    @autoreleasepool{

        hrReading = [[HRReading alloc] init];
        
        //Create NSDate set to sample's date
        hrReading.startDate = [[oldArrayArg objectAtIndex:i] startDate];
        //Create int set to sample's int
        hrReading.bpm = [[[oldArrayArg objectAtIndex:i] quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
        
        //Copy object to new array
        [wholeDayHeartRatesArray addObject: hrReading];
    }
    
    //NSLog (@"Finished copy New Array Count = %lu", (unsigned long)[oldArrayArg count]);
}


-(BOOL) RHRHasQuorum: (HRReading*)newRHR array:(NSMutableArray*)arrayArg
{
    //adds ‘newRHR’ to ‘lowestRHRArray
    [arrayArg addObject: newRHR];
    
    //and then compares ‘newRHR’ value with the lowest values in ‘lowestRHRArray
    for (int i = 0; i < [arrayArg count]; i++)
    @autoreleasepool{
        if (newRHR.bpm + 1 <= [[arrayArg objectAtIndex: i] bpm])
        {
            //log new lowest RHR
        }
    }
    
    //return yes or no
}

-(void) logReadingsToHistory: (NSDate*)dateArg
{
    //Get yesterday's date
    NSDate *now = [NSDate date];
    int daysToAdd = -1;
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
    
    int maxSustainedHR = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxSustainedHR"];
    int minSustainedHR = [[NSUserDefaults standardUserDefaults] integerForKey:@"MinSustainedHR"];
    int highestHRR = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxHRR"];
    
    NSLog (@"maxSustainedHR = %i", maxSustainedHR);
    NSLog (@"minSustainedHR = %i", minSustainedHR);
    NSLog (@"highestHRR = %i", highestHRR);
    NSLog (@"dateArg = %@", dateArg);
    
    //If it's a new day, copy yesterday's reading to the archivedReadingsArray and then save the array to disk
    [self saveArchivedReadingToHistoryLog: maxSustainedHR minHR:minSustainedHR hrr:highestHRR startDate:dateArg];
}

-(void) pullTodaysReadingHighsAndLowsFromUserDefaults
{
    NSLog (@"Pulling heart rate data from user defaults");
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MaxSustainedHR"] != 0)
        currentHeartRateSumAverageHigh = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxSustainedHR"];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MinSustainedHR"] != 0)
        currentHeartRateSumAverageLow = [[NSUserDefaults standardUserDefaults] integerForKey:@"MinSustainedHR"];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MaxHRR"] != 0)
        newHighestHRR = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxHRR"];
}

-(void) updateLowestAndHighestHeartRatesInArray: (NSMutableArray *)array
{
    int heartRateSumHigh = 0;
    double valueHigh1 = 0;
    double valueHigh2 = 0;
    bool breakOutOfLoopHigh = false;
    int numberOfSamplesBeingAddedHigh = 0;
    currentHeartRateSumAverageHigh = 0;
    //int totalElementsToIterate = 0;
    //double highestSustainedHeartRate = 0;
    //double lowestSustainedHeartRate = 1000;
    //int elementsIterated = 0;
    newHighestHRR = 0;
    int heartRateSumAverageLow = 0;
    int heartRateSumAverageHigh = 0;
    
    int bpm = 0;
    int basebmp = 0;
    int bpmSum = 0;
    int numberOfSamplesInSumbpm = 0;
    int bpmSumAverage = 0;
    int workingbpmCoolDownSum = 0;
    int numberOfSamplesInWorkingbpmCoolDownAverage = 0;
    int workingbpmCoolDownAverage = 0;
    
    int heartRateSumLow = 0;
    heartRateSumAverageLow = 0;
    double valueLow1 = 0;
    double valueLow2 = 0;
    bool breakOutOfLoopLow = false;
    int numberOfSamplesBeingAddedLow = 0;
    LowbpmAvgStartDatePair *lowbpmAvgStartDatePair;
    NSDate *timeStampOfFirstSample;
    currentHeartRateSumAverageLow = 1000;
    numElementToDeleteTo = 0;

    bool newMinSustainedHRLogged = false;
    bool continueWithRHRCalculations = false;
    
    //Pull highs and lows from user defaults
    [self pullTodaysReadingHighsAndLowsFromUserDefaults];
    
    if ([array count] > 180) {
        
        //Beginning of HRR calculations
        //Iterate through array from beginning until [array count] - 180 (2 min worth at the end)
        for (int i = 0; i < [array count] - 180; i++)
            @autoreleasepool
        {
            continueWithRHRCalculations = false;
            
            //Reset reused variables
            bpmSum = 0;
            numberOfSamplesInSumbpm = 0;
            bpmSumAverage = 0;
            workingbpmCoolDownAverage = 0;
            
            
            //Verify readings are no more than 5 seconds apart
            if ([self verifySamplesAreChronologicallyContiguous:i numOfIterations:180 array:wholeDayHeartRatesArray])
            {
               // NSLog (@"true!");
                continueWithRHRCalculations = true;
            }
            else
            {
               // NSLog (@"false!");
                continueWithRHRCalculations = false;
            }
            
            
            if (continueWithRHRCalculations)
            {
                //Find the first 1min interval from element i where each BPM is above 100 +/- 3…… AND the 120 values (2 minute) right after whose sum/60 is at least 5 less than the average BPM 1 minute before it.
                for (int j = i; j < i + 60; j++)
                    @autoreleasepool
                {
                    //bpm being iterated
                    basebmp = [[array objectAtIndex:i] bpm];
                    bpm = [[array objectAtIndex:j] bpm];
                    
                    //Make sure bpm is no less than 7 of the basebmp, and not more than 10 of the basebmp
                    if (basebmp > 110 && bpm >= basebmp - 7 && bpm <= basebmp + 10)
                    {
                        numberOfSamplesInSumbpm++;
                        bpmSum = bpmSum + bpm;
                    }
                    else
                    {
                        break;
                    }
                }
                
                int value1 = 0;
                int value2 = 0;
                
                //So if there are 60 samples in bpmSum, now iterate through 120 'cooldown' samples after the previous 60bpm
                if (numberOfSamplesInSumbpm == 60)
                {
                    //If all 60 elements are successfully iterated through find the average
                    bpmSumAverage = bpmSum/numberOfSamplesInSumbpm;
                    
                    //Reset numberOfSamplesInWorkingbpmCoolDownAverage for the following block
                    numberOfSamplesInWorkingbpmCoolDownAverage = 0;
                    
                    workingbpmCoolDownSum = 0;
                    
                    //now iterate through 120 'cooldown' samples after the previous 60bpm
                    for (int k = i + 61; k < i + 180; k++)
                        @autoreleasepool
                    {
                        numberOfSamplesInWorkingbpmCoolDownAverage++;
                        workingbpmCoolDownSum += [[array objectAtIndex:k] bpm];
                        
                        //NSLog (@"k = %i", k);
                        //Make sure each of the 120 cooldown values is not much higher than the previous
                        value1 = [[array objectAtIndex:k] bpm];
                        //NSLog (@"value1 = %i", value1);
                        //Heart rate value at j
                        value2 = [[array objectAtIndex:k+1] bpm];
                        
                        //NSLog (@"value2 = %i", value2);
                        //Make sure each of the 120 cooldown values is not much higher than the previous
                        if (value2 > value1 + 6)
                        {
                            break;
                        }
                    }
                    
                    //Get the average cooldown time for this time interval
                    if (numberOfSamplesInWorkingbpmCoolDownAverage == 119)
                    {
                        //If i is greater than the current numElementToDeleteTo, set numElementToDeleteTo equal to i
                        if (i > numElementToDeleteTo)
                            numElementToDeleteTo = i;
                        
                        workingbpmCoolDownAverage = workingbpmCoolDownSum/numberOfSamplesInWorkingbpmCoolDownAverage;
                        
                        //NSLog (@"bpmSumAverage = %i", bpmSumAverage);
                        //NSLog (@"workingbpmCoolDownAverage = %i", workingbpmCoolDownAverage);
                        
                        int elementAt2MinuteValue = 0;
                        
                        //if workingbpmCoolDownAverage if less than bpmSumAverage - 5...
                        if (workingbpmCoolDownAverage < bpmSumAverage - 5)
                        {
                            //Find the i-Value for the element with the startDate closest to the 2-minute mark after cooldown has started
                            //Iterate betweem i through and i + 120 and break when you find the 'elementAt2MinuteMark' that's closest to the 2-minute mark
                            for (int o = i; o < i + 180; o++)
                                @autoreleasepool
                            {
                                //i-value startDate in seconds (the last value after the previous 60-second high sustained bpm)
                                NSDate *dateI = [[array objectAtIndex:i + 59] startDate];
                                //o-value startDate in seconds
                                NSDate *dateO = [[array objectAtIndex:o] startDate];
                                
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                NSDateComponents *timeDifference = [calendar components:NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                                               fromDate:dateI
                                                                                 toDate:dateO
                                                                                options:0];
                                
                                if (timeDifference.year == 0 && timeDifference.month == 0 && timeDifference.day == 0 && timeDifference.hour == 0 && timeDifference.minute >= 2 && timeDifference.minute < 3)
                                {
                                    elementAt2MinuteValue = o;
                                    break;
                                }
                            }
                            
                            int hrr = 0;
                            
                            //Average the last four values between o through o + 4, with o STARTING at the earliest startDate that's exactly 120 seconds past hrrStartDate
                            hrr = bpmSumAverage - (([[array objectAtIndex: elementAt2MinuteValue] bpm] + [[array objectAtIndex: elementAt2MinuteValue + 1] bpm] + [[array objectAtIndex: elementAt2MinuteValue + 2] bpm] + [[array objectAtIndex: elementAt2MinuteValue + 3] bpm] + [[array objectAtIndex: elementAt2MinuteValue + 4] bpm])/5);
                            
                            // NSLog (@"hrr = %i", hrr);
                            
                            if (hrr >= newHighestHRR)
                            {
                                newHighestHRR = hrr;
                                //  NSLog (@"newHighestHRR = %i", newHighestHRR);
                            }
                            
                            // Used for Debugging: to look at each element that adds up to bpmSumAverage, and
                            //    the last four elements between [elementAt2MinuteValue] through [elementAt2MinuteValue + 4]
                            if (hrr == 77)
                            {
                                for (int j = i; j < i + 180; j++)
                                    @autoreleasepool
                                {
                                    NSLog (@"high %f", [[array objectAtIndex: j] bpm]);
                                    NSLog (@"high time %@", [self convertToLocalTime: [[array objectAtIndex:j] startDate]]);
                                }
                                
                                for (int k = elementAt2MinuteValue; k < elementAt2MinuteValue + 4; k++)
                                    @autoreleasepool
                                {
                                    NSLog (@"low %f", [[array objectAtIndex: k] bpm]);
                                    NSLog (@"low time %@", [self convertToLocalTime: [[array objectAtIndex:k] startDate]]);
                                }
                            }
                        }
                    }
                }
            }
        }
        //Ending of HRR calcuations
        
        //Beginning of code to find Highest Sustained Heart Rate
        for (int i = 0; i < [array count] - 60; i++)
        @autoreleasepool
        {
            breakOutOfLoopHigh = false;
            
            //Verify breakOutOfLoopHigh = false AND 60 samples are contiguous
            while (breakOutOfLoopHigh == false && [self verifySamplesAreChronologicallyContiguous:i numOfIterations:60 array:array])
            @autoreleasepool
            {
                heartRateSumHigh = 0;
                heartRateSumAverageHigh = 0;
                valueHigh1 = 0;
                valueHigh2 = 0;
                numberOfSamplesBeingAddedHigh = 0;
                
                //then add up values from i through i + 60 and divide them by 60 to get the average.  Save this as the 'newHighestSustainedHeartRate' if it's the new highesBefore wholeDayHeartRatesArray count
                for (int j = i; j < i + 60; j++)
                @autoreleasepool
                {
                    //Heart rate value at i
                    valueHigh1 = [[array objectAtIndex:i] bpm];
                    
                    //Heart rate value at j
                    valueHigh2 = [[array objectAtIndex:j] bpm];
                    
                    //Check to make sure j heart rate is not lower than 3bpm above the heartrate at i..
                    //...AND not higher than 3bpm above heartrate i.  Also make sure bpm reading is not 0
                    if ((valueHigh2 > valueHigh1 - 3 && valueHigh2 < valueHigh1 + 3) || (valueHigh1 >= 0 || valueHigh2 >= 0))
                    {
                        heartRateSumHigh += valueHigh2;
                        numberOfSamplesBeingAddedHigh++;
                    }
                    else
                    {
                        breakOutOfLoopHigh = true;
                        break;
                    }
                }
                
                //Only calculate for the newHighestSustainedHeartRate if the number of samples taken is 60
                if (numberOfSamplesBeingAddedHigh == 60)
                {
                    //If i is greater than the current numElementToDeleteTo, set numElementToDeleteTo equal to i
                    if (i > numElementToDeleteTo)
                        numElementToDeleteTo = i;
                    
                    //Divide heartRateSum by 10 to get the average heart rate across the 10 samples
                    heartRateSumAverageHigh = heartRateSumHigh/numberOfSamplesBeingAddedHigh;
                    
                    if (heartRateSumAverageHigh >= currentHeartRateSumAverageHigh)
                    {
                        currentHeartRateSumAverageHigh = heartRateSumAverageHigh;
                        
                        if (currentHeartRateSumAverageHigh > 66)
                        {
                            for (int j = i; j < i + 60; j++)
                            @autoreleasepool {
                                    
                                //NSLog (@"high = %f", [[array objectAtIndex:j] bpm]);
                                //NSLog (@"high %@", [self convertToLocalTime: [[array objectAtIndex:j] startDate]]);
                            }
                        }
                    }
                }
                
                breakOutOfLoopHigh = true;
                break;
            }
        }
        //Ending of code to find Highest Sustained Heart Rate
        
        //Beginning of code to find Lowest Sustained Heart Rate
        for (int i = 0; i < [array count] - 60; i++)
        @autoreleasepool
        {
            breakOutOfLoopLow = false;
            
            //Verify breakOutOfLoopHigh = false AND 60 samples are contiguous
            while (breakOutOfLoopLow == false && [self verifySamplesAreChronologicallyContiguous:i numOfIterations:60 array:array])
            @autoreleasepool
            {                
                heartRateSumLow = 0;
                heartRateSumAverageLow = 0;
                valueLow1 = 0;
                valueLow2 = 0;
                numberOfSamplesBeingAddedLow = 0;
                
                //then add up values from i through i + 60 and divide them by 60 to get the average.  Save this as the 'newLowestSustainedHeartRate' if it's the new lowest
                for (int j = i; j < i + 60; j++)
                @autoreleasepool
                {
                    //Heart rate value at i
                    valueLow1 = [[array objectAtIndex:i] bpm];
                    
                    //Heart rate value at j
                    valueLow2 = [[array objectAtIndex:j] bpm];

                    //Check to make sure j heart rate is not higher than 3bpm above the heartrate at i...
                    //...AND higher than 3bpm below heartrate i
                    if ((valueLow2 < valueLow1 + 3 && valueLow2 > valueLow1 - 3) || (valueLow1 >= 0 || valueLow2 >= 0))
                    {
                        heartRateSumLow += valueLow2;
                        numberOfSamplesBeingAddedLow++;
                    }
                    else
                    {
                        breakOutOfLoopLow = true;
                        break;
                    }
                }
                
                //Only calculate for the newLowestSustainedHeartRate if the number of samples taken is 60
                if (numberOfSamplesBeingAddedLow == 60)
                {
                    //Divide heartRateSum by 10 to get the average heart rate across the 10 samples
                    heartRateSumAverageLow = heartRateSumLow/numberOfSamplesBeingAddedLow;
                    
                    timeStampOfFirstSample = [[array objectAtIndex:i] startDate];
                    
                    lowbpmAvgStartDatePair = [[LowbpmAvgStartDatePair alloc] init];
                    lowbpmAvgStartDatePair->bpmAvg = heartRateSumAverageLow;
                    lowbpmAvgStartDatePair->startDate = timeStampOfFirstSample;
                    
                    [lowBPMAverageTimeStampPairsArray addObject: lowbpmAvgStartDatePair];
                    
                    //If i is greater than the current numElementToDeleteTo, set numElementToDeleteTo equal to i, and heartRateSumAverageLow is less than 100
                    if (i > numElementToDeleteTo && heartRateSumAverageLow < 100)
                        numElementToDeleteTo = i;
                    
                    if (heartRateSumAverageLow <= currentHeartRateSumAverageLow)
                    {
                        newMinSustainedHRLogged = true;
                        currentHeartRateSumAverageLow = heartRateSumAverageLow;

                        if (currentHeartRateSumAverageLow < 30)
                        {
                            for (int j = i; j < i + 60; j++)
                            @autoreleasepool
                            {
                               // NSLog (@"low = %f", [[array objectAtIndex:j] bpm]);
                               // NSLog (@"low %@", [self convertToLocalTime: [[array objectAtIndex:j] startDate]]);
                            }
                        }
                    }
                }
                
                breakOutOfLoopLow = true;
                break;
            }
            
            //At this point RHR, lowHR, and highHR have been determined.  Log the just calculated highest and lowest readings to the history log.
            if (i >= 1 && [self daysBetweenDate: [[array objectAtIndex:i - 1] startDate] andDate:[[array objectAtIndex:i] startDate]] >= 1)
            {
                NSLog (@"Logging highest and lowest to history log.");
                
                //Log highest RHR to history
                [self logReadingsToHistory:[[array objectAtIndex:i - 1] startDate]];
                
                //ResetRHR in user defaults
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MaxSustainedHR"];
                [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"MinSustainedHR"];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MaxHRR"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //Remember this breaks out of the 'for' loop its in, not just the 'if' loop
                break;
            }
            //If it's the same day then relog the day's minHR, maxHR, and HRR
            else
            {
                //Remove last object from history log
                [archivedReadingsArray removeLastObject];
                //Log today's minHR, maxHR, and HRR
                [self logReadingsToHistory:[[array objectAtIndex:i] startDate]];
            }
        }
        //Ending of code to find Lowest Sustained Heart Rate
        
        [self saveWholeDayHeartRatesArrayToDisk];
        
         Used to validate data in lowBPMAverageTimeStampPairsArray
        for (int i = 0; i < [lowBPMAverageTimeStampPairsArray count]; i++)
        @autoreleasepool
         {
            LowbpmAvgStartDatePair *lowBPMAverageTimeStampPair = [lowBPMAverageTimeStampPairsArray objectAtIndex: i];
            NSLog (@"bpm = %i", lowBPMAverageTimeStampPair->bpmAvg);
            NSLog (@"startDate = %@", lowBPMAverageTimeStampPair->startDate);
        }
    }
    
    //Update labels
    //Iterate through lowBPMAverageTimeStampPairs average the two lowest pairs, the higher of the two which is no more than 10bpm higher than the lower one.  If a pair is found set the lower of the two values to self.mainSustainedHeartRate.  Keep looping until you find a pair.
    bool validPairFound = false;
    int lowestBPMAverage1 = 1000;
    int lowestBPMAverage2 = 1000;
    LowbpmAvgStartDatePair *lowbpmAvgStartDatePairTest;
    LowbpmAvgStartDatePair *lowbpmAvgStartDatePair1;
    LowbpmAvgStartDatePair *lowbpmAvgStartDatePair2;
    
    while (validPairFound == false)
    @autoreleasepool{
        
        //Iterate through lowBPMAverageTimeStampPairs to find the lowestAvgBMP
        for (int i = 0; i < [lowBPMAverageTimeStampPairsArray count]; i++)
        @autoreleasepool
        {
            lowbpmAvgStartDatePairTest = [lowBPMAverageTimeStampPairsArray objectAtIndex: i];
            
            if (lowbpmAvgStartDatePairTest->bpmAvg < lowestBPMAverage1)
            {
                lowbpmAvgStartDatePair1 = lowbpmAvgStartDatePairTest;
            }
        }
        
        //Iterate through lowBPMAverageTimeStampPairs again to find a SEPARATE lowestAvgBMP value which has a timestamp of at least 1.5 hours later than the first AND no more than 10bmp than the first value
        for (int i = 0; i < [lowBPMAverageTimeStampPairsArray count]; i++)
        @autoreleasepool
        {
            lowbpmAvgStartDatePairTest = [lowBPMAverageTimeStampPairsArray objectAtIndex: i];
            
            //Make sure the startDates from lowbpmAvgStartDatePair1 and lowbpmAvgStartDatePair2 don't match
            if (lowbpmAvgStartDatePairTest->bpmAvg < lowbpmAvgStartDatePair1->bpmAvg + 10)
            {
                if (lowbpmAvgStartDatePair1->startDate != lowbpmAvgStartDatePair2->startDate)
                {
                    lowbpmAvgStartDatePair2 = lowbpmAvgStartDatePairTest;
                }
            }
        }
        
        //Verify that lowbpmAvgStartDatePair2->startDate is at least 1.5hours ahead of lowbpmAvgStartDatePair1->starDate
        NSDate *lowbpmAvgStartDatePair1StartDate = lowbpmAvgStartDatePair1->startDate;
        NSDate *lowbpmAvgStartDatePair2StartDate = lowbpmAvgStartDatePair2->startDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *timeDifference = [calendar components:NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                       fromDate:lowbpmAvgStartDatePair1StartDate
                                                         toDate:lowbpmAvgStartDatePair2StartDate
                                                        options:0];
        
        //NSLog(@"Difference in date components: %li/%li/%li/%li/%li", timeDifference.second, timeDifference.minute, timeDifference.day, timeDifference.month, timeDifference.year);
        
        if (timeDifference.day < 0 && (timeDifference.hour*60 + timeDifference.minute*1) < 90)
        {
            validPairFound = true;
            self.minSustainedHeartRate =
        }
    }

    //Save max, min, and HRR to NSUserDefaults
    NSLog (@"currentHeartRateSumAverageHigh = %i", currentHeartRateSumAverageHigh);
    NSLog (@"currentHeartRateSumAverageLow = %i", currentHeartRateSumAverageLow);
    NSLog (@"newHighestHRR = %i", newHighestHRR);

    [[NSUserDefaults standardUserDefaults] setInteger:currentHeartRateSumAverageHigh forKey:@"MaxSustainedHR"];
    [[NSUserDefaults standardUserDefaults] setInteger:currentHeartRateSumAverageLow forKey:@"MinSustainedHR"];
    [[NSUserDefaults standardUserDefaults] setInteger:newHighestHRR forKey:@"MaxHRR"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Update instance variables
    self.maxSustainedHeartRate = currentHeartRateSumAverageHigh;
    self.minSustainedHeartRate = currentHeartRateSumAverageLow;
    self.hrrIVar = newHighestHRR;
    
    //Update HR related labels
    self.maxSustainedHeartRateLabel.text = [NSString stringWithFormat: @"%.0d", currentHeartRateSumAverageHigh];
    self.minSustainedHeartRateLabel.text = [NSString stringWithFormat: @"%.0d", currentHeartRateSumAverageLow];
    self.oneMinuteHRR.text = [NSString stringWithFormat: @"%i", newHighestHRR];
    
    //Update last calculated label
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *time = [dateFormatter stringFromDate: currentTime];
    self.lastCalculatedLabel.text = [NSString stringWithFormat: @"Last Updated: %@", time];
    
    //If there is no new hrr, then update the label saying so
    if (newHighestHRR == 0)
        self.oneMinuteHRR.text = [NSString stringWithFormat: @"--"];
    
    //If no reasonable maxSustained and minSustained heart rates are available then update labels stating that
    if (currentHeartRateSumAverageHigh < 10)
    {
        self.maxSustainedHeartRateLabel.text = [NSString stringWithFormat: @"--"];
    }
    if (currentHeartRateSumAverageLow > 300)
    {
        self.minSustainedHeartRateLabel.text = [NSString stringWithFormat: @"--"];
    }
    
    //Blank out 'calculatingStatusLabel'
    self.calculatingStatusLabel.text = [NSString stringWithFormat: @""];
    
    [self updateAssessmentText];
}

-(void) updateAssessmentText
{
    double rhrYesterday;
    double rhrTwoDaysAgo;
    
    //Calculate RHR difference from the last two days
    if ([archivedReadingsArray count] >= 1)
        rhrYesterday = [[archivedReadingsArray lastObject] lowbpm];
    if ([archivedReadingsArray count] >= 2)
        rhrTwoDaysAgo = [[archivedReadingsArray objectAtIndex: [archivedReadingsArray count] - 1] lowbpm];
    
    double hrrYesterday;
    double hrrTwoDaysAgo;
    
    //Calculate HRR difference from the last two days
    if ([archivedReadingsArray count] >= 1)
        hrrYesterday = [[archivedReadingsArray lastObject] hrr];
    if ([archivedReadingsArray count] >= 2)
        hrrTwoDaysAgo = [[archivedReadingsArray objectAtIndex: [archivedReadingsArray count] - 1] hrr];
    
    NSString *maxSustainedHeartRateComment;
    NSString *minSustainedHeartRateComment;
    NSString *hrrComment;
    NSString *funFactComment;
    
    //NSLog (@"archivedReadingsArray count = %li", [archivedReadingsArray count]);
    //NSLog (@"rhrTwoDaysAgo = %f", rhrTwoDaysAgo);
    
    //Tell them how close they got to their max hrr today
    if (self.maxSustainedHeartRate > 120)
    {
        maxSustainedHeartRateComment = [NSString stringWithFormat: @"You sustained a high of %.0fbpm heart rate during exercise today.  Your calculated recommended MAXIMUM heart rate is %ibpm.", self.maxSustainedHeartRate, [self usersRecommendedMaxHeartRate]];
    }
    else
    {
        maxSustainedHeartRateComment = [NSString stringWithFormat: @"It doesn't look like you've exercised today :("];
    }
    
    //If rhr is 6 or higher from the previous day, bring it up.
    if (self.minSustainedHeartRate >= rhrYesterday + 6 && rhrYesterday > 0)
    {
        minSustainedHeartRateComment = [NSString stringWithFormat: @"Your resting heart rate is a bit higher today than it was yesterday.  You might be overtraining or getting sick."];
    }
    else
    {
        minSustainedHeartRateComment = [NSString stringWithFormat: @""];
    }
    
    //If not overtraining and maxSustainedHR is lower than like 120, then tell them to work out to have their 2-Min HRR measured
    if ((self.minSustainedHeartRate < rhrYesterday + 6) && self.maxSustainedHeartRate < 120)
    {
        hrrComment = [NSString stringWithFormat: @"If you exercise today, I'll measure your 2-minute heart rate recovery for you."];
    }
    else
    {
        hrrComment = [NSString stringWithFormat: @""];
    }
    
    double genderbpmOffset = 0;
    //Girl
    if ([self usersBiologicalSex] == 1)
    {
        genderbpmOffset = 5;
    }
    //Guy
    else if ([self usersBiologicalSex] == 2)
    {
        genderbpmOffset = 0;
    }
    
    //TO DO, instead of minSustainedHeartRate, average the 3 lowest bpm in archived array over the last 14 readings
    if (self.minSustainedHeartRate < 45 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are as or more fit than about 95%% of the people in the world."];
    }
    else if (self.minSustainedHeartRate >= 45 + genderbpmOffset && self.minSustainedHeartRate < 50 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are more fit than 85%% of the people in the world."];
    }
    else if (self.minSustainedHeartRate >= 50 + genderbpmOffset && self.minSustainedHeartRate < 55 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are more fit than 75%% of the people in the world."];
    }
    else if (self.minSustainedHeartRate >= 55 + genderbpmOffset && self.minSustainedHeartRate < 60 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are more fit than 65%% of the people in the world."];
    }
    else if (self.minSustainedHeartRate >= 60 + genderbpmOffset && self.minSustainedHeartRate < 65 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are more fit than 55%% of the people in the world."];
    }
    else if (self.minSustainedHeartRate >= 65 + genderbpmOffset)
    {
        funFactComment = [NSString stringWithFormat: @"Fun Fact: Your resting heart rate indicates you are as or less fit as 45%% of the people in the world."];
    }
    
    NSMutableString *recommendationString = [[NSMutableString alloc] init];
    
    if (maxSustainedHeartRateComment.length > 0)
        [recommendationString appendString: [NSString stringWithFormat: @"%@\n\n", maxSustainedHeartRateComment]];
    
    NSLog (@"recommendationString length = %li", recommendationString.length);
    
    if (hrrComment.length > 0)
        [recommendationString appendString: [NSString stringWithFormat: @"%@\n\n", hrrComment]];
    
    if (minSustainedHeartRateComment.length > 0)
        [recommendationString appendString: [NSString stringWithFormat: @"%@\n\n", minSustainedHeartRateComment]];
    
    if (funFactComment.length > 0)
        [recommendationString appendString: [NSString stringWithFormat: @"%@", funFactComment]];
    
    self.assessmentTextView.text = recommendationString;
}

-(int) usersRecommendedMaxHeartRate
{
    int usersAge = [self usersAge];
    int gender = [self usersBiologicalSex];
    
    //Girl
    if (gender == 1)
    {
        return 216 - (1.09 * usersAge);
    }
    //Guy
    else if (gender == 2)
    {
        return 202 - (0.55 * usersAge);
    }
    else
    {
        return 0;
    }
}

-(int) usersAge {
    
    NSError *error;
    NSDate *dateOfBirth = [healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
        
        return 0;
    }
    
    else {
        // Compute the age of the user.
        NSDate *now = [NSDate date];
        
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        
        NSUInteger usersAge = [ageComponents year];
        
        return (int)usersAge;
    }
}

-(int) usersBiologicalSex
{
    NSError *error = nil;
    HKBiologicalSexObject *sex = [healthStore biologicalSexWithError:&error];
    
    return sex.biologicalSex;
}

-(void) calcAndDisplayFitnessLevel
{
    fitnessLevelNum = 10;

    double genderbpmOffset = 0;
    //Girl
    if ([self usersBiologicalSex] == 1)
    {
        genderbpmOffset = 5;
    }
    //Guy
    else if ([self usersBiologicalSex] == 2)
    {
        genderbpmOffset = 0;
    }
    
    //Subtract points if minSustainedHeartRate exists, else return 0
    if (self.minSustainedHeartRate < 10)
    {
        self.calculatingStatusLabel.text = [NSString stringWithFormat: @"RHR Missing"];
        [self.calculatingStatusLabel setFont: [UIFont systemFontOfSize:35]];
        return;
    }
    else
    {
        if (self.minSustainedHeartRate < 45 + genderbpmOffset)
        {
            fitnessLevelNum -= 0;
        }
        else if (self.minSustainedHeartRate >= 45 + genderbpmOffset && self.minSustainedHeartRate < 50 + genderbpmOffset)
        {
            fitnessLevelNum -= 1;
        }
        else if (self.minSustainedHeartRate >= 50 + genderbpmOffset && self.minSustainedHeartRate < 55 + genderbpmOffset)
        {
            fitnessLevelNum -= 2;
        }
        else if (self.minSustainedHeartRate >= 55 + genderbpmOffset && self.minSustainedHeartRate < 60 + genderbpmOffset)
        {
            fitnessLevelNum -= 3;
        }
        else if (self.minSustainedHeartRate >= 60 + genderbpmOffset && self.minSustainedHeartRate < 65 + genderbpmOffset)
        {
            fitnessLevelNum -= 4;
        }
        else if (self.minSustainedHeartRate >= 65 + genderbpmOffset)
        {
            fitnessLevelNum -= 5;
        }
    }
    
    //Subtract points for HRR exists, else return
    if (self.hrrIVar == 0)
    {
        self.calculatingStatusLabel.text = [NSString stringWithFormat: @"HRR Missing"];
        [self.calculatingStatusLabel setFont: [UIFont systemFontOfSize:27]];
        return;
    }
    else
    {
        if (self.hrrIVar > 60)
        {
            fitnessLevelNum -= 0;
        }
        else if (self.hrrIVar >= 50 && self.hrrIVar < 59)
        {
            fitnessLevelNum -= 1;
        }
        else if (self.hrrIVar >= 40 && self.hrrIVar < 50)
        {
            fitnessLevelNum -= 2;
        }
        else if (self.hrrIVar >= 30 && self.hrrIVar < 40)
        {
            fitnessLevelNum -= 3;
        }
        else if (self.hrrIVar >= 20 && self.hrrIVar < 30)
        {
            fitnessLevelNum -= 4;
        }
        else if (self.hrrIVar <= 19)
        {
            fitnessLevelNum -= 5;
        }
    }
    
    if (fitnessLevelNum == 0)
        fitnessLevelNum = 1;
    
    //If RHR and HRR are available, calc and display fitness level
    self.calculatingStatusLabel.text = [NSString stringWithFormat: @"Fitness Level: %.0f/10", fitnessLevelNum];
    [self.calculatingStatusLabel setFont: [UIFont systemFontOfSize:35]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
