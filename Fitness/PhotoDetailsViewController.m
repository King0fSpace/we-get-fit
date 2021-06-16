//
//  PhotoDetailsViewController.m
//  We Get Fit
//
//  Created by Long Le on 9/12/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "PhotoDetailsViewController.h"

@implementation PhotoDetailsViewController

@synthesize userPhoto;
@synthesize passedInUserObject;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (passedInUserObject == nil)
        passedInUserObject = [PFUser currentUser];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (passedInUserObject)
    {
        //Load image here and display it full screen
        [passedInUserObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error)
            {
                UIImage *image = [UIImage imageWithData:data];
                // image can now be set on a UIImageView
                userPhoto = [[UIImageView alloc] initWithImage:image];
                userPhoto.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height);
                userPhoto.layer.cornerRadius = userPhoto.frame.size.width / 2;
                userPhoto.clipsToBounds = YES;
                userPhoto.contentMode = UIViewContentModeScaleAspectFit;
                [self.view addSubview:userPhoto];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


@end
