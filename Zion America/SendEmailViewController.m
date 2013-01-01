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
    //Set up mailer alert
    
    
	// Do any additional setup after loading the view.
    _commentView.layer.borderWidth = 3.0f;
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
        [_scrollView setContentOffset:CGPointMake(0.0, _activeView.frame.origin.y-kbSize.height+100) animated:YES];
    }
}

- (void)keyboardDidHide: (NSNotification*) aNotification
{

}

//send the email
- (void) sendEmail:(id) sender
{
    
    CTCoreMessage *msg = [[CTCoreMessage alloc] init];
    CTCoreAddress *toAddress = [CTCoreAddress addressWithName:_emailName.text
                                                        email:_emailAddress.text];
    [msg setTo:[NSSet setWithObject:toAddress]];
    [msg setBody:_commentView.text];
    
    NSError *error;
    BOOL success = [CTSMTPConnection sendMessage:msg
                                          server:@"mail.marylandzion.org"
                                        username:@"info@marylandzion.org"
                                        password:@"M4ryl4ndZ1on!"
                                            port:26
                                  connectionType:CTSMTPConnectionTypeTLS
                                         useAuth:YES
                                           error:&error];
    if (success) {
        NSLog(@"Email sent successfully");
    }
    else {
        NSLog(@"An error was encountered while sending the email %@", error);
    }
}

@end
