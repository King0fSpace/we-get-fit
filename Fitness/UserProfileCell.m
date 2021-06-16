//
//  HomeViewUserCell.m
//  Fitness
//
//  Created by Long Le on 3/25/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "UserProfileCell.h"

@implementation UserProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(6, 6, [[UIScreen mainScreen] bounds].size.width/4 + 19, [[UIScreen mainScreen] bounds].size.width/4 + 19);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 0;
}

@end
