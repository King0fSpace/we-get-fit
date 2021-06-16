//
//  RulesViewController.m
//  We Get Fit
//
//  Created by Long Le on 11/4/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

@synthesize titleLabel;
@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Change background color
    self.view.backgroundColor = [UIColor whiteColor];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter; // UITextAlignmentCenter, UITextAlignmentLeft
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.text = @"Challenge Rules";
    titleLabel.font = [titleLabel.font fontWithSize:25];
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, 85);
    [self.view addSubview:titleLabel];
    
    //Add text box with challenge rules
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 200, [[UIScreen mainScreen] bounds].size.width - 5, [[UIScreen mainScreen] bounds].size.height/2)];
    textView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:15];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    textView.userInteractionEnabled = NO;
    textView.text = @"• Winners are announced every Monday \n\n• Winners are chosen based on amount of 'Average Activity' during the prior week\n\n• 'Average Activity' is an average of the participant's FOUR, highest 'Performance' days between Monday-Saturday during the prior week\n\n• 'Performance' is based on the number of steps, minutes of exercise, and calories burned relative to the user's age, gender, height, and weight. Steps, exercise, and calories each comprise a third of your total score";
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    [self.view addSubview:textView];
    
    //Add 'Dismiss' button to dismiss current view
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(dismissModalViewControllerAnimated)];
    
    self.navigationItem.rightBarButtonItem = dismissButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismissModalViewControllerAnimated
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
