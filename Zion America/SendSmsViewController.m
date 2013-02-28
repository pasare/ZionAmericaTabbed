//
//  SendSmsViewController.m
//  Zion America
//
//  Created by Patrick Asare on 1/11/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "SendSmsViewController.h"

@interface SendSmsViewController ()

@end

@implementation SendSmsViewController

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
    _commentView.text =@"Message";
    //set the colors
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _sendSmsTable.backgroundColor = [UIColor clearColor];
    [_sendSmsTable setBackgroundView:nil];
    _commentView.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    
    //Initalize variables
    _phoneName = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _phoneText = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    
    //Create the logging in alert
    self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Sending Message" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the failed login alert
    self.failedAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Message Sent Sucessfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    Contact *contact = [VariableStore sharedInstance].selectedContact;
    if (contact != nil) {
        _phoneName.text = [contact name];
        _phoneText.text = [contact phone];
    }
    
    //Create send button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Send" style:UIBarButtonItemStyleDone
                                              target:self action:@selector(sendSms:)];
    _commentView.layer.borderWidth = 1.0f;
    _commentView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //keyboard functions
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to control the text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == _phoneName) {
        [theTextField resignFirstResponder];
        [_phoneText becomeFirstResponder ];
    }
    else if (theTextField == _phoneText) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

//Tap anywhere to dismiss keyboard
-(void)dismissKeyboard
{
    [ _phoneText resignFirstResponder];
    [ _phoneName resignFirstResponder];
    [ _commentView resignFirstResponder];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeView = textView;
    textView.text = @"";
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _activeView = nil;
    
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

-(void) sendSms:(id)sender
{
    //[_statusAlert show];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    //controller.delegate = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *wpposts = [defaults objectForKey:@"posts"];
    NSString * videoUrl;
    NSString *videoName = [[VariableStore sharedInstance] videoName ];
    if([MFMessageComposeViewController canSendText])
	{
        for (NSDictionary *post in wpposts) {
            if ([[post objectForKey:@"post_title"] isEqualToString:videoName]) {
                videoUrl = [post objectForKey:@"link"];
            }
        }
        
        NSString *bodyText =[[NSString alloc] initWithFormat:@"%@\rPlease Enjoy this video titled: %@\r%@",_commentView.text,videoName,videoUrl];
		controller.body = bodyText;
		controller.recipients = [NSArray arrayWithObjects:_phoneText.text, nil];
		controller.messageComposeDelegate = self;
        controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self presentViewController:controller animated:YES completion:^(void){}];
		//[self dismissViewControllerAnimated:YES completion:^(void){}];
	}
}

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	
	//feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
    
	switch (result)
	{
		case MessageComposeResultCancelled:
			//feedbackMsg.text = @"Result: SMS sending canceled";
            
			break;
            
		case MessageComposeResultSent:{
            
            [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
            
            //Save the contact
            [self saveContact];
            
            //add item to history
            [self saveHistory];
            
            //Display successful sms message
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
            [_failedAlert show];
			break;
        }
		case MessageComposeResultFailed:
			//feedbackMsg.text = @"Result: SMS sending failed";
            [_failedAlert setMessage:@"SMS sending failed"];
            [_failedAlert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
			break;
		default:
			//feedbackMsg.text = @"Result: SMS not sent";
            [_failedAlert setMessage:@"For some reason unable to send message"];
            [_failedAlert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if( cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (indexPath.row == 0) {
        _phoneName.autocorrectionType = UITextAutocorrectionTypeNo;
        [_phoneName setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_phoneName setReturnKeyType:UIReturnKeyNext];
        cell.textLabel.text = @"Name";
        cell.accessoryView = _phoneName ;
    }
    if (indexPath.row == 1) {
        _phoneText.autocorrectionType = UITextAutocorrectionTypeNo;
        [_phoneText setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_phoneText setKeyboardType:UIKeyboardTypePhonePad];
        [_phoneText setReturnKeyType:UIReturnKeyNext];
        cell.textLabel.text = @"Number";
        cell.accessoryView = _phoneText;
    }
    _phoneName.delegate = self;
    _phoneText.delegate = self;
    
    
    [_sendSmsTable addSubview:_phoneName];
    [_sendSmsTable addSubview:_phoneText];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void) saveContact{
    BOOL duplicate = NO;
    NSFetchedResultsController *fetchedContacts = [[VariableStore sharedInstance]fetchedContactsController];
    NSArray *contactList = [fetchedContacts fetchedObjects];
    Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [contact setName:_phoneName.text];
    [contact setEmail:nil];
    [contact setPhone:_phoneText.text];
    for (Contact *currentContact in contactList){
        if ([contact duplicateContact:currentContact] ) {
            //If the contact exists but the phone is blank copy the email and save again
            if ([[currentContact phone] isEqualToString:@""]) {
                [contact setName:_phoneName.text];
                [contact setEmail:[currentContact email]];
                [contact setPhone:_phoneText.text];
                
                //delete the old object
                [[[VariableStore sharedInstance] context] deleteObject:currentContact];
                
                break;
            }
            else
                duplicate = YES;
                break;
        }
    }
    if (!duplicate){
        NSError *error = nil;
        if (![[[VariableStore sharedInstance] context] save:&error]) {
            // Handle the error.
        }
    }
    else {
        //clear the contact so that it does not get saved twice
        [[[VariableStore sharedInstance]context]deleteObject:contact];
    }
    
    contact = nil;
}

-(void) saveHistory{
    NSError *error;
    History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [history setDate:[NSDate date]];
    [history setRecipient:_phoneName.text];
    [history setVideo:[[VariableStore sharedInstance] videoName ]];
    //save the newly created history item
    if (![[[VariableStore sharedInstance] context] save:&error]) {
        // Handle the error.
    }
    history = nil;
}
@end
