//
//  TableViewHistoryLogViewController.m
//  Fitness
//
//  Created by Long Le on 11/5/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "TableViewHistoryLogViewController.h"


@interface TableViewHistoryLogViewController ()

@end

@implementation TableViewHistoryLogViewController

@synthesize index;
@synthesize archivedReadingsArray;
@synthesize title;
/*
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog (@"TableViewHistoryLogViewController viewDidLoad");
    
    // Do any additional setup
    //index = 3;
    title = @"History";
    
    archivedReadingsArray = [[NSMutableArray alloc] init];
    
    [self readArchivedReadingsArrayFromDisk];
    
    for (int i = 0; i < [archivedReadingsArray count]; i++)
    @autoreleasepool{
        if ([[archivedReadingsArray objectAtIndex:i] hrr] == 0)
        {
            //NSLog (@"archivedReadingsArray %f", [[archivedReadingsArray objectAtIndex: i] highbpm]);
            [archivedReadingsArray removeObjectAtIndex:i];
        }
    }
}

-(NSString*) convertToLocalTime: (NSDate*)dateArg
{
    NSDateFormatter *localFormat = [[NSDateFormatter alloc] init];
    [localFormat setTimeStyle:NSDateFormatterLongStyle];
    [localFormat setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
    NSString *localTime = [localFormat stringFromDate:dateArg];
    
    return localTime;
}

-(NSString *) pathForData2File
{
    NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    
    if (documentDir) {
        path = [documentDir objectAtIndex:0];
    }
    
    return [NSString stringWithFormat:@"%@/%@", path, @"data2.bin"];
}
                               
- (void) readArchivedReadingsArrayFromDisk
{
    NSString *path = [self pathForData2File];
    
    NSArray *unmutableArchivedReadingsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    [archivedReadingsArray addObjectsFromArray: unmutableArchivedReadingsArray];
    //NSLog (@"high bpm = %f", [[archivedReadingsArray objectAtIndex:0] highbpm]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [archivedReadingsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TableViewHistoryLogCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //reverse order of objects in archivedReadingsArray
    NSArray* reversed = [[archivedReadingsArray reverseObjectEnumerator] allObjects];
    
    double highbpmDouble = [[reversed objectAtIndex:indexPath.row] highbpm];
    double lowbpmDouble = [[reversed objectAtIndex:indexPath.row] lowbpm];
    double hrrDouble = [[reversed objectAtIndex:indexPath.row] hrr];
    NSDate *startDate = [[reversed objectAtIndex:indexPath.row] startDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yy"];
    
    NSString *startDateString = [dateFormat stringFromDate:startDate];
    NSString *highbpmhrrString = [NSString stringWithFormat: @"Max|HRR: %.0f|%.0f", highbpmDouble, hrrDouble];
    NSString *lowbpmString = [NSString stringWithFormat: @"Min: %.0f", lowbpmDouble];

    
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@   %@", startDateString, highbpmhrrString, lowbpmString];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
