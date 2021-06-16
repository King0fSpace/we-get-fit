//
//  HRMFinderViewController.m
//  Fitness
//
//  Created by Long Le on 11/9/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "HRMFinderViewController.h"

@implementation HRMFinderViewController 

@synthesize heartRateMonitors;
@synthesize manufacturer;
@synthesize connected;
@synthesize index;
@synthesize title;

- (void)viewDidLoad
{
    //index = 0;
    title = [NSString stringWithFormat: @"Heart Rate"];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"CurrentHeartRate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"CurrentHeartRate"]) {
        
        if ([[NSUserDefaults standardUserDefaults] doubleForKey:@"CurrentHeartRate"] > 0)
            self.currentHeartRate.text = [NSString stringWithFormat: @"%.0f", [[NSUserDefaults standardUserDefaults] doubleForKey:@"CurrentHeartRate"]];
    }
}

-(void) dealloc
{
    NSLog (@"HRMFinderViewController dealloc called");
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"CurrentHeartRate"];
}


@end
