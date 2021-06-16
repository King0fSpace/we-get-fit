//
//  EditYourProfileViewController.m
//  We Get Fit
//
//  Created by Long Le on 7/15/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "EditYourProfileViewController.h"


@interface EditYourProfileViewController ()

@end

@implementation EditYourProfileViewController

@synthesize nameTextField;
@synthesize usernameTextField;
@synthesize userObject;
@synthesize yourPhoto;

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    if (userObject == nil)
        if ([PFUser currentUser])
            userObject = [PFUser currentUser];
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    self.view = view;
    
    // Do any additional setup after loading the view.
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    //do something like background color, title, etc you self
    [self.view addSubview:navBar];

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    navItem.rightBarButtonItem = done;
    navBar.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:navBar];

    //Configure navBar title
    UILabel *navBarTitleLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationItem.titleView.frame.size.width,40)];
    navBarTitleLabel.text = @"Edit Profile";
    navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    navBarTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    navBarTitleLabel.textColor = [UIColor whiteColor];
    navItem.titleView = navBarTitleLabel;
    
    //Add the 'name' field to the top left
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 30)];
    if (userObject)
        nameTextField.text = userObject[@"first_name"];
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.delegate = self;
    [self.view addSubview:nameTextField];
    
    //Add 'FullNameIcon' next to the name text field
    UIImageView *fullNameIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FullNameIcon"]];
    fullNameIcon.frame = CGRectMake(0, 0, 35, 35);
    fullNameIcon.center = CGPointMake(25, nameTextField.center.y);
    [self.view addSubview:fullNameIcon];
    
    //Add 'username' text field below that
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 200, 30)];
    if (userObject)
        usernameTextField.text = userObject[@"username"];
    
    usernameTextField.returnKeyType = UIReturnKeyDone;
    usernameTextField.delegate = self;
    [self.view addSubview:usernameTextField];
    
    //Add 'UserNameIcon' next to the username text field
    UIImageView *usernameIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserNameIcon.png"]];
    usernameIcon.frame = CGRectMake(0, 0, 25, 25);
    usernameIcon.center = CGPointMake(25, usernameTextField.center.y);
    [self.view addSubview:usernameIcon];
    
    //Add photo circle and edit button to the right of those two
    if (userObject)
    {
        [userObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                UIImage *image = [UIImage imageWithData:data];
               // NSLog(@"data = %@", data);
                NSLog(@"userObject profile_photo = %@", userObject[@"profile_photo"]);
                // image can now be set on a UIImageView
                yourPhoto = [[UIImageView alloc] initWithImage:image];
                yourPhoto.frame = CGRectMake(0, 0, 75, 75);
                yourPhoto.center = CGPointMake(nameTextField.center.x + 110, nameTextField.center.y + 15);
                yourPhoto.layer.cornerRadius = yourPhoto.frame.size.width / 2;
                yourPhoto.clipsToBounds = YES;
                [self.view addSubview:yourPhoto];
                
                //Add 'Edit' button beneath photo
                UIButton *editLabelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [editLabelButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
                [editLabelButton setTitle:@"edit" forState:UIControlStateNormal];
                [editLabelButton sizeToFit];
                editLabelButton.center = CGPointMake(yourPhoto.center.x, yourPhoto.center.y + 47);
                [self.view addSubview:editLabelButton];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog (@"updateUserPhoto called!");
   // [yourPhoto removeFromSuperview];
    
    //Refresh user profile photo in case they changed it just now
    if (userObject)
    {
     [userObject[@"profile_photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
         UIImage *image = [UIImage imageWithData:data];
         //NSLog(@"data = %@", data);
         NSLog(@"userObject profile_photo = %@", userObject[@"profile_photo"]);
         // image can now be set on a UIImageView
         yourPhoto = [[UIImageView alloc] initWithImage:image];
         yourPhoto.frame = CGRectMake(0, 0, 75, 75);
         yourPhoto.center = CGPointMake(nameTextField.center.x + 110, nameTextField.center.y + 15);
         yourPhoto.layer.cornerRadius = yourPhoto.frame.size.width / 2;
         yourPhoto.clipsToBounds = YES;
         [self.view addSubview:yourPhoto];
         }
     }];
    }
}

//When user taps 'Upload Photo' button on Home Page this displays one button that slide up from the button of the screen that lets the user Take a Photo or Choose a Photo from their library
- (void)uploadPhoto
{
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        NSLog (@"cameraDeviceAvailable & photoLibraryAvailable available");
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showInView: self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog (@"imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info");
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    EditPhotoViewController *viewController = [[EditPhotoViewController alloc] initWithImage:image];
    //[viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showInView:self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    NSLog (@"shouldStartPhotoLibraryPickerController called!");
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *originalValidUsername = textField.text;
    
    // done button was pressed - dismiss keyboard
    if (textField == self.nameTextField)
    {
        [self.nameTextField becomeFirstResponder];
        
        //Query parse to see if name exists already
        PFQuery *query = [PFQuery queryWithClassName:@"user"];
        [query whereKey:@"full_name" equalTo:self.nameTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                // Do something with the found objects
                if (userObject)
                    userObject[@"full_name"] = self.nameTextField.text;
                
                //Change full_name_lowercase in parse as well
                if (userObject)
                    userObject[@"full_name_lowercase"] = [self.nameTextField.text lowercaseString];
                
                [userObject saveEventually];
            }
            else
            {
                // Log details of the failure
                NSLog(@"Error trying to query for duplicate usernames as the one the user wants to change theirs to");
            }
            
            [textField resignFirstResponder];
        }];
    }
    else if (textField == self.usernameTextField)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UsernameManuallySet"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.usernameTextField becomeFirstResponder];
        [textField resignFirstResponder];
        
        NSLog (@"self.usernameTextField.text = %@", self.usernameTextField.text);
        
        if ([PFUser currentUser])
        {
            //Check to make sure username is under 16 characters max
            if ([self.usernameTextField.text length] >= 16)
            {
                if (userObject)
                    usernameTextField.text = userObject[@"username"];
                
                //Let the user know the username is too long
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Sorry"
                                                                 message:@"That Username is Too Long"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                //Query parse to see if name exists already
                PFQuery *query = [PFUser query];
                [query whereKey:@"username" equalTo:self.usernameTextField.text];
                [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error)
                    {
                        // Do something with the found objects
                        NSLog (@"[objects count] = %lu", (unsigned long)[objects count]);

                        if ([objects count] > 0 || [usernameTextField.text isEqualToString:@""])
                        {
                            //Set text field's text back to the valid username
                            if (userObject)
                                usernameTextField.text = userObject[@"username"];
                            
                            //If NOT OK, show pop up letting them know the name is taken and set the text field back to what your parse name currently is
                            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Sorry :("
                                                                             message:@"That Username is Already Taken"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles: nil];
                            [alert show];
                        }
                        else if (!([self.usernameTextField.text isEqualToString:[objects lastObject][@"username"]]))
                        {
                            //If OK, then save the name to parse and make sure the text field contains the new name
                            if (userObject)
                            {
                                userObject[@"username"] = self.usernameTextField.text;
                                //Change username_lowercase in parse as well
                                userObject[@"username_lowercase"] = [self.usernameTextField.text lowercaseString];
                                [userObject saveEventually];
                            }
                        }
                    }
                    else
                    {
                        // Log details of the failure
                        NSLog(@"Error trying to query for duplicate usernames as the one the user wants to change theirs to");
                    }
                    
                    [textField resignFirstResponder];
                }];
            }
        }
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
}

- (void)doneButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
