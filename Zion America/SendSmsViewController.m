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
    //set the colors
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _phoneText.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    _phoneName.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    _commentView.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
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
    _commentView.layer.borderWidth = 3.0f;
    _commentView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            //Save this contact to the contact list
            BOOL duplicate = NO;
            NSError *error;
            NSFetchedResultsController *fetchedContacts = [[VariableStore sharedInstance]fetchedContactsController];
            NSArray *contactList = [fetchedContacts fetchedObjects];
            BOOL contactToDelete = NO;
            Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:[[VariableStore sharedInstance] context]];
            [contact setName:_phoneName.text];
            [contact setEmail:nil];
            [contact setPhone:_phoneText.text];
            [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
            
            //loop through the contact list checking for a duplicate contact
            for (Contact *currentContact in contactList){
                if ([contact duplicateContact:currentContact] ) {
                    //If the contact exists but the phone is blank copy the email and save again
                    if ([currentContact phone] == nil) {
                        [contact setName:_phoneName.text];
                        [contact setEmail:[currentContact email]];
                        [contact setPhone:_phoneText.text];
                        
                        //delete the old object
                        [[[VariableStore sharedInstance] context] deleteObject:currentContact];
                        
                        //replace with new object
                        if (![[[VariableStore sharedInstance] context] save:&error]) {
                            // Handle the error.
                        }
                        contactToDelete = YES;
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
            [[[VariableStore sharedInstance]context]deleteObject:contact];
            contact = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
            _phoneName.text = [contact name];
            _phoneText.text = [contact phone];
            //Display successful sms message
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
@end
