//
//  UserDashboardView.m
//  We Get Fit
//
//  Created by Long Le on 4/23/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "UserDashboardView.h"

@implementation UserDashboardView

@synthesize labelElapsed;
@synthesize uploaderName;
@synthesize updatedAt;
@synthesize timeIntervalFormatter;
@synthesize likeButton;

@synthesize photoButton;
@synthesize photoCaption;

@synthesize blueCircleView;
@synthesize blueCircleStepsLabel;
@synthesize blueCircleNumOfStepsTodayLabel;
@synthesize blueCircleSmallStepsLabel;

@synthesize redCircleView;
@synthesize redCircleExerciseLabel;
@synthesize redCircleMinOfExerciseTodayLabel;
@synthesize redCircleSmallMinLabel;

@synthesize orangeCircleView;
@synthesize orangeCircleCaloriesLabel;
@synthesize orangeCircleNumOfCaloriesTodayLabel;
@synthesize orangeCircleSmallMinLabel;

@synthesize blueBarView;
@synthesize grayBarForBlueBarView;
@synthesize redBarView;
@synthesize grayBarForRedBarView;
@synthesize orangeBarView;
@synthesize grayBarForOrangeBarView;

@synthesize todayDelimiterLabel;
@synthesize updatingLabel;
@synthesize thisWeekDelimiterLabel;
@synthesize fitnessLevelDelimiterLabel;
@synthesize followButton;
@synthesize flagButton;
@synthesize chatButton;

@synthesize fitnessLevelBarView;
@synthesize grayBarForFitnessLevelBarView;
@synthesize fitnessRatingForBarLabel;

@synthesize uploadPhotoButton;

@synthesize userPersonalStats;

@synthesize numOfLikesInt;
@synthesize friendsLabel;
@synthesize followingLabel;
@synthesize followersLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}

@end
