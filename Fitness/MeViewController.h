//
//  MeViewController.h
//  Fitness
//
//  Created by Long Le on 3/8/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"
#import "ActivityCell.h"
#import "UserProfileCell.h"
#import "AppConstant.h"
#import "HealthMethods.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Cache.h"
#import "PhotoFooterView.h"
#import "Utility.h"
#import "UserDashboardView.h"
#import "HKHealthStore+AAPLExtensions.h"
#import "messages.h"
#import "utilities.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "ChatView.h"
#import <AddressBook/AddressBook.h>
#import "EditYourProfileViewController.h"
#import "FriendsListViewController.h"
#import "FollowingListViewController.h"
#import "FollowersListViewController.h"
#import "MyLoginViewController.h"
#import "PhotoDetailsViewController.h"
#import "WhyHealthKitViewController.h"


@protocol PAPTabBarControllerDelegate;

@interface MeViewController : PFQueryTableViewController <PhotoFooterViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSString *title;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property UserDashboardView *dashboardView;
@property PFObject *userObject;
@property NSInteger viewOffset;
@property BOOL currentViewIsNonRootView;
@property UIPickerView *myPickerView;
@property NSMutableArray *listsArray;
@property UIView *pickerToolBarView;
@property UIActivityIndicatorView *progressIndicator;
@property UIButton *shareHealthDataButton;
@property UITextView *askToShareData;
@property UITextView *calculatingFitnessRatingLabel;
@property UITextView *askUserToShareDataLabel;
@property int numOfDaysWatchWasWorn;    //Used to determine what the divisor should be when calculating steps, cals, exericse minutes
@property UITextView *userEditableTextField;
@property NSMutableArray *facebookFriendsObjectIdsArray;

-(BOOL)shouldPresentPhotoCaptureController;
-(void)setPassedInUser:(PFObject *)object;
-(void)addDashboardView;
-(void)populateUserDashboardView;
-(void)shareHealthDataOrCreateButton;

-(void)addColoredCircles;
-(void)addBlueCircle: (PFObject *)object;
-(void)addRedCircle: (PFObject *)object;
-(void)addOrangeCircle: (PFObject *)object;
-(void) addTodayDelimiterLabel;
-(void) updateTodayDelimiterLabel;

-(void)addBlueBar:(PFObject *)object;
-(void)addRedBar:(PFObject *)object;
-(void)addOrangeBar:(PFObject *)object;
-(void)addThisWeekDelimiterLabel:(PFObject *)object;
-(void)addFitnessLevelBar:(PFObject *)object;
-(void)addFitnessLevelDelimiterLabel:(PFObject *)object;

-(BOOL)allHealthDataSharedByUser;
-(void)userObjectSavedToList:(NSInteger)row;

-(NSInteger)usersAge;
-(BOOL)isFirstTimeHealthQueriesBeingRunToday;
-(void)shiftHealthStatsDownADayInParse;
-(void)shiftHeartRatesDownADayInParse;
-(NSString*)todaysDateFormatted;
-(NSString*)todaysDateFormattedNSDate;
-(int)numberOfDaysBetweenQueryLastRunAndNow;
-(NSDate*)todaysDateNSDate;
-(void)createEditYourProfileButton;

-(int) sevenDayAvgNumOfSteps: (PFObject*)object;
-(int) sevenDayAvgMinutesOfExercise: (PFObject*)object;
-(int) sevenDayAvgCaloriesBurned: (PFObject*)object;

-(void)localNotificationForWorkoutMotivation;
-(void)dialogueBoxForWorkoutMotivation;
-(void) setTodaysActivityLabel;
-(void)callHealthQueries;
-(void) updateDashboardAndColoredCircles;


@property int numberOfFriends;
@property int numberOfPeopleYouAreFollowing;
@property int numberOfFollowers;
@property NSMutableArray *friendsObjectIdArray;
@property UILabel *usernameLabel;

@property CLLocation *currentLocation;
@property CLLocationManager *locationManager;

@property UILabel *navControllerTitleLabel;


-(void)displayShareDataRequest;

@end



@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;
-(void)followButtonTapped:(UIButton*)sender;
-(void)shareHealthDataButtonTapped;


@end