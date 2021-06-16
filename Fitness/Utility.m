//
//  PAPUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "Utility.h"
#import "UIImage+ResizeAdditions.h"

@implementation Utility


#pragma mark - PAPUtility
#pragma mark Like Photos

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:photo forKey:kPAPActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [Utility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[Cache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [Utility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[Cache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}


#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    NSLog(@"Processing profile picture of size: %@", @(newProfilePictureData.length));
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    NSLog(@"Processed profile picture");
}
/*
+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    // Check that PFUser has valid fbid that matches current FBSessions userId
    NSString *facebookId = [user objectForKey:kPAPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0 && [facebookId isEqualToString:[[[PFFacebookUtils session] accessTokenData] userID]]);
}
*/
+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPAPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"AvatarPlaceholderBig.png"];
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}









#pragma mark User Friending

+ (void)friendUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *friendActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [friendActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [friendActivity setObject:user forKey:kPAPActivityToUserKey];
    [friendActivity setObject:@"friend" forKey:kPAPActivityTypeKey];
    
    PFACL *friendACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [friendACL setPublicReadAccess:YES];
    [friendACL setPublicWriteAccess:YES];
    friendActivity.ACL = friendACL;
    
    [friendActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[Cache sharedCache] setFriendStatus:YES user:user];
}

+ (void)friendUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *friendActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [friendActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [friendActivity setObject:user forKey:kPAPActivityToUserKey];
    [friendActivity setObject:@"friend" forKey:kPAPActivityTypeKey];
    
    PFACL *friendACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [friendACL setPublicReadAccess:YES];
    [friendACL setPublicWriteAccess:YES];
    friendActivity.ACL = friendACL;
    
    [friendActivity saveEventually:completionBlock];
    [[Cache sharedCache] setFriendStatus:YES user:user];
}

+ (void)friendUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [Utility friendUserEventually:user block:completionBlock];
        [[Cache sharedCache] setFriendStatus:YES user:user];
    }
}

+ (void)unfriendUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query whereKey:kPAPActivityTypeKey equalTo:@"friend"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendActivities, NSError *error) {
        // While normally there should only be one friend activity returned, we can't guarantee that.
        
        if (!error)
        {
            for (PFObject *friendActivity in friendActivities)
            {
                [friendActivity deleteEventually];
            }
        }
    }];
    [[Cache sharedCache] setFriendStatus:NO user:user];
}

+ (void)unfriendUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:@"friend"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[Cache sharedCache] setFriendStatus:NO user:user];
    }
}

+ (void)rejectFriendRequestEventually:(PFUser *)user tableViewController:(PFQueryTableViewController *)tableViewController tableView:(UITableView*)tableView {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:user];
    [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityTypeKey equalTo:@"friend"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendActivities, NSError *error) {
        // While normally there should only be one friend activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *friendActivity in friendActivities) {
                [friendActivity deleteEventually];
            }
        }
        
        [tableViewController loadObjects];
        [tableView reloadData];
    }];
    [[Cache sharedCache] setFriendStatus:NO user:user];
}

#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setPublicWriteAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[Cache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    NSLog (@"followUserEventually in Utility called!");
    
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    //Add friend to friendsObjectIdArray
    NSMutableArray *friendsObjectIdArray = [[NSMutableArray alloc] init];
    friendsObjectIdArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsObjectIdArray"];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObjectsFromArray:friendsObjectIdArray];
    NSString *friendObjectIdString = [NSString stringWithFormat:@"%@",user.objectId];
    [tempArray addObject: friendObjectIdString];
    
    //Save array to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"friendsObjectIdArray"];
    NSLog (@"adding object to friendsObjectIdArray count = %li", [tempArray count]);
    
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:@"Following" forKey:@"saved_to_list"];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setPublicWriteAccess:YES];
    followActivity.ACL = followACL;

    [[Cache sharedCache] setFollowStatus:YES user:user];
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //Check if the user is also following you.  If so set the object's 'FriendStatus field as 'Friends.  Do the same to the object where the 'toUser' and 'fromUser' are vice versa.
        PFQuery *queryIfUserIsAlsoFollowingYou = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryIfUserIsAlsoFollowingYou whereKey:@"fromUser" equalTo:user];
        [queryIfUserIsAlsoFollowingYou whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [queryIfUserIsAlsoFollowingYou whereKey:@"saved_to_list" equalTo:@"Following"];
        [queryIfUserIsAlsoFollowingYou findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 for (PFObject *object in objects)
                 {
                     //You are following target, so set the 'FriendStatus' field as 'Friends' for respective object
                     [followActivity setObject:@"Friends" forKey:@"FriendStatus"];
                     [followActivity saveInBackground];
                     
                     //Target user is also following you, so set the 'FriendStatus' field as 'Friends' for respective object
                     [object setObject:@"Friends" forKey:@"FriendStatus"];
                     [object saveInBackground];
                 }
             }
             else
             {
                 NSLog (@"Error attempting to find out if target user is also following you while trying to follow them.");
             }
         }];
    }];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [Utility followUserEventually:user block:completionBlock];
        [[Cache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    
    NSLog (@"unfollowUserEventually in Utility called!");
    
    //Remove friend to friendsObjectIdArray
    NSMutableArray *friendsObjectIdArray = [[NSMutableArray alloc] init];
    friendsObjectIdArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsObjectIdArray"];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObjectsFromArray:friendsObjectIdArray];
    
    NSString *friendObjectIdString = [NSString stringWithFormat:@"%@",user.objectId];
    [tempArray removeObject: friendObjectIdString];
    
    //Save array to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:@"friendsObjectIdArray"];
    NSLog (@"removing object to friendsObjectIdArray count = %li", [tempArray count]);
    
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error)
        {
            for (PFObject *followActivity in followActivities)
            {
                if ([followActivity objectForKey:@"saved_to_list"])
                {
                    [followActivity deleteEventually];
                }
            }
            
            //Check if the user is also following you.  If so set the object whose 'fromUser' field is the other user and 'toUser' field is you's 'FriendStatus' field as 'NotFriends.
            PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [query whereKey:kPAPActivityFromUserKey equalTo:user];
            [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error)
                {
                    for (PFObject *object in objects)
                    {
                        [object setObject:@"NotFriends" forKey:@"FriendStatus"];
                        [object saveInBackground];
                    }
                }
            }];
        }
    }];
    
    [[Cache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[Cache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];
    
    return query;
}


#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}
@end
