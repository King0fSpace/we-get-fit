//
//  HomeViewPhotoCell.h
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "AppConstant.h"
#import "Constants.h"
#import "TTTTimeIntervalFormatter.h"


@protocol HomeViewPhotoCellDelegate;


@interface ActivityCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;

@property (strong, nonatomic) PFImageView *uploaderPhoto;
@property (strong, nonatomic) UILabel *labelElapsed;
@property (strong, nonatomic) UILabel *uploaderName;
@property (strong, nonatomic) UILabel *updatedAt;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;


NSString* TimeElapsed(NSTimeInterval seconds);

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

@property UILabel *fitnessLevelLabel;
@property UILabel *photoCaption;

@property UIView *blueCircleView;
@property UILabel *blueCircleStepsLabel;
@property UILabel *blueCircleNumOfStepsTodayLabel;
@property UILabel *blueCircleSmallStepsLabel;

@property UIView *redCircleView;
@property UILabel *redCircleExerciseLabel;
@property UILabel *redCircleMinOfExerciseTodayLabel;
@property UILabel *redCircleSmallMinLabel;

@property UIView *orangeCircleView;
@property UILabel *orangeCircleCaloriesLabel;
@property UILabel *orangeCircleNumOfCaloriesTodayLabel;
@property UILabel *orangeCircleSmallMinLabel;

@property UIView *blueBarView;
@property UIView *grayBarForBlueBarView;
@property UIView *redBarView;
@property UIView *grayBarForRedBarView;
@property UIView *orangeBarView;
@property UIView *grayBarForOrangeBarView;

@property UILabel *todayDelimiterLabel;
@property UILabel *thisWeekDelimiterLabel;
@property UILabel *fitnessLevelDelimiterLabel;

@property UIView *fitnessLevelBarView;

@property UIButton *uploadPhotoButton;

@property UITextView *userPersonalStats;

@property UIButton *likeButton;

@property int numOfLikesInt;

- (void)didTapLikePhotoButtonAction:(UIButton *)button;
-(void)shouldEnableLikeButton:(BOOL)enable;


@end

