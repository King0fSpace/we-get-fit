//
//  ArchivedReading.m
//  Fitness
//
//  Created by Long Le on 11/6/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "ArchivedReading.h"

@implementation ArchivedReading
@synthesize lastUpdated, updatedToday, userObjectId, listRankingScore, yesterdaysListRankingScore, usersFullName;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:lastUpdated forKey:@"lastUpdated"];
    [encoder encodeBool:updatedToday forKey:@"updatedToday"];
    [encoder encodeObject:userObjectId forKey:@"userObjectId"];
    [encoder encodeDouble:listRankingScore forKey:@"listRankingScore"];
    [encoder encodeDouble:yesterdaysListRankingScore forKey:@"yesterdaysListRankingScore"];
    [encoder encodeDouble:moveGoal forKey:@"moveGoal"];
    [encoder encodeObject:usersFullName forKey:@"full_name"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.lastUpdated = [coder decodeObjectForKey:@"lastUpdated"];
    self.updatedToday = [coder decodeBoolForKey:@"updatedToday"];
    self.userObjectId = [coder decodeObjectForKey:@"userObjectId"];
    self.listRankingScore = [coder decodeDoubleForKey:@"listRankingScore"];
    self.yesterdaysListRankingScore = [coder decodeDoubleForKey:@"yesterdaysListRankingScore"];
    self.moveGoal = [coder decodeDoubleForKey:@"moveGoal"];
    self.usersFullName = [coder decodeObjectForKey:@"full_name"];
    return self;
}

@end
