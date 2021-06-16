//
//  PhotoCell.h
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>


#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)


@interface PhotoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;

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

@property UILabel *footer;


/*
@property (nonatomic, strong) UIButton *photoButton2;
@property (nonatomic, strong) UIButton *photoButton3;
@property (nonatomic, strong) UIButton *photoButton4;


@property (nonatomic, strong) PFImageView *imageView1;
@property (nonatomic, strong) PFImageView *imageView2;
@property (nonatomic, strong) PFImageView *imageView3;
@property (nonatomic, strong) PFImageView *imageView4;
*/

@end
