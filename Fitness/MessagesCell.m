//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



#import "MessagesCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesCell()
{
    PFObject *message;
}


@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesCell

@synthesize imageUser;
@synthesize labelDescription, labelLastMessage;
@synthesize labelElapsed, labelCounter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFObject *)message_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    message = message_;
    //---------------------------------------------------------------------------------------------------------------------------------------------


    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *lastUser = message[PF_MESSAGES_LASTUSER];
    [imageUser setFile:lastUser[PF_USER_PICTURE]];
    //Call in background to allow image to load and THEN resize it and stuff
    [imageUser loadInBackground:^(UIImage *image, NSError *error) {
        
        if (!error) {
            
            imageUser.frame = CGRectMake(imageUser.frame.origin.x, imageUser.frame.origin.y, 50, 50);
            
            imageUser.layer.cornerRadius = imageUser.frame.size.height/2;
            imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
            
            imageUser.layer.masksToBounds = YES;
            imageUser.layer.borderWidth = 0;
            
            NSLog (@"imageUser.frame.size.width = %f", imageUser.frame.size.width);
            NSLog (@"imageUser.frame.size.height = %f", imageUser.frame.size.height);
        }
    }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    labelDescription.text = message[PF_MESSAGES_DESCRIPTION];
    labelLastMessage.text = message[PF_MESSAGES_LASTMESSAGE];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message.updatedAt];
    labelElapsed.text = TimeElapsed(seconds);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    int counter = [message[PF_MESSAGES_COUNTER] intValue];
    labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

@end
