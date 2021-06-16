//
//  HomeViewPhotoCell.m
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "ActivityCell.h"
//#import "PAPUtility.h" <-imported in Anypic


@implementation ActivityCell

@synthesize uploaderPhoto;
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
@synthesize thisWeekDelimiterLabel;
@synthesize fitnessLevelDelimiterLabel;

@synthesize fitnessLevelBarView;

@synthesize uploadPhotoButton;

@synthesize userPersonalStats;

@synthesize numOfLikesInt;


#pragma mark - NSObject


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        numOfLikesInt = 0;
        
        self.opaque = NO;
        self.selectionStyle = UITableViewCellStyleDefault;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(0.0f, 95.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width/2);
}



@end
