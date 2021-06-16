//
//  FriendsViewPhotoCell.m
//  Fitness
//
//  Created by Long Le on 4/7/15.
//  Copyright (c) 2015 Le, Long. All rights reserved.
//

#import "PersonHealthStatsQuickViewCell.h"

@implementation PersonHealthStatsQuickViewCell

@synthesize photoButton;

@synthesize blueCircleView;
@synthesize blueCircleStepsLabel;
@synthesize blueCircleNumOfStepsTodayLabel;
@synthesize blueCircleSmallStepsLabel;

@synthesize redCircleView;
@synthesize redCircleExerciseLabel;
@synthesize redCircleMinOfExerciseTodayLabel;
@synthesize redCircleSmallMinLabel;

@synthesize orangeCircleView;
@synthesize orangeCircleCaloriesLabel;
@synthesize orangeCircleNumOfCaloriesTodayLabel;
@synthesize orangeCircleSmallMinLabel;

@synthesize friendRequestLabel;
@synthesize acceptButton;
@synthesize rejectButton;

@synthesize footer;


#pragma mark - NSObject


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
        
        int footerSizeHeight = 10;
        self.footer = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bounds.size.height - footerSizeHeight, self.imageView.bounds.size.width, footerSizeHeight)];
        self.footer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.contentView addSubview:self.footer];
        
        //Setting text color and font style in HomeView addPhotoFooter method
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(30, 1, 58, 58);
    /*
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 0;
    req
    NSLog (@"self.imageView.frame.size.width = %f", self.imageView.frame.size.width);
    NSLog (@"self.imageView.frame.size.height = %f", self.imageView.frame.size.height);
    */
    
    self.photoButton.frame = CGRectMake(30, 1, 58, 58);
    
    //This resets the frame size which is dependent on imageView, which during initialization, imageView's size is not known yet.
    int footerSizeHeight = 17;
   // self.footer.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.bounds.size.height - footerSizeHeight + 3, self.imageView.bounds.size.width, footerSizeHeight);
    
    //Setting text color and font style in HomeView addPhotoFooter method
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = [UIImage imageNamed:@"UserNameIcon.png"];
        
    /*
    [self.squareNumberView removeFromSuperview];
    [self.blueCircleView removeFromSuperview];
    [self.blueCircleStepsLabel removeFromSuperview];
    [self.blueCircleNumOfStepsTodayLabel removeFromSuperview];
    [self.redCircleView removeFromSuperview];
    [self.redCircleExerciseLabel removeFromSuperview];
    [self.redCircleMinOfExerciseTodayLabel removeFromSuperview];
    [self.redCircleSmallMinLabel removeFromSuperview];
    [self.orangeCircleView removeFromSuperview];
    [self.orangeCircleCaloriesLabel removeFromSuperview];
    [self.orangeCircleNumOfCaloriesTodayLabel removeFromSuperview];
    [self.orangeCircleSmallMinLabel removeFromSuperview];
     */
}

@end
