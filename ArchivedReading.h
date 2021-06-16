//
//  ArchivedReading.h
//  Fitness
//
//  Created by Long Le on 11/6/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <Foundation/Foundation.h>

//Create object to hold date, high, low, and HRR for a particular day
@interface ArchivedReading : NSObject <NSCoding>
{
    NSDate *lastUpdated;
    NSString *userObjectId;
    float listRankingScore;
    float yesterdaysListRankingScore;
    float moveGoal;
    NSString *usersFullName;
}
@property(nonatomic) NSDate *lastUpdated;
@property(nonatomic) BOOL updatedToday;
@property(nonatomic) NSString *userObjectId;
@property(nonatomic) float listRankingScore;
@property(nonatomic) float yesterdaysListRankingScore;
@property(nonatomic) float moveGoal;
@property(nonatomic) NSString *usersFullName;

@end


