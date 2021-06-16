//
//  PhotoCell.m
//  Fitness
//
//  Created by Long Le on 11/30/14.
//  Copyright (c) 2014 Le, Long. All rights reserved.
//

#import "PhotoCell.h"
//#import "PAPUtility.h" <-imported in Anypic


@implementation PhotoCell

/*
@synthesize photoButton1;
@synthesize photoButton2;
@synthesize photoButton3;
@synthesize photoButton4;

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
*/
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
        /*
        imageView1 = [[PFImageView alloc] init];
        imageView1.contentMode = UIViewContentModeScaleAspectFit;
        imageView1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView1];
        
        imageView2 = [[PFImageView alloc] init];
        imageView2.contentMode = UIViewContentModeScaleAspectFit;
        imageView2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView2];
        
        imageView3 = [[PFImageView alloc] init];
        imageView3.contentMode = UIViewContentModeScaleAspectFit;
        imageView3.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView3];
        
        imageView4 = [[PFImageView alloc] init];
        imageView4.contentMode = UIViewContentModeScaleAspectFit;
        imageView4.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView4];
         
        self.photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton1];
        
        self.photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton2];
        
        self.photoButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton3.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton3];
        
        self.photoButton4 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton4.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton4];
        
        [self.contentView bringSubviewToFront:imageView1];
        [self.contentView bringSubviewToFront:imageView2];
        [self.contentView bringSubviewToFront:imageView3];
        [self.contentView bringSubviewToFront:imageView4];
        */
    
        //[self.contentView bringSubviewToFront:[self imageView1]];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        int footerSizeHeight = 25;
        self.footer = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bounds.size.height - footerSizeHeight, self.imageView.bounds.size.width, footerSizeHeight)];
        self.footer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.contentView addSubview:self.footer];
    }
    
    return self;
}

#pragma mark - UIView

-(void)prepareForReuse
{
    //Set standin photo
    self.imageView.image = [UIImage imageNamed:@"UserNameIcon.png"];
}

- (void)layoutSubviews {
   
    [super layoutSubviews];
    /*
    self.photoButton1.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    self.photoButton2.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width/2, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    self.photoButton3.frame = CGRectMake( 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    self.photoButton4.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    
    imageView1.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    imageView2.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width/2, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    imageView3.frame = CGRectMake( 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    imageView4.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
    */
    
    if (IS_STANDARD_IPHONE_6)
    {
        self.imageView.frame = CGRectMake(0.0f, -7, [[UIScreen mainScreen] bounds].size.height/4, [[UIScreen mainScreen] bounds].size.height/4);
        self.photoButton.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.height/4, [[UIScreen mainScreen] bounds].size.height/4);

        //This resets the frame size which is dependent on imageView, which during initialization, imageView's size is not known yet.
        int footerSizeHeight = 25;
        self.footer.frame = CGRectMake(0, self.imageView.bounds.size.height - footerSizeHeight - 7, self.imageView.bounds.size.width, footerSizeHeight);
    }
    else
    {
        self.imageView.frame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
        self.photoButton.frame = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.width/2);
        
        //This resets the frame size which is dependent on imageView, which during initialization, imageView's size is not known yet.
        int footerSizeHeight = 25;
        self.footer.frame = CGRectMake(0, self.imageView.bounds.size.height - footerSizeHeight, self.imageView.bounds.size.width, footerSizeHeight);
    }
}


@end
