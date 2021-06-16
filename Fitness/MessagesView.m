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
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "MessagesView.h"
#import "MessagesCell.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesView()
{
    NSMutableArray *messages;
   // UIRefreshControl *refreshControl;
    NSTimer *timer;
}
@property (strong, nonatomic) IBOutlet UITableView *tableMessages;


@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesView

//TO DO: Finish viewEmpty so that if there are no messages the user sees a blank view with a message telling them that there are no messages.
//@synthesize viewEmpty;

@synthesize index;
@synthesize tableMessages;


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog (@"MessagesView viewDidLoad");
    
    [super viewDidLoad];
    index = 2;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableMessages.contentInset = inset;
    
  //  refreshControl = [[UIRefreshControl alloc] init];
  //  [refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];

    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    
    messages = [[NSMutableArray alloc] init];

    //  viewEmpty.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self loadMessages];
    }
   // else LoginUser(self);
    
    //Set title for navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.tabBarController.navigationItem.titleView = label;
    label.text = @"Chat";
    [label sizeToFit];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog (@"MessagesView loadMessages");
    
    if ([PFUser currentUser] != nil)
    {
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        [query includeKey:PF_MESSAGES_LASTUSER];
        [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [messages removeAllObjects];
                 [messages addObjectsFromArray:objects];
                 [self updateEmptyView];
                 [self updateTabCounter];
                 
                 //Add call to reload list of pending messages here
                 [tableMessages reloadData];
             }
             else [ProgressHUD showError:@"Network error."];
             //[refreshControl endRefreshing];
         }];
    }
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateEmptyView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
 //   viewEmpty.hidden = ([messages count] != 0);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    int total = 0;
    for (PFObject *message in messages)
    {
        total += [message[PF_MESSAGES_COUNTER] intValue];
    }
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [messages removeAllObjects];
    //Add call to reload list of pending messages here
    
    
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    item.badgeValue = nil;
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (MessagesCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell"];
    
    if (cell == nil) {
        cell = [[MessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessagesCell"];
    }
    
    [cell bindData:messages[indexPath.row]];
    
    return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    DeleteMessageItem(messages[indexPath.row]);
    [messages removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateEmptyView];
    [self updateTabCounter];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog (@"MessagesView didSelectRow");
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFObject *message = messages[indexPath.row];

    //Query class name
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    
    [query getObjectInBackgroundWithId:message.objectId block:^(PFObject *roomIdObject, NSError *error)
    {
        ChatView *chatView = [[ChatView alloc] initWith:roomIdObject[@"roomId"]];
        
        //UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:chatView];
        //[self presentViewController:navBar animated:YES completion:nil];
        
        [self.navigationController presentViewController:chatView animated:YES completion:nil];
    }];
   
    // Do something with the returned PFObject.roomId in the roomId variable.
}

@end
