//
//  UsersViewController.h
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "PhotoCell.h"
#import "MeViewController.h"


@interface UsersViewController : PFQueryTableViewController <UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *loadedUsersArray;
@property PFObject *passedInUserObject;
@property NSInteger viewOffset;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

-(int) sevenDayAvgMinutesOfExercise: (PFObject*)object;
-(int) sevenDayAvgNumOfSteps: (PFObject*)object;
-(int) sevenDayAvgCaloriesBurned: (PFObject*)object;

@end
