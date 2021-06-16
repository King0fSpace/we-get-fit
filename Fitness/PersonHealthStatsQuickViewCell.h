//
//  FriendsViewPhotoCell.h
//  Fitness
//
//  Created by Long Le on 4/7/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface PersonHealthStatsQuickViewCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;

@property UIView *squareNumberView;
@property UILabel *squareNumberLabel;

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

@property UILabel *friendRequestLabel;
@property UIButton *acceptButton;
@property UIButton *rejectButton;

@property UILabel *footer;



@end
