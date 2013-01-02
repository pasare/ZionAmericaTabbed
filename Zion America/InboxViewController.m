//
//  InboxViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/31/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "InboxViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searching = NO;
    _letUserSelectRow = YES;
    _listOfItems = [[NSMutableArray alloc] init];
    
    //UIAlert for retrieving email list
	self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Retrieving Emails" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the failed load alert
    self.failedVideoAlert = [[UIAlertView alloc] initWithTitle:@"List Error" message:@"unable to load the email list at this time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    //Load the video list from memory if possible
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *emails = [defaults objectForKey:@"emails"];
    
    //If the sync button is press, update the email list
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Sync" style:UIBarButtonItemStylePlain
                                              target:self action:@selector(updateList:)];
    //Load the email list from memory
    if (emails != nil) {
        [self loadEmailList:emails];
    }
    //Retrieve video list from server
    else {
        [self.statusAlert show];
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tryRetrieveEmailList) userInfo:nil repeats:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadEmailList:(NSArray*) emails
{
    
}

-(void) tryRetrieveEmailList
{
    int newCount = 0;
    CTCoreAccount *account = [[CTCoreAccount alloc] init];
    [account connectToServer:@"mail.marylandzion.org" port:143 connectionType:CONNECTION_TYPE_PLAIN authType:IMAP_AUTH_TYPE_PLAIN login:@"info@marylandzion.org" password:@"M4ryl4ndZ1on!"];
    CTCoreFolder *inbox = [account folderWithPath:@"INBOX"];
    NSArray *messageList = [inbox messagesFromUID:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
    _tableArray = messageList;
    
    for (CTCoreMessage *message in messageList) {
        //Get the number of new messages
        if([message isUnread])
            newCount++;
    }
    
    NSMutableString *newTitle= [NSMutableString stringWithFormat:@"Inbox (%d)",newCount];
    _inboxNavigationItem.title = newTitle;
    [_emailTable reloadData];
    
       [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES]; 
    
}

//Methods for the table generation
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searching)
        return [_listOfItems count];
    else {
        return [_tableArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"inboxCell";
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    /*if (cell == nil)
    {
        cell = [[InboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    } */
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InboxCellView" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[InboxCell class]])
        {
            cell = (InboxCell *)currentObject;
            break;
        }
    }
    
    if (_searching){
        cell.textLabel.text = [_listOfItems objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        //Add the cells
        
        CTCoreMessage *message = [_tableArray objectAtIndex:indexPath.row];
        NSString *currentSender = [[message.from anyObject] name];
        NSString *subject = [message subject];
        NSDate *senderDate = [message senderDate];
        NSDate *localDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy";
        
        NSString *dateString = [dateFormatter stringFromDate: senderDate];
        
        if ([currentSender isEqualToString:@""]) {
                currentSender = [[message.from anyObject] email];
            }
        if ([message isUnread]) {
            [[cell unreadMessageLabel] setImage:[UIImage imageNamed:@"gnome_mail_unread.png"]];
        }
        else {
            //[[cell unreadMessageLabel] setImage:[UIImage imageNamed:@"stock_mail_unread.png"]];
        }
        [[cell senderLabel]setText:currentSender];
        [[cell titleLabel]setText:subject];
        [[cell timeLabel]setText:dateString];
        NSLog(@"Sender date %@",dateString);
        return cell;
    }
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selectedEmail = nil;
    
    if(_searching)
        selectedEmail = [_listOfItems objectAtIndex:indexPath.row];
    else {
        NSArray *array = [_tableArray objectAtIndex:indexPath.section];
        selectedEmail = [array objectAtIndex:indexPath.row];
    }
    [VariableStore sharedInstance].emailName = selectedEmail;
    //[self performSegueWithIdentifier: @"videoDetailSegue" sender: self];
}

@end
