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
    _emailTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    [_emailTable setBackgroundView:nil];
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
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self action:@selector(updateList)];
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
    NSArray *messageList = [inbox messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope| CTFetchAttrBodyStructure];
    _tableArray = messageList;
    
    //Sort array so that newest mail shows up first
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"senderDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    _tableArray = [messageList sortedArrayUsingDescriptors:sortDescriptors];
    
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
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InboxCellView" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[InboxCell class]])
        {
            cell = (InboxCell *)currentObject;
            break;
        }
    }
    CTCoreMessage *message;
    if (_searching && [_listOfItems count] >0){
        message = [_listOfItems objectAtIndex:indexPath.row];
    }
    else {
        //Add the cells
        
        message = [_tableArray objectAtIndex:indexPath.row];
    }
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
        [[cell unreadMessageLabel] setImage:[UIImage imageNamed:@"gnome_mail_read.png"]];
    }
    [[cell senderLabel]setText:currentSender];
    [[cell titleLabel]setText:subject];
    [[cell timeLabel]setText:dateString];
    //NSLog(@"Sender date %@",dateString);
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    return cell;
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CTCoreMessage *selectedEmail;
    
    if(_searching)
        selectedEmail = [_listOfItems objectAtIndex:indexPath.row];
    else {
        selectedEmail = [_tableArray objectAtIndex:indexPath.row];
    }
    [VariableStore sharedInstance].selectedEmail = selectedEmail;
    [self performSegueWithIdentifier: @"emailDetailSegue" sender: self];
}

//Searching methods
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    
    _searching = YES;
    _letUserSelectRow = NO;
    _emailTable.scrollEnabled = NO;
    
    //Add the done button.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(doneSearching_Clicked:)];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_letUserSelectRow)
        return indexPath;
    else
        return nil;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    
    //Remove all objects first.
    [_listOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        
        _searching = YES;
        _letUserSelectRow = YES;
        _emailTable.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        
        _searching = NO;
        _letUserSelectRow = NO;
        _emailTable.scrollEnabled = NO;
    }
    
    [_emailTable reloadData];
}

- (void) searchTableView
{
    
    NSString *searchText = _searchBar.text;

    for (CTCoreMessage *sTemp in _tableArray)
    {
        NSRange subjectResultsRange = [[sTemp subject] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange fromResultsRange = [[[sTemp.from anyObject]name] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange toResultsRange = [[[sTemp.to anyObject]name] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange bodyResultsRange = [[sTemp body] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (subjectResultsRange.length > 0 || fromResultsRange.length > 0 || toResultsRange.length > 0 || bodyResultsRange.length > 0)
            [_listOfItems addObject:sTemp];
    }
}

- (void) doneSearching_Clicked:(id)sender
{
    
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
    _letUserSelectRow = YES;
    _searching = NO;
    _emailTable.scrollEnabled = YES;
    //Recreate the sync button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self action:@selector(updateList)];
    
    
    [_emailTable reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
    [self searchTableView];
}

-(void) updateList
{
    [self.statusAlert show];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tryRetrieveEmailList) userInfo:nil repeats:NO];
}

- (IBAction)confirmLogout:(id)sender {
    _sheet = [[UIActionSheet alloc] initWithTitle:@"You will be logged out of the system"
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Confirm"
                                otherButtonTitles:nil];
    
    // Show the sheet
    [_sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //Logout confirmed
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier: @"logoutSegue" sender: self];
    }
}
@end
