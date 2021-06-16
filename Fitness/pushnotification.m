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

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "pushnotification.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserAssign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserResign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [NSNull null];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification(NSString *roomId, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:@"roomId" equalTo:roomId];
    [query whereKey:@"sender_objectId" notEqualTo:[PFUser currentUser].objectId];
    [query includeKey:@"sender_objectId"];
    [query setLimit:1000];
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:@"user_objectId" matchesKey:@"sender_objectId" inQuery:query];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setMessage:text];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"SendPushNotification send error.");
         }
     }];

}
