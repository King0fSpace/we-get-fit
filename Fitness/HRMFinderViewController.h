//
//  HRMFinderViewController.h
//  Fitness
//
//  Created by Long Le on 11/9/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>

#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define POLARH7_HRM_ENABLE_SERVICE_UUID @"2A39"
#define POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_UUID @"2A29"

@import HealthKit;

HKHealthStore *healthStore;

@interface HRMFinderViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    
    NSMutableArray *heartRateMonitors;
    
    uint16_t heartRate;
    
    NSString *manufacturer;
    BOOL autoConnect;
    
    // Progress Indicator
    //...
}

@property (retain) NSMutableArray *heartRateMonitors;
@property (copy) NSString *manufacturer;
@property (copy) NSString *connected;
@property (assign) uint16_t heartRate;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) IBOutlet UILabel *currentHeartRate;
@property (strong, nonatomic) IBOutlet UILabel *staticTitleLabel;
@property (strong, nonatomic) NSString *title;

- (void) updateWithHRMData:(NSData *)data;
- (void)observerQueryToUpdateCurrentHR:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler;

@end
