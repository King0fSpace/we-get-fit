//
//  EditYourProfileViewController.h
//  We Get Fit
//
//  Created by Long Le on 7/15/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EditPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface EditYourProfileViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property UITextField *nameTextField;
@property UITextField *usernameTextField;
@property PFObject *userObject;
@property UIImageView *yourPhoto;


- (void)uploadPhoto;
-(void) updateUserPhoto;


@end
