//
//  PAPEditPhotoViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "EditPhotoViewController.h"
//#import "PhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "Cache.h"
#import "Constants.h"

@interface EditPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@end

@implementation EditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;


#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    
    NSLog (@"initWithImage:(UIImage *)aImage in EditPhotoViewController called!");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        if (!aImage)
        {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 42.0f, 320.0f, 320.0f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:photoImageView];
    
    
    /* Ignore the footer for now
    CGRect footerRect = [PAPPhotoDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    PAPPhotoDetailsFooterView *footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.commentTextField.delegate = self;
    [self.scrollView addSubview:footerView];
    */
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height /*+ footerView.frame.size.height*/)];
}

- (void)viewDidLoad {
    
    NSLog (@"viewDidLoad in EditPhotoViewController");
    
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    //Add button to bottom left of screen to cancel
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(15, [[UIScreen mainScreen] bounds].size.height - 75, 160.0, 40.0);
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Cooperplate" size:36.0]];
    [self.view addSubview:cancelButton];
    
    //Add button to right of cancel button to publish
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [publishButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    publishButton.frame = CGRectMake(135, [[UIScreen mainScreen] bounds].size.height - 75, 160.0, 40.0);
    [publishButton.titleLabel setFont:[UIFont fontWithName:@"Cooperplate" size:36.0]];
    [self.view addSubview:publishButton];
    /*
    //Add text field
    CGRect frame = CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 135, [[UIScreen mainScreen] bounds].size.width - 20, 30);
    commentTextField = [[UITextField alloc] initWithFrame:frame];
    commentTextField.borderStyle = UITextBorderStyleRoundedRect;
    commentTextField.returnKeyType = UIReturnKeySend;
    commentTextField.textColor = [UIColor blackColor];
    commentTextField.font = [UIFont systemFontOfSize:17.0];
    commentTextField.placeholder = @"Add a comment";
    commentTextField.backgroundColor = [UIColor whiteColor];
    commentTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    commentTextField.keyboardType = UIKeyboardTypeDefault;
    commentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    commentTextField.delegate = self;
    [self.view addSubview:commentTextField];
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self shouldUploadImage:self.image];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.commentTextField resignFirstResponder];
}


#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    NSLog (@"shouldUploadImage:(UIImage *)anImage");
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    

    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender {
    NSLog (@"doneButtonAction:(id)sender");
    NSDictionary *userInfo = [NSDictionary dictionary];
    /*
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    */
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    //User photo caption
    /*NSString *caption = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
    //Save the comment in the 'Photo' class associated with the photo as a 'photoCaption'
    [photo setObject:caption forKey:@"photoCaption"];
    */
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [[PFUser currentUser] setObject:self.photoFile forKey:@"profile_photo"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // some logging code here
                if (succeeded)
                {
                    NSLog(@"Photo uploaded successfully");
                    [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                        {
                            NSLog(@"Thumbnail uploaded successfully");
                            
                            //Update user photo in EditPhotoViewController
                            [self dismissViewControllerAnimated:YES completion:nil];
                            EditYourProfileViewController *subClass = [[EditYourProfileViewController alloc] init];
                            [subClass updateUserPhoto];
                        }
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }];
                }
                else
                {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
            }];
            
            /*
            NSLog(@"Photo uploaded");
            NSLog (@"comment = %@", [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey]);
            [[Cache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
               // NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                    [comment setObject:photo forKey:kPAPActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                    [comment setObject:commentText forKey:kPAPActivityContentKey];

                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[Cache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            */
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
}

- (void)cancelButtonAction:(id)sender {
    NSLog (@"cancelButtonAction:(id)sender");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
