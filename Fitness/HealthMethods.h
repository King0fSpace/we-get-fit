//
//  HealthMethods.h
//  Fitness
//
//  Created by Long Le on 3/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
//#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "NotificationsView.h"
#import "ArchivedReading.h"

int const allowHRRelatedQueries =  NO;

@import HealthKit;

@interface HealthMethods : NSObject

@property (nonatomic) NSMutableArray *yesterdaysStepSamplesArray;
@property (nonatomic) NSMutableArray *twoDaysAgoStepSamplesArray;
@property (nonatomic) NSMutableArray *threeDaysAgoStepSamplesArray;
@property (nonatomic) NSMutableArray *fourDaysAgoStepSamplesArray;
@property (nonatomic) NSMutableArray *fiveDaysAgoStepSamplesArray;
@property (nonatomic) NSMutableArray *sixDaysAgoStepSamplesArray;

@property (nonatomic) NSMutableArray *todaysHeartRatesArray;
@property (nonatomic) NSMutableArray *yesterdaysHeartRatesArray;
@property (nonatomic) NSMutableArray *twoDaysAgoHeartRatesArray;
@property (nonatomic) NSMutableArray *threeDaysAgoHeartRatesArray;
@property (nonatomic) NSMutableArray *fourDaysAgoHeartRatesArray;
@property (nonatomic) NSMutableArray *fiveDaysAgoHeartRatesArray;
@property (nonatomic) NSMutableArray *sixDaysAgoHeartRatesArray;
@property (nonatomic) NSMutableArray *heartRatesForDateRangeArray;

@property (nonatomic) NSMutableArray *lastSixDaysWorthOfWorkoutsArray;

@property (nonatomic) NSInteger todaysMinOfExercise;
@property (nonatomic) float todaysCaloriesBurned;



@property (nonatomic) BOOL userSharedStepsData;
@property (nonatomic) NSMutableArray *dataSources;
@property (nonatomic) NSSet *sourcesSet;
@property (nonatomic) NSPredicate *iPhoneSourcePredicate;
@property (nonatomic) NSPredicate *appleWatchSourcePredicate;

@property (nonatomic) NSMutableArray *archivedReadingsArray;

@property (nonatomic) double workoutCreditMultiplierDouble;




-(void)queryTotalStepsForToday: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit;
-(void) calculateFitnessRating: (PFQueryTableViewController*)pfTableView completion:(void (^)(double, NSError *))completionHandler;

//Workout queries
-(void)queryMinutesOfWorkoutsForToday: (PFQueryTableViewController*)pfTableView;
-(void)queryMinutesOfWorkoutsForYesterday: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
-(void)queryMinutesOfWorkoutsForTwoDaysAgo: (PFQueryTableViewController*)pfTableView completion:(void (^)(double, NSError *))completionHandler;
-(void)queryMinutesOfWorkoutsForThreeDaysAgo: (PFQueryTableViewController*)pfTableView completion:(void (^)(double, NSError *))completionHandler;
-(void)queryMinutesOfWorkoutsForFourDaysAgo: (PFQueryTableViewController*)pfTableView completion:(void (^)(double, NSError *))completionHandler;
-(void)queryMinutesOfWorkoutsForFiveDaysAgo: (PFQueryTableViewController*)pfTableView completion:(void (^)(double, NSError *))completionHandler;

//Calorie Queries
- (void)queryTotalCaloriesBurnedForToday: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedOneDayAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedTwoDaysAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedThreeDaysAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedFourDaysAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedFiveDaysAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryTotalCaloriesBurnedSixDaysAgo: (PFQueryTableViewController*)pfTableView unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;

//Step sample queries
- (void)queryAllOfYesterdaysStepSamples: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfTwoDaysAgoStepSamples: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;


//Heartrate Queries
- (void)queryAllOfTodaysHeartRates:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfYesterdaysHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfTwoDaysAgoHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfThreeDaysAgoHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfFourDaysAgoHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfFiveDaysAgoHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;
- (void)queryAllOfSixDaysAgoHeartRates: (PFQueryTableViewController*)viewController unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;

//Method called when the last query runs which determines whether or not the user had shared health data
-(BOOL)userSharedHealthData;

//User's biological stats query
-(void)saveUsersHeightToParse;
- (void)saveUsersWeightToParse;

-(NSString*) convertToLocalTime: (NSDate*)dateArg;
-(NSDate *) convertToGlobalTime: (NSDate*)utcTimeArg;
-(BOOL) isNSDateToday: (NSDate*)dateToCheckArg;
-(void)calculateTimeRelativeToUserListRankingScore;

-(NSString *)determineProperPushNotificationMessage:(NSArray*)newestFriendsFitnessDataArray;

-(void) sendAppropriateCompetitiveNotificationMessage;
-(void) sendAppropriateCompetitiveNotificationMessage: (NSDate*)dateArg;
-(void) saveFriendsListRankingScoreToDisk: (void (^)(double, NSError *))completionHandler;
-(void)localNotificationForWorkoutMotivation: (UIViewController*)viewControllerArg;
-(void)dialogueBoxForWorkoutMotivation: (UIViewController*)viewControllerArg;
- (void) readArchivedReadingsArrayFromDisk;
- (void) readArchivedReadingsArrayFromDisk: (NSDate*)dateArg;
-(void)queryTotalNumberOfWorldChallengers: (void (^)(double, int, int, NSError *))completionHandler;
-(void)queryTotalNumberOfFacebookFriendsChallengers: (void (^)(double, int, int, NSError *))completionHandler;



@end
