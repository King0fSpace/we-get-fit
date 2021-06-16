//
//  AppDelegate.m
//  Fitness
//
//  Created by Long Le on 10/14/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
//#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize currentHeartRate;
@synthesize homeCurrentListSelectedString;
@synthesize friendsObjectIdArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog (@"AppDelegate didFinishLaunchingWithOptions called!");
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [ParseCrashReporting enable];
    
    
    [Parse setApplicationId:@"QfyGwKvPHkJCJFdnE6bOTjp4fAmmQ2mLYKSNxklM"
                  clientKey:@"EFa3K0sGTbPKloLkB7BRc0XrkyeJAJDureCbgGcL"];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
        
    //Allow MotivationDialogue box timer checker to run
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AllowMotivationDialogueBoxTimerToRun"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AllowChangeTodaysActivityLabelTimerToRun"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StepsQueryCurrentlyRunning"];

    //Set up listsArray
    NSMutableArray *listsArray = [[NSMutableArray alloc] init];
    [listsArray addObject:@"Following"];
    [listsArray addObject:@"Friends"];
    [listsArray addObject:@"Top Rated"];
    //Save listsArray to NSUserDefaults. Value is accessed in HomeView class
    [[NSUserDefaults standardUserDefaults] setObject:listsArray forKey:@"listsArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Set home tab's current selected list
    homeCurrentListSelectedString = [listsArray objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"listDisplayedTextField"]];
    

    //Change navigation bar color
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:81/255.0 green:193/255.0 blue:180/255.0 alpha:0.5]];

    //Init healthStore.  ALWAYS init it before you call healthStore methods.  
    healthStore = [[HKHealthStore alloc] init];
    
    //This allows steps to be queried in the background which allows queries for exercise minutes and calorie burns to be cascaded on through
    HKSampleType *stepsSampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [healthStore enableBackgroundDeliveryForType:stepsSampleType frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error)
    {
        if (success)
            NSLog (@"Steps background delivery successful");
        else
            NSLog (@"Steps background delivery NOT successful");
    }];
    /*
    HKQuery *query = [[HKObserverQuery alloc] initWithSampleType:stepsSampleType predicate:nil updateHandler:
                      ^void(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error)
                      {
                          NSLog (@"Steps HKObserverQuery called");
                          //If we don't call the completion handler right away, Apple gets mad. They'll try sending us the same notification here 3 times on a back-off algorithm.  The preferred method is we just call the completion handler.  Makes me wonder why they even HAVE a completionHandler if we're expected to just call it right away...
                          if (completionHandler) {
                              completionHandler();
                          }
                      }];
    [healthStore executeQuery:query];
    */
    /*
   // HKSampleType *workoutsSampleType = [HKSampleType quantityTypeForIdentifier:HKWorkoutTypeIdentifier];
    [healthStore enableBackgroundDeliveryForType:[HKWorkoutType workoutType] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error)
     {
         if (success)
             NSLog (@"Workouts background delivery successful");
         else
             NSLog (@"Workouts background delivery NOT successful");
     }];
    
    HKQuery *workoutsQuery = [[HKObserverQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:nil updateHandler:
                      ^void(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error)
                      {
                          NSLog (@"Workouts HKObserverQuery called");
                          //If we don't call the completion handler right away, Apple gets mad. They'll try sending us the same notification here 3 times on a back-off algorithm.  The preferred method is we just call the completion handler.  Makes me wonder why they even HAVE a completionHandler if we're expected to just call it right away...
                          if (completionHandler) {
                              completionHandler();
                          }
                      }];
    [healthStore executeQuery:workoutsQuery];
    */
    
    /*  TO DO: you need to find a way to call saveFriendsListRankingScoreToDisk, and readArchivedReadingsArrayFromDisk before the scheduled notification is called otherwise it's incorrect
    if ([PFUser currentUser])
    {
        //Schedule 11am local notification
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar] ;
        NSDate *now = [NSDate date];
        NSDateComponents *elevenAM = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
        [elevenAM setHour:11];
        [elevenAM setMinute:0];
        NSDate *elevenAMNSDate = [calendar dateFromComponents:elevenAM];
        
        HealthMethods *healthMethodsSubClass = [[HealthMethods alloc] init];
        
        [healthMethodsSubClass saveFriendsListRankingScoreToDisk: ^(double done, NSError *error)
         {
             if (done)
             {
                 //Scheudle 11am local notification
                 [healthMethodsSubClass readArchivedReadingsArrayFromDisk: elevenAMNSDate];
                 
                 //Schedule 4pm local notification
                 NSDateComponents *fourPM = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
                 [fourPM setHour:16];
                 [fourPM setMinute:0];
                 NSDate *fourPMNSDate = [calendar dateFromComponents:fourPM];
                 [healthMethodsSubClass readArchivedReadingsArrayFromDisk: fourPMNSDate];
             }
         }];
    }
     */
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    
    //[application registerForRemoteNotifications];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground called!");
    
    application.applicationIconBadgeNumber = 0;
    
    HealthMethods *healthMethodsSubClass = [[HealthMethods alloc] init];
    [healthMethodsSubClass saveUsersHeightToParse];
    [healthMethodsSubClass saveUsersWeightToParse];   
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //[[PFFacebookUtils session] close];
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.repeatInterval = NSDayCalendarUnit;
    [notification setAlertBody: @"We Get Fit is no longer running and will stop sharing with your friends"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    
    //Cancel all push notifications when app terminates
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (void)crash
{
    [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog (@"AppDelegate didRegisterForRemoteNotificationsWithDeviceToken called!");
    
    if ([PFUser currentUser])
    {
        // Store the deviceToken in the current installation and save it to Parse.
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation setObject:[PFUser currentUser] forKey: @"user"];
        [currentInstallation saveInBackground];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

/*
 Update UI with heart rate data received from device
 CHANGE TO sending hrm data to Health app
 */
- (void) updateWithHRMData:(NSData *)data
{
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0)
    {
        /* uint8 bpm */
        bpm = reportData[1];
    }
    else
    {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
        
    currentHeartRate = bpm;
    
    //NSLog (@"self.currentHeartRate = %f", self.currentHeartRate);
    
    //Save currentHeartRate to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setDouble: currentHeartRate forKey:@"CurrentHeartRate"];
    
    if (currentHeartRate > 0)
        [self saveHeartRateDataToHealthKit: currentHeartRate];
}

- (void)saveHeartRateDataToHealthKit:(uint16_t)bpm {
   
    // Save the user's bpm into HealthKit.
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    HKQuantity *bpmQuantity = [HKQuantity quantityWithUnit:bpmUnit doubleValue:bpm];
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *bpmSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:bpmQuantity startDate:now endDate:now];
    //NSLog (@"bpmSample = %@", bpmSample);
    
    [healthStore saveObject:bpmSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the heart rate sample %@. In your app, try to handle this gracefully. The error was: %@.", bpmSample, error);
        }
        
        //do something here if you want
        //NSLog (@"bpm reading written to health app!");
    }];
}

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    return FALSE;
}

/*
 Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
 */
- (void) startScan
{
    NSLog (@"startScan for device");
    
    NSDictionary *options = @{
                              CBCentralManagerOptionRestoreIdentifierKey:@"myCentralManagerIdentifier",
                              CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:YES]
                              };
    
    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:options];
}

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan
{
    [manager stopScan];
}


#pragma mark - CBCentralManager delegate methods
// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog (@"centralManagerDidUpdateState called");
    
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
        [central scanForPeripheralsWithServices:services options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
/*
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog (@"device found!");
    
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"heartRateMonitors"];
    if(![self.heartRateMonitors containsObject:aPeripheral] )
        [peripherals addObject:aPeripheral];
    
    // Retreive already known devices
    if(autoConnect)
    {
        [manager retrievePeripherals:[NSArray arrayWithObject:(id)aPeripheral.UUID]];
    }
}
*/
/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        peripheral = [peripherals objectAtIndex:0];
        [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog (@"didConnectPeripheral called");
    
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
    self.connected = @"Connected";
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog (@"didDisconnectPeripheral called");
    
    self.connected = @"Not connected";
    self.manufacturer = @"";
    self.heartRate = 0;
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
    
    [self startScan];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
/*
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        
        // Heart Rate Service
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        // Device Information Service
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        // GAP (Generic Access Profile) for Device Name 
        if ( [aService.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}
*/
/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
/*
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Set notification on heart rate measurement
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
            {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found a Heart Rate Measurement Characteristic");
            }
            // Read body sensor location
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Body Sensor Location Characteristic");
            }
            
            // Write heart rate control point
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
            {
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Read device name
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Read manufacturer name
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}
*/
/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
/*
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        if( (characteristic.value)  || !error )
        {
            // Update UI with heart rate data
            [self updateWithHRMData:characteristic.value];
        }
    }
    // Value for body sensor location received
    else  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
    {
        NSData * updatedValue = characteristic.value;
        uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
        if(dataPointer)
        {
            uint8_t location = dataPointer[0];
            NSString*  locationString;
            switch (location)
            {
                case 0:
                    locationString = @"Other";
                    break;
                case 1:
                    locationString = @"Chest";
                    break;
                case 2:
                    locationString = @"Wrist";
                    break;
                case 3:
                    locationString = @"Finger";
                    break;
                case 4:
                    locationString = @"Hand";
                    break;
                case 5:
                    locationString = @"Ear Lobe";
                    break;
                case 6:
                    locationString = @"Foot";
                    break;
                default:
                    locationString = @"Reserved";
                    break;
            }
            NSLog(@"Body Sensor Location = %@ (%d)", locationString, location);
        }
    }
    // Value for device Name received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    }
    // Value for manufacturer name received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        self.manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", self.manufacturer);
    }
}
 */
/*
// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    
    NSLog (@"dataTypesToRead method running");
    
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *bodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *biologicalSex = [HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierBiologicalSex];
    HKCharacteristicType *age = [HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *caloriesBurned = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *distanceWalkingRunning = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKObjectType *runningType = [HKObjectType workoutType];

    return [NSSet setWithObjects:heartRateType, biologicalSex, age, stepsType, bodyMass, caloriesBurned, distanceWalkingRunning, runningType, nil];
}
*/
/*
// Returns the types of data that Fit wishes to wrte from HealthKit.
- (NSSet *)dataTypesToWrite {
    
    NSLog (@"dataTypesToWrite method running");
    
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    return [NSSet setWithObjects:heartRateType, nil];
}
*/

-(void) registerSettingsAndCategories
{
    NSLog (@"registerSettingsAndCategories");
    
    NSMutableSet *categories = [[NSMutableSet alloc] init];
    
    UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
    replyAction.title = NSLocalizedString(@"Reply", comment: @"Reply");
    replyAction.identifier = @"Replay";
    replyAction.activationMode = UIUserNotificationActivationModeBackground;
    replyAction.authenticationRequired = false;
    
    
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    [inviteCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextDefault];
    inviteCategory.identifier = @"Invitation";
    [categories addObject:inviteCategory];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}


@end
