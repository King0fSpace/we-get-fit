//
//  ChallengesViewController.h
//  We Get Fit
//
//  Created by Long Le on 10/23/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#define		HEADER_THICKNESS			25		//thickenss of the thin header placed above the winners and table view


#import "UsersViewController.h"
#import "PersonHealthStatsQuickViewCell.h"
#import "HomeView.h"
#import "RulesViewController.h"

@interface ChallengesViewController : HomeView

@property BOOL userAlreadyShownInList;
@property UIView *whiteListBlockoutView;

-(int) dayOfTheWeek;
-(void)addGrayChallengeDayBar;

@end
