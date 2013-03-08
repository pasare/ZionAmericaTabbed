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
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    //set the colors
     self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _sendEmailTable.backgroundColor = [UIColor clearColor];
    [_sendEmailTable setBackgroundView:nil];
    _commentView.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    
    //Initalize variables
    _emailName = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _emailName.autocompleteType = HTAutocompleteTypeContact;
    _emailName.keyboardType = UIKeyboardTypeDefault;
    _emailName.delegate = self;
    _emailName.ignoreCase = YES;
    _emailName.showAutocompleteButton = YES;
    _emailName.clearButtonMode = UITextFieldViewModeAlways;

    _emailAddress = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _emailSubject = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    
    if ([VariableStore sharedInstance].selectedContactName != nil) 
        _emailName.text =[VariableStore sharedInstance].selectedContactName;
    
    if ([VariableStore sharedInstance].selectedContactEmail !=nil)
        _emailAddress.text = [VariableStore sharedInstance].selectedContactEmail;
    
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
        [self retrieveEmail];
        [theTextField resignFirstResponder];
        [_emailAddress becomeFirstResponder ];
    }
    else if (theTextField == _emailAddress) {
        [theTextField resignFirstResponder];
        [_emailSubject becomeFirstResponder ];
    }
    else if (theTextField == _emailSubject) {
        [theTextField resignFirstResponder];
        [_commentView becomeFirstResponder];
    }
    return YES;
}

//Always put comment box above keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if (_activeView !=nil)
    {
        //if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            NSDictionary* info = [aNotification userInfo];
            CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
            CGRect bkgndRect = _activeView.superview.frame;
            bkgndRect.size.height += kbSize.height;
            [_activeView.superview setFrame:bkgndRect];
            [_scrollView setContentOffset:CGPointMake(0.0, _activeView.frame.origin.y-kbSize.height+200) animated:YES];
        //}
    }
}

- (void)keyboardDidHide: (NSNotification*) aNotification
{
    _scrollView.scrollEnabled = YES;
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
    VariableStore *globals =[VariableStore sharedInstance];
    _emailAddress.layer.borderWidth = 0.0f;
    
    CTCoreMessage *msg = [[CTCoreMessage alloc] init];
    CTCoreAddress *toAddress = [CTCoreAddress addressWithName:_emailName.text email:_emailAddress.text];
    CTCoreAddress *fromAddress = [CTCoreAddress addressWithName:globals.zionName email:globals.smtpEmail];
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
    
    if (globals.smtpServer != nil) {
        success = [CTSMTPConnection sendMessage:msg
                                server:globals.smtpServer
                                username:globals.smtpEmail
                                password:globals.smtpPassword
                                port:26
                                connectionType:CTSMTPConnectionTypeStartTLS
                                    useAuth:YES
                                    error:&error];
    }
    
    if (success) {
        
        [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
        //Save contact
        [self saveContact];
        
        //Add item to history
        [self saveHistory];
        
        
        [_emailAlert show];
        //return to video selection view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
        [self performSegueWithIdentifier: @"emailSentSegue" sender: self];
        [VariableStore sharedInstance].selectedContactName = nil;
        [VariableStore sharedInstance].selectedContactEmail = nil;
        [VariableStore sharedInstance].selectedContactPhone = nil;
        _emailAddress.text=@"";
        _emailName.text=@"";
        _emailSubject.text=@"";
    }
    else {
        [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
        NSLog(@"An error was encountered while sending the email %@", error);
        [_failedAlert show];
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
        [_emailName setReturnKeyType:UIReturnKeyNext];
        cell.textLabel.text = @"Name";
        cell.accessoryView = _emailName ;
    }
    if (indexPath.row == 1) {
        _emailAddress.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailAddress setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_emailAddress setReturnKeyType:UIReturnKeyNext];
        _emailAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [_emailAddress setKeyboardType:UIKeyboardTypeEmailAddress];
        cell.textLabel.text = @"Email";
        cell.accessoryView = _emailAddress;
    }
    if (indexPath.row == 2) {
        _emailSubject.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailSubject setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_emailSubject setReturnKeyType:UIReturnKeyNext];
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

-(void) saveContact {
    CFErrorRef error = NULL;
    NSArray *nameParts = [_emailName.text componentsSeparatedByString:@" "];
    NSString *firstName = [nameParts objectAtIndex:0];
    NSString *lastName = [nameParts objectAtIndex:1];
    NSMutableString *fullName = [[NSMutableString alloc]initWithFormat:@"%@ %@",firstName,lastName];
    NSString *emailAddress = _emailAddress.text;
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(fullName));
	// This contact already exists in the addressbook. Check if its email address is blank
	if ((people != nil) && [people count]) {
		ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        //Check if the email address is set
        ABMutableMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
        if(emailMultiValue){
            NSString *email = (__bridge NSString *) ABMultiValueCopyValueAtIndex(emailMultiValue,0);
            if (email == nil || [email isEqualToString:@""]){
                //Create the new email and save
                emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
                bool didAddEmail = ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)(emailAddress), kABHomeLabel, NULL);
                
                if(didAddEmail){
                    ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, nil);
                    
                    ABAddressBookAddRecord(addressBook, person, &error);
                    ABAddressBookSave(addressBook, &error);
                    CFRelease(emailMultiValue);
                    CFRelease(person);
                    CFRelease(addressBook);
                }
            }
        }        
    }
	else {
        //Contact does not exist create new
        ABRecordRef person = ABPersonCreate();
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), nil);
        if (lastName != nil && ![lastName isEqualToString:@""])
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), nil);
        //create the email
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
        bool didAddEmail = ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)(emailAddress), kABHomeLabel, NULL);
        
        if(didAddEmail){
            ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, nil);
        }
        //Save the contact
        CFRelease(emailMultiValue);
        ABAddressBookAddRecord(addressBook, person, &error);
        ABAddressBookSave(addressBook, &error);
        
        //Add the contact to the group
        [[VariableStore sharedInstance] CheckIfGroupExistsWithName:@"Zion America"];
        //[self CheckIfGroupExistsWithName:@"Zion America"];
        ABRecordID groupId = [[VariableStore sharedInstance] groupId];
        ABRecordRef zionAmericaGroup = ABAddressBookGetGroupWithRecordID(addressBook, groupId);
        ABGroupAddMember(zionAmericaGroup, person, &error);
        ABAddressBookSave(addressBook, &error);
        
        CFRelease(person);
        CFRelease(addressBook);
    }
}

-(void) saveHistory {
    NSError *error;
    History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [history setDate:[NSDate date]];
    [history setRecipient:_emailName.text];
    [history setVideo:[VariableStore sharedInstance].videoName];
    if (![[[VariableStore sharedInstance] context] save:&error]) {
        // Handle the error.
    }
    history = nil;
}

//Retrieve the email for the auto completed name. If it exists
-(void) retrieveEmail {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(_emailName.text)));
    if ((people != nil) && [people count]) {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        ABMutableMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
        if(emailMultiValue){
            _emailAddress.text = (__bridge NSString *) ABMultiValueCopyValueAtIndex(emailMultiValue,0);
        }
    }
    else _emailAddress.text = @"";
}

@end
