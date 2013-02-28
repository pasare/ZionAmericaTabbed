//
//  SendEmailViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/30/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "SendEmailViewController.h"

@interface SendEmailViewController ()

@end

@implementation SendEmailViewController

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
    //set the colors
     self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _sendEmailTable.backgroundColor = [UIColor clearColor];
    [_sendEmailTable setBackgroundView:nil];
    _commentView.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    
    //Initalize variables
    _emailName = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _emailAddress = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _emailSubject = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    
    Contact *contact = [VariableStore sharedInstance].selectedContact;
    if (contact != nil) {
        _emailName.text = [contact name];
        _emailAddress.text = [contact email];
    }
    //Set up mailer alert
    //UIAlert for retrieving video list
	self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Sending Email" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the sucessful email alert
    _emailAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The email was sent successfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    
    //Create the failed email alert
    _failedAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The email was not sent, please check the address and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
	// Do any additional setup after loading the view.
    _commentView.layer.borderWidth = 1.0f;
    _commentView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Create send button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Send" style:UIBarButtonItemStyleDone
                                              target:self action:@selector(sendEmail:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    [ _emailSubject resignFirstResponder];
    [ _emailAddress resignFirstResponder];
    [ _emailName resignFirstResponder];
    [ _commentView resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeView = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _activeView = nil;
}

//Method to control the text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    if (theTextField == _emailName) {
        [theTextField resignFirstResponder];
        [_emailAddress becomeFirstResponder ];
    }
    else if (theTextField == _emailAddress) {
        [theTextField resignFirstResponder];
        [_emailSubject becomeFirstResponder ];
    }
    else if (theTextField == _emailSubject) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

//Always put comment box above keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if (_activeView !=nil)
    {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        CGRect bkgndRect = _activeView.superview.frame;
        bkgndRect.size.height += kbSize.height;
        [_activeView.superview setFrame:bkgndRect];
        [_scrollView setContentOffset:CGPointMake(0.0, _activeView.frame.origin.y-kbSize.height+200) animated:YES];
    }
}

- (void)keyboardDidHide: (NSNotification*) aNotification
{

}

//send the email

-(void) sendEmail:(id) sender {
    if (_emailName.text.length !=0) {
        if (_emailAddress.text.length != 0) {
            [self.statusAlert show];
            [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(sendEmailFinal:) userInfo:nil repeats:NO];
        }
        else {
            NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
            [_sendEmailTable cellForRowAtIndexPath:path].textLabel.textColor = [UIColor redColor];
            [_emailAddress becomeFirstResponder];
            path = [NSIndexPath indexPathForRow:0 inSection:0];
            [_sendEmailTable cellForRowAtIndexPath:path].textLabel.textColor = [UIColor blackColor];
        }
    }
    else {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [_sendEmailTable cellForRowAtIndexPath:path].textLabel.textColor = [UIColor blackColor];
        path = [NSIndexPath indexPathForRow:0 inSection:0];
        [_sendEmailTable cellForRowAtIndexPath:path].textLabel.textColor = [UIColor redColor];
        [_emailName becomeFirstResponder];
    }
}
- (void) sendEmailFinal:(id) sender
{
    _emailAddress.layer.borderWidth = 0.0f;
    
    CTCoreMessage *msg = [[CTCoreMessage alloc] init];
    CTCoreAddress *toAddress = [CTCoreAddress addressWithName:_emailName.text email:_emailAddress.text];
    CTCoreAddress *fromAddress = [CTCoreAddress addressWithName:@"Maryland Zion" email:@"info@marylandzion.org"];
    
    NSError *error;
    NSString *videoName = [VariableStore sharedInstance].videoName;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *videoUrl;
    NSArray *wpposts = [defaults objectForKey:@"posts"];
    
    for (NSDictionary *post in wpposts) {
        if ([[post objectForKey:@"post_title"] isEqualToString:videoName]) {
            videoUrl = [post objectForKey:@"link"];
        }
    }
    
    BOOL success = NO;
    
        
        
        
        //Create the message to send
        NSString *videoDescription = [NSString stringWithFormat:@"Please enjoy this video titled: %@\r%@",videoName , videoUrl];
        NSMutableString *msgBody = [NSMutableString stringWithCapacity:0];
        
        [msgBody appendString:[NSString stringWithFormat:@"\r%@\r",_commentView.text]];
        [msgBody appendString:videoDescription];
        [msg setTo:[NSSet setWithObject:toAddress]];
        [msg setFrom: [NSSet setWithObject:fromAddress]];
        if (_emailSubject.text.length > 0)
            [msg setSubject:_emailSubject.text];
        [msg setBody:msgBody];
        
        success = [CTSMTPConnection sendMessage:msg
                                          server:@"mail.marylandzion.org"
                                        username:@"info@marylandzion.org"
                                        password:@"M4ryl4ndZ1on!"
                                            port:26
                                  connectionType:CTSMTPConnectionTypeStartTLS
                                         useAuth:YES
                                           error:&error];
    
    if (success) {
        BOOL duplicate = NO;
        
        
        Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:[[VariableStore sharedInstance] context]];
        [contact setName:_emailName.text];
        [contact setEmail:_emailAddress.text];
        [contact setPhone:nil];
        
        //Save this contact to the contact list
        NSFetchedResultsController *fetchedContacts = [[VariableStore sharedInstance]fetchedContactsController];
        NSArray *contactList = [fetchedContacts fetchedObjects];
        BOOL contactToDelete = NO;
        
        //loop through the contact list checking for a duplicate name
        for (Contact *currentContact in contactList){
            if ([contact duplicateContact:currentContact] ) {
                //If the contact exists but the email is blank copy the phone and save again
                if ([currentContact email] == nil) {
                    [contact setName:_emailName.text];
                    [contact setEmail:_emailAddress.text];
                    [contact setPhone:[currentContact phone]];
                    
                    //delete the old object
                    [[[VariableStore sharedInstance] context] deleteObject:currentContact];
                    
                    //replace with new object
                    if (![[[VariableStore sharedInstance] context] save:&error]) {
                        // Handle the error.
                    }
                    contactToDelete = YES;
                    break;
                }
                else
                    duplicate = YES;
            }
        } 
        if (!duplicate && !contactToDelete){
            NSError *error = nil;
            if (![[[VariableStore sharedInstance] context] save:&error]) {
                // Handle the error.
            }
        }
        
        [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
        //clear the contact so that it does not get saved again
        [[[VariableStore sharedInstance]context]deleteObject:contact];
        contact = nil;
        
        //Add item to history
        History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:[[VariableStore sharedInstance] context]];
        [history setDate:[NSDate date]];
        [history setRecipient:_emailName.text];
        [history setVideo:videoName];
        if (![[[VariableStore sharedInstance] context] save:&error]) {
            // Handle the error.
        }
        
        
        [_emailAlert show];
        contact = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
        [self performSegueWithIdentifier: @"emailSentSegue" sender: self];
            [VariableStore sharedInstance].selectedContact = nil;
        _emailAddress.text=@"";
        _emailName.text=@"";
        _emailSubject.text=@"";
        NSLog(@"Email sent successfully");

    }
    else {
        [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
        NSLog(@"An error was encountered while sending the email %@", error);
        [_failedAlert show];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
        //[self performSegueWithIdentifier: @"emailSentSegue" sender: self];
    }
}

//Create the group cells look for textboxes
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if( cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (indexPath.row == 0) {
        _emailName.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailName setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Name";
        cell.accessoryView = _emailName ;
    }
    if (indexPath.row == 1) {
        _emailAddress.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailAddress setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Email";
        cell.accessoryView = _emailAddress;
    }
    if (indexPath.row == 2) {
        _emailSubject.autocorrectionType = UITextAutocorrectionTypeYes;
        [_emailSubject setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Subject";
        cell.accessoryView = _emailSubject;
    }
    _emailName.delegate = self;
    _emailAddress.delegate = self;
    _emailSubject.delegate = self;
    
    
    [_sendEmailTable addSubview:_emailName];
    [_sendEmailTable addSubview:_emailAddress];
    [_sendEmailTable addSubview:_emailSubject];
    //cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

@end
