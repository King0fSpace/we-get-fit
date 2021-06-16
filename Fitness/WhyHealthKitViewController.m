//
//  WhyHealthKitViewController.m
//  We Get Fit
//
//  Created by Long Le on 12/3/15.
//  Copyright © 2015 Le, Long. All rights reserved.
//

#import "WhyHealthKitViewController.h"

@interface WhyHealthKitViewController ()

@end

@implementation WhyHealthKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    super.textView.text = @"• Active Energy & Workouts are used to determine your minutes of exercise and calories burned\n\n• Date of Birth, Height, Sex, and Weight are used to determine fairness when comparing your total calories burned with other users\n\n• Heart Rate is used to determine the legitimacy of exercise and calories burned\n\n• Steps, Walking + Running Distance is used to determine the number of steps you've taken and the distances you've traversed\n\n• Your health data is not sold to advertisers and ONLY used within We Get Fit to make competitions possible";
    [super.textView sizeToFit];
    super.textView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
