//
//  UserDashboardView.h
//  We Get Fit
//
//  Created by Long Le on 4/23/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TTTTimeIntervalFormatter.h"

@interface UserDashboardView : UIView


@property (nonatomic, strong) UIButton *photoButton;

@property (strong, nonatomic) UIImageView *uploaderPhoto;
@property (strong, nonatomic) UILabel *labelElapsed;
@property (strong, nonatomic) UILabel *uploaderName;
@property (strong, nonatomic) UILabel *updatedAt;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property UIButton *followButton;
@property UIButton *flagButton;
//@property UIButton *addToListButton;
@property UIButton *chatButton;


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
@property UILabel *updatingLabel;
@property UILabel *thisWeekDelimiterLabel;
@property UILabel *fitnessLevelDelimiterLabel;

@property UIView *fitnessLevelBarView;
@property UIView *grayBarForFitnessLevelBarView;
@property UILabel *fitnessRatingForBarLabel;

@property UIButton *uploadPhotoButton;

@property UITextView *userPersonalStats;

@property UIButton *likeButton;

@property int numOfLikesInt;
@property UILabel *friendsLabel;
@property UILabel *followingLabel;
@property UILabel *followersLabel;
@property UILabel *numberOfFriendsLabel;
@property UILabel *numberOfFollowingLabel;
@property UILabel *numberOfFollowersLabel;

@end
