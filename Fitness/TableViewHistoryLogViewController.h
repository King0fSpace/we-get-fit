//
//  TableViewHistoryLogViewController.h
//  Fitness
//
//  Created by Long Le on 11/5/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PageContentViewController.h"
#import "ArchivedReading.h"


@interface TableViewHistoryLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *archivedReadingsArray;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSString *title;

@end
