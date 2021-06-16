//
//  PAPEditPhotoViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "AppDelegate.h"
#import "EditYourProfileViewController.h"

@interface EditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

- (id)initWithImage:(UIImage *)aImage;

@end
