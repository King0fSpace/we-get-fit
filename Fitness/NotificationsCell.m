//
//  NotificationsCell.m
//  We Get Fit
//
//  Created by Long Le on 4/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "NotificationsCell.h"

@implementation NotificationsCell


@synthesize notificationTextLabel;
@synthesize elapsedTimeSincePost;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellStyleDefault;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    //Round out the user's photo
    self.imageView.frame = CGRectMake(5, 1, 78, 78);
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
     
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 0;
     
    NSLog (@"self.imageView.frame.size.width = %f", self.imageView.frame.size.width);
    NSLog (@"self.imageView.frame.size.height = %f", self.imageView.frame.size.height);
}

-(void)prepareForReuse
{
    NSLog (@"NotificationsCell prepareForReuse called!");
    
    self.imageView.image = [UIImage imageNamed:@"UserNameIcon.png"];
    notificationTextLabel.text = @"";
    elapsedTimeSincePost.text = @"";
}

@end
