//
//  PageContentViewController.h
//  Fitness
//
//  Created by Long Le on 10/15/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LowbpmAvgStartDatePair.h"
#import "ArchivedReading.h"

@import UIKit;
@import HealthKit;

HKHealthStore *healthStore;

@interface PageContentViewController : UIViewController 

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *title;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSMutableArray *wholeDayHeartRatesArray;
@property (nonatomic) NSMutableArray *wholeDayHeartRatesToDeleteArray;
@property (nonatomic) NSMutableArray *lowBPMAverageTimeStampPairsArray;
@property (nonatomic) NSMutableArray *elementsToRemoveArray;
@property (nonatomic) NSMutableArray *archivedReadingsArray;


//This array contains the first element of every lowAverageHeartRate sample.  The objects in the array can be used to determine the timeStamp value which is the beginning of every 30sample lowAverageHeartRate value

@property (nonatomic) long int lastAnchor;

@property (nonatomic) double maxHeartRate;
@property (nonatomic) double minHeartRate;
@property (weak, nonatomic) IBOutlet UILabel *maxHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *minHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fitnessLevelLabel;


@property (nonatomic) double maxSustainedHeartRate;
@property (nonatomic) double minSustainedHeartRate;
@property (nonatomic) double fitnessLevelNum;
@property (nonatomic) double hrrIVar;
@property (weak, nonatomic) IBOutlet UILabel *maxSustainedHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *minSustainedHeartRateLabel;
@property (nonatomic) int currentHeartRateSumAverageHigh;
@property (nonatomic) int currentHeartRateSumAverageLow;
@property (nonatomic) int newHighestHRR;

@property (nonatomic) IBOutlet UILabel *calculatingStatusLabel;
@property (nonatomic, strong) NSTimer *myTimer;

@property (weak, nonatomic) IBOutlet UILabel *oneMinuteHRR;

@property(nonatomic) int numElementToDeleteTo;

@property (nonatomic) BOOL isNewDay;

@property (assign, nonatomic) NSInteger index;

@property (weak, nonatomic) IBOutlet UITextView *assessmentTextView;

@property (strong, nonatomic) IBOutlet UILabel *lastCalculatedLabel;

-(int) usersBiologicalSex;
-(int) usersAge;
-(int) usersRecommendedMaxHeartRate;
-(void) convertHKUnitToHRReadingAndCopyToNewArray: (NSArray*)oldArrayArg newArray:(NSMutableArray*)newArrayArg;
-(void) updateCalculatingLabel;
-(void) updateLowestAndHighestHeartRatesInArray: (NSMutableArray *)array;
-(NSString*) convertToLocalTime: (NSDate*)dateArg;


@end
