//
//  AppDelegate.h
//  Fitness
//
//  Created by Long Le on 10/14/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "Reachability.h"
#import "AppConstant.h"
#import "Constants.h"
#import "HealthMethods.h"
#import "Cache.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>



#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define POLARH7_HRM_ENABLE_SERVICE_UUID @"2A39"
#define POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_UUID @"2A29"



@import HealthKit;

HKHealthStore *healthStore;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    
    NSMutableArray *heartRateMonitors;
        
    NSString *manufacturer;
    BOOL autoConnect;
    
    // Progress Indicator
    //...
}

@property (strong, nonatomic) UIWindow *window;
@property (retain) NSMutableArray *heartRateMonitors;
@property (copy) NSString *manufacturer;
@property (copy) NSString *connected;
@property (assign) uint16_t heartRate;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (nonatomic) double currentHeartRate;
@property (nonatomic, readonly) int networkStatus;
@property NSMutableArray *stepsArray;
@property NSString *homeCurrentListSelectedString;
@property NSMutableArray *friendsObjectIdArray;


- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;
- (BOOL)isParseReachable;


- (void) updateWithHRMData:(NSData *)data;

@end

