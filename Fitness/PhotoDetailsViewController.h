//
//  PhotoDetailsViewController.h
//  We Get Fit
//
//  Created by Long Le on 9/12/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"

@interface PhotoDetailsViewController : UIViewController


@property UIImageView *userPhoto;
@property PFObject *passedInUserObject;

@end
