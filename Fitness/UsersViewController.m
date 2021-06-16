//
//  UsersViewController.m
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "UsersViewController.h"

@interface UsersViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end


@implementation UsersViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize passedInUserObject;
@synthesize viewOffset;


#pragma mark - Initialization

/*
- (id)initWithCoder:(NSCoder *)aCoder {
    
    NSLog (@"usersviewController initWithCoder");
    
    self = [super initWithCoder:aCoder];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = @"Photo";
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 7;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = NO;        
    }
    return self;
}
*/
- (void)viewDidLoad
{
    NSLog (@"usersViewController viewDidLoad");
    
    [super viewDidLoad];
        
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    /*  ChallengeWinnersViewController is a subclass of this class and we don't want the search bar yet.
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

    [self.searchController.searchBar sizeToFit];
     */
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //make sure model has only results that correspond to the search here
    //[self filterResults: [searchController.searchBar text]];
    
    [self loadObjects];
}
/*
//helper method, called in updateSearchResultsForSearchController
- (void)filterResults:(NSString *)searchTerm {
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"user"];
    [query whereKeyExists:@"username"];  //this is based on whatever query you are trying to accomplish
    [query whereKey:@"username" containsString:searchTerm];
    
    NSArray *results  = [query findObjects];
    
    NSLog(@"%@", results);
    NSLog(@"%u", results.count);
    
    [self.searchResults addObjectsFromArray:results];
}
*/
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /*
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0)
        sections++;
    return sections;
     */
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 1;
    NSInteger row = [self.objects count];
    if (self.paginationEnabled && row != 0)
        row++;
    return row;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count)
    {
        return 160;
        
    }
    else
    {
        return 44.0f;
    }
}

//The creates a 'load more' cell which the user taps to load more
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"UsersViewController didSelectRowAtIndexPath called");
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if (indexPath.row == self.objects.count && self.paginationEnabled)
    {
        // Load More Cell
        [self loadNextPage];
    }
    else
    {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        MeViewController *viewController = [[MeViewController alloc] init];
        viewController.viewOffset = 460;
        viewController.currentViewIsNonRootView = YES;
        viewController.userObject = object;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

//This automatically loads more when the user scrolls to the bottom of the page
/*
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        [self loadNextPage];
    }
}
*/

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    NSLog (@"queryForTable");
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:20];
        return query;
    }
    
    NSString *lowercaseSearchTerm = [self.searchController.searchBar.text lowercaseString];
    
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"NumberOfStepsToday"];
    if (self.searchController.searchBar.text.length > 0)
        [query whereKey:@"username_lowercase" containsString:lowercaseSearchTerm];
    [query whereKeyExists:@"username"];  //this is based on whatever query you are trying to accomplish

    PFQuery *query2 = [PFUser query];
    [query2 whereKeyExists:@"NumberOfStepsToday"];
    if (self.searchController.searchBar.text.length > 0)
        [query2 whereKey:@"full_name_lowercase" containsString:lowercaseSearchTerm];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
    
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Photo"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */
    
    return compoundQuery;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {

    // overridden, since we want to implement sections
    if (indexPath.row < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.row];
    }
    
    return nil;
}

-(void) addPhotoFooter: (PhotoCell *)cell countryCode:(NSString*)countryCode age:(NSNumber*)ageArg gender:(NSString*)genderArg username:(NSString*)usernameArg
{
    NSLog (@"addPhotoFooter called!");
    
    NSString *genderInitial;
    
    if ([genderArg isEqualToString: [NSString stringWithFormat:@"male"]])
    {
        genderInitial = [NSString stringWithFormat:@"M"];
    }
    else
    {
        genderInitial = [NSString stringWithFormat:@"F"];
    }

    //If first name AND gender AND age is available
    if (countryCode != NULL && ageArg != NULL && genderInitial != NULL)
        cell.footer.text = [NSString stringWithFormat: @"  %@%@, %@", ageArg, genderInitial, countryCode];
    else if (ageArg != NULL && genderInitial != NULL)
        cell.footer.text = [NSString stringWithFormat: @"  %@%@", ageArg, genderInitial];
    //If first name AND gender is available
    else if (countryCode != NULL && genderInitial != NULL)
        cell.footer.text = [NSString stringWithFormat: @"  %@, %@", genderInitial, countryCode];
    //If first name AND age is available
    else if (countryCode != NULL && ageArg != NULL)
        cell.footer.text = [NSString stringWithFormat: @"  %@, %@", ageArg, countryCode];
    else if (countryCode != NULL)
        cell.footer.text = [NSString stringWithFormat: @"  %@", countryCode];
    
    cell.footer.textColor = [UIColor whiteColor];
    cell.footer.font = [UIFont fontWithName:@"Helvetica" size:21];
    cell.footer.tag = 1;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *identifier = @"Cell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    PFFile *thumbnail = [object objectForKey:@"profile_photo"];
    cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    cell.imageView.file = thumbnail;
    
    return cell;
}
*/

- (NSString *)getThreeLetterCountryCodeFromTwoLetterCountryCode:(NSString *)twoLetterCountryCode{
    // modified from http://stackoverflow.com/a/7520861
    NSDictionary *translateCodeDic = @{@"AF" : @"AFG",    // Afghanistan
                                       @"AL" : @"ALB",    // Albania
                                       @"AE" : @"ARE",    // U.A.E.
                                       @"AR" : @"ARG",    // Argentina
                                       @"AM" : @"ARM",    // Armenia
                                       @"AU" : @"AUS",    // Australia
                                       @"AT" : @"AUT",    // Austria
                                       @"AZ" : @"AZE",    // Azerbaijan
                                       @"BE" : @"BEL",    // Belgium
                                       @"BD" : @"BGD",    // Bangladesh
                                       @"BG" : @"BGR",    // Bulgaria
                                       @"BH" : @"BHR",    // Bahrain
                                       @"BA" : @"BIH",    // Bosnia and Herzegovina
                                       @"BY" : @"BLR",    // Belarus
                                       @"BZ" : @"BLZ",    // Belize
                                       @"BO" : @"BOL",    // Bolivia
                                       @"BR" : @"BRA",    // Brazil
                                       @"BN" : @"BRN",    // Brunei Darussalam
                                       @"CA" : @"CAN",    // Canada
                                       @"CH" : @"CHE",    // Switzerland
                                       @"CL" : @"CHL",    // Chile
                                       @"CN" : @"CHN",    // People's Republic of China
                                       @"CO" : @"COL",    // Colombia
                                       @"CR" : @"CRI",    // Costa Rica
                                       @"CZ" : @"CZE",    // Czech Republic
                                       @"DE" : @"DEU",    // Germany
                                       @"DK" : @"DNK",    // Denmark
                                       @"DO" : @"DOM",    // Dominican Republic
                                       @"DZ" : @"DZA",    // Algeria
                                       @"EC" : @"ECU",    // Ecuador
                                       @"EG" : @"EGY",    // Egypt
                                       @"ES" : @"ESP",    // Spain
                                       @"EE" : @"EST",    // Estonia
                                       @"ET" : @"ETH",    // Ethiopia
                                       @"FI" : @"FIN",    // Finland
                                       @"FR" : @"FRA",    // France
                                       @"FO" : @"FRO",    // Faroe Islands
                                       @"GB" : @"GBR",    // United Kingdom
                                       @"GE" : @"GEO",    // Georgia
                                       @"GR" : @"GRC",    // Greece
                                       @"GL" : @"GRL",    // Greenland
                                       @"GT" : @"GTM",    // Guatemala
                                       @"HK" : @"HKG",    // Hong Kong S.A.R.
                                       @"HN" : @"HND",    // Honduras
                                       @"HR" : @"HRV",    // Croatia
                                       @"HU" : @"HUN",    // Hungary
                                       @"ID" : @"IDN",    // Indonesia
                                       @"IN" : @"IND",    // India
                                       @"IE" : @"IRL",    // Ireland
                                       @"IR" : @"IRN",    // Iran
                                       @"IQ" : @"IRQ",    // Iraq
                                       @"IS" : @"ISL",    // Iceland
                                       @"IL" : @"ISR",    // Israel
                                       @"IT" : @"ITA",    // Italy
                                       @"JM" : @"JAM",    // Jamaica
                                       @"JO" : @"JOR",    // Jordan
                                       @"JP" : @"JPN",    // Japan
                                       @"KZ" : @"KAZ",    // Kazakhstan
                                       @"KE" : @"KEN",    // Kenya
                                       @"KG" : @"KGZ",    // Kyrgyzstan
                                       @"KH" : @"KHM",    // Cambodia
                                       @"KR" : @"KOR",    // Korea
                                       @"KW" : @"KWT",    // Kuwait
                                       @"LA" : @"LAO",    // Lao P.D.R.
                                       @"LB" : @"LBN",    // Lebanon
                                       @"LY" : @"LBY",    // Libya
                                       @"LI" : @"LIE",    // Liechtenstein
                                       @"LK" : @"LKA",    // Sri Lanka
                                       @"LT" : @"LTU",    // Lithuania
                                       @"LU" : @"LUX",    // Luxembourg
                                       @"LV" : @"LVA",    // Latvia
                                       @"MO" : @"MAC",    // Macao S.A.R.
                                       @"MA" : @"MAR",    // Morocco
                                       @"MC" : @"MCO",    // Principality of Monaco
                                       @"MV" : @"MDV",    // Maldives
                                       @"MX" : @"MEX",    // Mexico
                                       @"MK" : @"MKD",    // Macedonia (FYROM)
                                       @"MT" : @"MLT",    // Malta
                                       @"ME" : @"MNE",    // Montenegro
                                       @"MN" : @"MNG",    // Mongolia
                                       @"MY" : @"MYS",    // Malaysia
                                       @"NG" : @"NGA",    // Nigeria
                                       @"NI" : @"NIC",    // Nicaragua
                                       @"NL" : @"NLD",    // Netherlands
                                       @"NO" : @"NOR",    // Norway
                                       @"NP" : @"NPL",    // Nepal
                                       @"NZ" : @"NZL",    // New Zealand
                                       @"OM" : @"OMN",    // Oman
                                       @"PK" : @"PAK",    // Islamic Republic of Pakistan
                                       @"PA" : @"PAN",    // Panama
                                       @"PE" : @"PER",    // Peru
                                       @"PH" : @"PHL",    // Republic of the Philippines
                                       @"PL" : @"POL",    // Poland
                                       @"PR" : @"PRI",    // Puerto Rico
                                       @"PT" : @"PRT",    // Portugal
                                       @"PY" : @"PRY",    // Paraguay
                                       @"QA" : @"QAT",    // Qatar
                                       @"RO" : @"ROU",    // Romania
                                       @"RU" : @"RUS",    // Russia
                                       @"RW" : @"RWA",    // Rwanda
                                       @"SA" : @"SAU",    // Saudi Arabia
                                       @"CS" : @"SCG",    // Serbia and Montenegro (Former)
                                       @"SN" : @"SEN",    // Senegal
                                       @"SG" : @"SGP",    // Singapore
                                       @"SV" : @"SLV",    // El Salvador
                                       @"RS" : @"SRB",    // Serbia
                                       @"SK" : @"SVK",    // Slovakia
                                       @"SI" : @"SVN",    // Slovenia
                                       @"SE" : @"SWE",    // Sweden
                                       @"SY" : @"SYR",    // Syria
                                       @"TJ" : @"TAJ",    // Tajikistan
                                       @"TH" : @"THA",    // Thailand
                                       @"TM" : @"TKM",    // Turkmenistan
                                       @"TT" : @"TTO",    // Trinidad and Tobago
                                       @"TN" : @"TUN",    // Tunisia
                                       @"TR" : @"TUR",    // Turkey
                                       @"TW" : @"TWN",    // Taiwan
                                       @"UA" : @"UKR",    // Ukraine
                                       @"UY" : @"URY",    // Uruguay
                                       @"US" : @"USA",    // United States
                                       @"UZ" : @"UZB",    // Uzbekistan
                                       @"VE" : @"VEN",    // Bolivarian Republic of Venezuela
                                       @"VN" : @"VNM",    // Vietnam
                                       @"YE" : @"YEM",    // Yemen
                                       @"ZA" : @"ZAF",    // Zimbabwe
                                       };
    NSString *result = [translateCodeDic objectForKey:twoLetterCountryCode];
    return result;
}

- (PhotoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
 
    NSLog (@"indexPath = %@", indexPath);
    
    NSLog (@"cellForRowAtIndexPath in UsersViewController");
    
    static NSString *CellIdentifier = @"Cell";
        
    if (indexPath.row == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        PhotoCell *cell = (PhotoCell *)[self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        return cell;
    
    } else {
  
        PhotoCell *cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       
        //Add all cell assets within this if block. configure the assets right outside the block
        if (!cell)
        {
            cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
            cell.blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.blueCircleView];
            
            cell.blueCircleSmallStepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.blueCircleSmallStepsLabel];
            
            cell.blueCircleNumOfStepsTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.blueCircleNumOfStepsTodayLabel];
            
            cell.redCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.redCircleView];
            
            cell.redCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.redCircleSmallMinLabel];
            
            cell.redCircleMinOfExerciseTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.redCircleMinOfExerciseTodayLabel];
            
            cell.orangeCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview: cell.orangeCircleView];
            
            cell.orangeCircleSmallMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.orangeCircleSmallMinLabel];
            
            cell.orangeCircleNumOfCaloriesTodayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [cell addSubview:cell.orangeCircleNumOfCaloriesTodayLabel];
        }
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }

        
        //Change color of every other cell
        if (indexPath.row % 2) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
        }
        
        PFUser *userFetched = object;
        [userFetched fetchIfNeededInBackgroundWithBlock:^(PFObject *objects, NSError *error)
         {
             NSString *gender = [object objectForKey:@"gender"];
             NSNumber *age = [object objectForKey:@"age"];
             NSString *countryCode = [object objectForKey:@"threeLetterCountryCode"];
             NSString *username = [object objectForKey:@"username"];
             
             //Add user photo to cell
             cell.imageView.file = [object objectForKey:@"profile_photo"];
             cell.imageView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 20, 20);
             [cell.imageView loadInBackground];
             
             //add text to footer
             [self addPhotoFooter:cell countryCode:countryCode age:age gender:gender username:username];
         }];
        
        //Add photoButton that brings up user profile when tapped
        cell.photoButton.tag = indexPath.row;
        [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *sevenDayAverageLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, 0, 0, 0)];
        sevenDayAverageLabel.textColor = [UIColor lightGrayColor];
        sevenDayAverageLabel.backgroundColor = [UIColor clearColor];
        sevenDayAverageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(10.0)];
        sevenDayAverageLabel.text = [NSString stringWithFormat: @"7 Day Average"];
        [sevenDayAverageLabel sizeToFit];
        float xPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4;
        float yPosition = 8;
        sevenDayAverageLabel.center = CGPointMake(xPosition, yPosition);
        [cell addSubview:sevenDayAverageLabel];
        
        //Add exercise metrics to the right of picture
        //Determine blueCircle size
        float blueCircleHeightAndWidth;
        float blueCircleXPosition;
        float blueCircleYPosition;
        NSLog (@"[self sevenDayAvgNumOfSteps:object] = %i", [self sevenDayAvgNumOfSteps:object]);
        if ([self sevenDayAvgNumOfSteps:object] < 10) {
            
            blueCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 10 && [self sevenDayAvgNumOfSteps:object] < 999)
        {
            blueCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 999 && [self sevenDayAvgNumOfSteps:object] < 5000)
        {
            blueCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 5000 && [self sevenDayAvgNumOfSteps:object] < 10000)
        {
            blueCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgNumOfSteps:object] >= 10000)
        {
            blueCircleHeightAndWidth = 15*5.25;
        }

        double cellBoundsHeight = 160; //Hardcoding this will position the bubbles correctly automatically
        
        blueCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4 - [[UIScreen mainScreen] bounds].size.width/10 - sqrt(4.5);
        blueCircleYPosition = (cellBoundsHeight/2) + (cellBoundsHeight/5);
                
        //Add blue colored circle
        cell.blueCircleView.frame = CGRectMake(0, 0, blueCircleHeightAndWidth, blueCircleHeightAndWidth);
        cell.blueCircleView.center = CGPointMake(blueCircleXPosition, blueCircleYPosition);
        cell.blueCircleView.alpha = 0.8;
        cell.blueCircleView.layer.cornerRadius = blueCircleHeightAndWidth/2;
        cell.blueCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:164/255.0 alpha:1];
        cell.blueCircleView.tag = 2;
        [cell.blueCircleView sizeToFit];
        
        cell.blueCircleStepsLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y);

        //Add small blue 'Steps' label under the number of steps
        cell.blueCircleSmallStepsLabel.text = @"steps";
        cell.blueCircleSmallStepsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.blueCircleSmallStepsLabel.textColor = [UIColor whiteColor];
        cell.blueCircleSmallStepsLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.blueCircleSmallStepsLabel sizeToFit];
        cell.blueCircleSmallStepsLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y + 10);

        //Add number of steps inside the blue circle
        cell.blueCircleNumOfStepsTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgNumOfSteps:object]];
        cell.blueCircleNumOfStepsTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.blueCircleNumOfStepsTodayLabel.textColor = [UIColor whiteColor];
        cell.blueCircleNumOfStepsTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.blueCircleNumOfStepsTodayLabel.tag = 2;
        [cell.blueCircleNumOfStepsTodayLabel sizeToFit];
        cell.blueCircleNumOfStepsTodayLabel.center = CGPointMake(cell.blueCircleView.center.x, cell.blueCircleView.center.y);


        //Determine redCircle size
        float redCircleHeightAndWidth;
        float redCircleXPosition;
        float redCircleYPosition;
        if ([self sevenDayAvgMinutesOfExercise:object] < 1) {
            
            redCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 1 && [self sevenDayAvgMinutesOfExercise:object] < 20)
        {
            redCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 20 && [self sevenDayAvgMinutesOfExercise:object] < 40)
        {
            redCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 40 && [self sevenDayAvgMinutesOfExercise:object] < 60)
        {
            redCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgMinutesOfExercise:object] >= 60)
        {
            redCircleHeightAndWidth = 15*5.25;
        }

        redCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4;
        redCircleYPosition = (cellBoundsHeight/2) - (cellBoundsHeight/6);

        
        //Add red colored circle
        cell.redCircleView.frame = CGRectMake(0, 0, redCircleHeightAndWidth, redCircleHeightAndWidth);
        cell.redCircleView.alpha = 0.8;
        cell.redCircleView.center = CGPointMake(redCircleXPosition, redCircleYPosition);
        cell.redCircleView.layer.cornerRadius = redCircleHeightAndWidth/2;
        cell.redCircleView.backgroundColor = [UIColor colorWithRed:140/255.0 green:198/255.0 blue:62/255.0 alpha:1];
        cell.redCircleView.tag = 2;
        [cell.redCircleView sizeToFit];
        cell.redCircleExerciseLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y);

        
        //Add small 'min' label under the distance run label
        cell.redCircleSmallMinLabel.text = @"min";
        cell.redCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.redCircleSmallMinLabel.textColor = [UIColor whiteColor];
        cell.redCircleSmallMinLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.redCircleSmallMinLabel sizeToFit];
        cell.redCircleSmallMinLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y + 10);

        
        //Add number of steps inside the red circle
        cell.redCircleMinOfExerciseTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgMinutesOfExercise:object]];
        cell.redCircleMinOfExerciseTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.redCircleMinOfExerciseTodayLabel.textColor = [UIColor whiteColor];
        cell.redCircleMinOfExerciseTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.redCircleMinOfExerciseTodayLabel.tag = 2;
        [cell.redCircleMinOfExerciseTodayLabel sizeToFit];
        cell.redCircleMinOfExerciseTodayLabel.center = CGPointMake(cell.redCircleView.center.x, cell.redCircleView.center.y);
        
        
        //Determine orangeCircle size
        float orangeCircleHeightAndWidth;
        float orangeCircleXPosition;
        float orangeCircleYPosition;
        NSNumber *moveGoalNSNum = [object objectForKey:@"moveGoal"];
        double moveGoal = [moveGoalNSNum doubleValue];
        
        if ([self sevenDayAvgCaloriesBurned:object] < moveGoal*0.25 || [self sevenDayAvgCaloriesBurned:object] == 0) {
            
            orangeCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.25 && [self sevenDayAvgCaloriesBurned:object] < moveGoal*0.5)
        {
            orangeCircleHeightAndWidth = 15*2.3;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.5 && [self sevenDayAvgCaloriesBurned:object] < moveGoal*0.75)
        {
            orangeCircleHeightAndWidth = 15*3.0;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal*0.75 && [self sevenDayAvgCaloriesBurned:object] < moveGoal)
        {
            orangeCircleHeightAndWidth = 15*3.8;
        }
        else if ([self sevenDayAvgCaloriesBurned:object] >= moveGoal)
        {
            orangeCircleHeightAndWidth = 15*5.25;
        }

        orangeCircleXPosition = [[UIScreen mainScreen] bounds].size.width/2 + [[UIScreen mainScreen] bounds].size.width/4 + [[UIScreen mainScreen] bounds].size.width/10 + sqrt(4.5);
        orangeCircleYPosition = (cellBoundsHeight/2) + (cellBoundsHeight/5);

        
        //Add orange colored circle
        cell.orangeCircleView.frame = CGRectMake(0, 0, orangeCircleHeightAndWidth, orangeCircleHeightAndWidth);
        cell.orangeCircleView.center = CGPointMake(orangeCircleXPosition, orangeCircleYPosition);
        cell.orangeCircleView.alpha = 0.8;
        cell.orangeCircleView.layer.cornerRadius = orangeCircleHeightAndWidth/2;
        cell.orangeCircleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:173/255.0 blue:239/255.0 alpha:1];
        cell.orangeCircleView.tag = 2;
        [cell.orangeCircleView sizeToFit];
        

        //Add small 'cal' label under the distance run label
        cell.orangeCircleSmallMinLabel.text = @"cal";
        cell.orangeCircleSmallMinLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
        cell.orangeCircleSmallMinLabel.textColor = [UIColor whiteColor];
        cell.redCircleSmallMinLabel.tag = 2;
        //Resize the frame of the UILabel to fit the text
        [cell.orangeCircleSmallMinLabel sizeToFit];
        cell.orangeCircleSmallMinLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y + 10);
        
  
        //Add number of steps inside the orange circle
        cell.orangeCircleNumOfCaloriesTodayLabel.text = [NSString stringWithFormat: @"%i", [self sevenDayAvgCaloriesBurned:object]];
        cell.orangeCircleNumOfCaloriesTodayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.orangeCircleNumOfCaloriesTodayLabel.textColor = [UIColor whiteColor];
        cell.orangeCircleNumOfCaloriesTodayLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        cell.orangeCircleNumOfCaloriesTodayLabel.tag = 2;
        [cell.orangeCircleNumOfCaloriesTodayLabel sizeToFit];
        cell.orangeCircleNumOfCaloriesTodayLabel.center = CGPointMake(cell.orangeCircleView.center.x, cell.orangeCircleView.center.y);

        return cell;
    }
}

-(int) sevenDayAvgMinutesOfExercise: (PFObject*)object
{
    NSNumber *minutesOfExerciseTodayNSNumber = [object objectForKey:@"sevenDayAvgNumOfMinOfExercise"];
    return (int)[minutesOfExerciseTodayNSNumber integerValue];
}

-(int) sevenDayAvgNumOfSteps: (PFObject*)object
{
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:@"sevenDayAvgNumOfSteps"];
    return (int)[numOfStepsTodayNSNumber integerValue];
}

-(int) sevenDayAvgCaloriesBurned: (PFObject*)object
{
    NSNumber *caloriesBurnedTodayNSNumber = [object objectForKey:@"sevenDayAvgNumOfCaloriesBurned"];
    return (int)[caloriesBurnedTodayNSNumber integerValue];
}

-(void) displayUserWorkoutDescription: (PFObject*)object
{
    NSLog (@"displayUserWorkoutDescription called!");
    NSString *firstName = [NSString stringWithFormat:@"%@", [object objectForKey:@"first_name"]];
    NSString *numOfStepsToday = [object objectForKey:@"NumberOfStepsToday"];
    NSString *numOfStepsYesterday = [object objectForKey:@"NumberOfStepsYesterday"];
    
    //Calculate average number of steps over the last seven days
    //Today
    NSNumber *numOfStepsTodayNSNumber = [object objectForKey:@"NumberOfStepsToday"];
    int numOfStepsTodayInt = [numOfStepsTodayNSNumber integerValue];
    //Yesterday
    NSNumber *numOfStepsYesterdayNSNumber = [object objectForKey:@"NumberOfStepsYesterday"];
    int numOfStepsYesterdayInt = [numOfStepsYesterdayNSNumber integerValue];
    //Two days ago
    NSNumber *numOfStepsTwoDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsTwoDaysAgo"];
    int numOfStepsTwoDaysAgoInt = [numOfStepsTwoDaysAgoNSNumber integerValue];
    //Three days ago
    NSNumber *numOfStepsThreeDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsThreeDaysAgo"];
    int numOfStepsThreeDaysAgoInt = [numOfStepsThreeDaysAgoNSNumber integerValue];
    //Four days ago
    NSNumber *numOfStepsFourDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsFourDaysAgo"];
    int numOfStepsFourDaysAgoInt = [numOfStepsFourDaysAgoNSNumber integerValue];
    //Five days ago
    NSNumber *numOfStepsFiveDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsFiveDaysAgo"];
    int numOfStepsFiveDaysAgoInt = [numOfStepsFiveDaysAgoNSNumber integerValue];
    //Six days ago
    NSNumber *numOfStepsSixDaysAgoNSNumber = [object objectForKey:@"NumberOfStepsSixDaysAgo"];
    int numOfStepsSixDaysAgoInt = [numOfStepsSixDaysAgoNSNumber integerValue];
    
    int averageStepsADayOverTheLastWeek = (numOfStepsYesterdayInt + numOfStepsTwoDaysAgoInt + numOfStepsThreeDaysAgoInt + numOfStepsFourDaysAgoInt + numOfStepsFiveDaysAgoInt + numOfStepsSixDaysAgoInt)/6;
    /*
    NSString *workoutDescription = [NSString stringWithFormat:@"%@ walked %i steps today. Yesterday, he walked %i steps. Over the last week, he has walked an average of %i steps a day.", firstName, numOfStepsTodayInt, numOfStepsYesterdayInt, averageStepsADayOverTheLastWeek];
    userWorkoutDescription.text = workoutDescription;
    [userWorkoutDescription setFont:[UIFont fontWithName:@"ArialMT" size:16]];
     */
}

#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    // Dispose of any resources that can be recreated.
}

- (void)didTapOnPhotoAction:(UIButton *)sender {
  
    PFObject *object = [self.objects objectAtIndex:sender.tag];
    
    MeViewController *viewController = [[MeViewController alloc] init];
    viewController.viewOffset = 460;
    viewController.currentViewIsNonRootView = YES;
    viewController.userObject = object;
    [self.navigationController pushViewController:viewController animated:YES];
}

//Query for steps taken for today
- (void)queryTotalStepsForToday: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryStepsWithAnchor called!");
    
    // Set your start and end date for your query of interest
    NSDate *now = [NSDate date];
    
    NSDate *todayAtMidnight = [NSDate date];;
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *todayPredicate = [HKQuery predicateForSamplesWithStartDate:todayAtMidnight endDate:now options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:todayPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsToday = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog (@"numOfStepsToday iVars = %i", numOfStepsToday);
                                    
                                    NSNumber *numOfStepsTodayNSNumber = [NSNumber numberWithInt:numOfStepsToday];
                                    
                                    if ([PFUser currentUser])
                                    {
                                        [[PFUser currentUser] setObject:numOfStepsTodayNSNumber forKey:@"NumberOfStepsToday"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken yesterday
-(void)queryTotalStepsForYesterday: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    NSLog (@"queryStepsWithAnchor called!");
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    //get NSDate for yesterday at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *yesterdayPredicate = [HKQuery predicateForSamplesWithStartDate:yesterdayAtMidnight endDate:todayAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:yesterdayPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsYesterday = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Yesterday: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsYesterdayNSNumber = [NSNumber numberWithInt:numOfStepsYesterday];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsYesterdayNSNumber forKey:@"NumberOfStepsYesterday"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken two days ago
-(void)queryTotalStepsForTwoDaysAgo: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for two days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-48];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterdayAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    yesterdayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:yesterdayAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *twoDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:twoDaysAgoAtMidnight endDate:yesterdayAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:twoDaysAgoPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsTwoDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Two Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsTwoDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsTwoDaysAgo];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsTwoDaysAgoNSNumber forKey:@"NumberOfStepsTwoDaysAgo"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken three days ago
-(void)queryTotalStepsForThreeDaysAgo: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for three days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-48];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *twoDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    twoDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:twoDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *threeDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:threeDaysAgoAtMidnight endDate:twoDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:threeDaysAgoPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsThreeDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Three Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsThreeDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsThreeDaysAgo];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsThreeDaysAgoNSNumber forKey:@"NumberOfStepsThreeDaysAgo"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken four days ago
-(void)queryTotalStepsForFourDaysAgo: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for four days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-72];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *threeDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    threeDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:threeDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fourDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fourDaysAgoAtMidnight endDate:threeDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:fourDaysAgoPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsFourDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Four Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsFourDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsFourDaysAgo];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsFourDaysAgoNSNumber forKey:@"NumberOfStepsFourDaysAgo"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken five days ago
-(void)queryTotalStepsForFiveDaysAgo: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for five days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-96];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fourDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fourDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fourDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *fiveDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:fiveDaysAgoAtMidnight endDate:fourDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:fiveDaysAgoPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsFiveDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Five Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsFiveDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsFiveDaysAgo];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsFiveDaysAgoNSNumber forKey:@"NumberOfStepsFiveDaysAgo"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Query for steps taken six days ago
-(void)queryTotalStepsForSixDaysAgo: (HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    
    // Set your start and end date for your query of interest
    
    //Used to help NSDates at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    //today at midnight
    NSDate *todayAtMidnight = [NSDate date];
    todayAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:todayAtMidnight]];
    
    
    //get NSDate for six days ago at midnight
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-144];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *sixDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    sixDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:sixDaysAgoAtMidnight]];
    
    //yesterdayAtMidnight used to get todayPredicate
    [components setHour:-120];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *fiveDaysAgoAtMidnight = [cal dateByAddingComponents:components toDate:todayAtMidnight options:0];
    fiveDaysAgoAtMidnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:fiveDaysAgoAtMidnight]];
    
    // Use the sample type for step count
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    NSPredicate *sixDaysAgoPredicate = [HKQuery predicateForSamplesWithStartDate:sixDaysAgoAtMidnight endDate:fiveDaysAgoAtMidnight options:HKQueryOptionStrictStartDate];
    
    
    HKStatisticsOptions sumOptions = HKStatisticsOptionCumulativeSum;
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:stepCountQuantityType
                                                       quantitySamplePredicate:sixDaysAgoPredicate
                                                                       options:sumOptions
                                                             completionHandler:^(HKStatisticsQuery *query,
                                                                                 HKStatistics *result,
                                                                                 NSError *error)
                                {
                                    HKQuantity *sum = [result sumQuantity];
                                    
                                    int numOfStepsSixDaysAgo = [sum doubleValueForUnit:[HKUnit countUnit]];
                                    NSLog(@"Total Steps Six Days Ago: %lf", [sum doubleValueForUnit:[HKUnit countUnit]]);
                                    
                                    NSNumber *numOfStepsSixDaysAgoNSNumber = [NSNumber numberWithInt:numOfStepsSixDaysAgo];
                                    
                                    if ([PFUser currentUser])
                                    {
                                    
                                        [[PFUser currentUser] setObject:numOfStepsSixDaysAgoNSNumber forKey:@"NumberOfStepsSixDaysAgo"];
                                        
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            // some logging code here
                                            NSLog (@"PFUser data save in background success = %i", succeeded);
                                            NSLog (@"Error = %@", error);
                                        }];
                                    }
                                }];
    
    // Execute the query
    [healthStore executeQuery:query];
}

//Method - Calculates difference between two NSDates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(NSString*) convertToLocalTime: (NSDate*)dateArg
{
    NSDateFormatter *localFormat = [[NSDateFormatter alloc] init];
    [localFormat setTimeStyle:NSDateFormatterLongStyle];
    [localFormat setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
    NSString *localTime = [localFormat stringFromDate:dateArg];
    
    return localTime;
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
