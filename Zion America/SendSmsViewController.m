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
    [self sendSms];
    //set the colors
    /*self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _sendSmsTable.backgroundColor = [UIColor clearColor];
    [_sendSmsTable setBackgroundView:nil];
    _commentView.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1]; */
    
    /*//Initalize variables
    _phoneName = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _phoneText = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)]; */
    
    //Create the failed message alert
    self.failedAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Message Sent Sucessfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) sendSms {
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
        
        NSString *bodyText =[[NSString alloc] initWithFormat:@"\rPlease enjoy this video titled: %@\r%@",videoName,videoUrl];
		controller.body = bodyText;
		controller.recipients = [NSArray arrayWithObjects:_phoneText.text, nil];
		controller.messageComposeDelegate = self;
        //controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self presentViewController:controller animated:NO completion:^(void){}];
	}
}

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
	switch (result)
	{
		case MessageComposeResultCancelled:
            
			break;
            
		case MessageComposeResultSent:{
            
            [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
            _recipients = controller.recipients;
            
            //Check if the contact that was texted exists
            //add item to history
            [self saveHistory];
            
            //Display successful sms message
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
            [_failedAlert show];
			break;
        }
		case MessageComposeResultFailed:
            [_failedAlert setMessage:@"SMS sending failed"];
            [_failedAlert show];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self performSegueWithIdentifier: @"smsSentSegue" sender: self];
			break;
		default:
            [_failedAlert setMessage:@"Unable to send message at this time"];
            [_failedAlert show];
            //[self performSegueWithIdentifier: @"smsSentSegue" sender: self];
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void) saveHistory{
    NSError *error;
    History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [history setDate:[NSDate date]];
    
    if ([VariableStore sharedInstance].selectedContactName != nil)
        [history setRecipient:[VariableStore sharedInstance].selectedContactName];
    else {
        [history setRecipient:@"Unknown"];
    }
    
    [history setVideo:[[VariableStore sharedInstance] videoName ]];
    //save the newly created history item
    if (![[[VariableStore sharedInstance] context] save:&error]) {
        // Handle the error.
    }
    history = nil;
}

@end
