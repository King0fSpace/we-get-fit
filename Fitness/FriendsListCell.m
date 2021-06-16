//
//  FriendsListCell.m
//  We Get Fit
//
//  Created by Long Le on 7/18/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "FriendsListCell.h"

@implementation FriendsListCell

@synthesize fullNameLabel;
@synthesize usernameLabel;
@synthesize photoButton;
@synthesize followButton;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellStyleDefault;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    //Round out the user's photo
    self.imageView.frame = CGRectMake(7, 7, 45, 45);
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 0;
    
    //Photo button is used to detect a tap in order to load the user's profile photo
    self.photoButton.frame = CGRectMake(7, 7, 45, 45);
    self.photoButton.layer.cornerRadius = self.photoButton.frame.size.height/2;
    self.photoButton.layer.cornerRadius = self.photoButton.frame.size.width/2;
    self.photoButton.layer.masksToBounds = YES;
    self.photoButton.layer.borderWidth = 0;
    
    NSLog (@"self.imageView.frame.size.width = %f", self.imageView.frame.size.width);
    NSLog (@"self.imageView.frame.size.height = %f", self.imageView.frame.size.height);
}

@end
