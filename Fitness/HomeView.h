//
//  FriendsView.h
//  Fitness
//
//  Created by Long Le on 4/7/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "UsersViewController.h"
#import "PersonHealthStatsQuickViewCell.h"

@interface HomeView : PFQueryTableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property UITextField *listDisplayedTextField;
@property UIPickerView *myPickerView;
@property NSMutableArray *listsArray;
@property UIView *pickerToolBarView;
@property NSString *homeCurrentListSelectedString;
@property NSMutableArray *mySortedObjects;
@property UILabel *todaysActivityLabel;

-(void) addPhotoFooter: (PersonHealthStatsQuickViewCell *)cell threeLetterCountryCode:(NSString*)threeLetterCountryCodeArg;
-(int) numOfSteps: (PFObject*)object;
-(int) minutesOfExercise: (PFObject*)object;
-(int) caloriesBurned: (PFObject*)object;
-(BOOL) isNSDateToday: (NSDate*)dateToCheckArg;

@end
