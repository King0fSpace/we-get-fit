//
//  InterfaceController.m
//  Fitness WatchKit Extension
//
//  Created by Long Le on 3/13/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)remoteNotification
{
    [self pushControllerWithName:@"TextInputController" context:nil];
}


@end



