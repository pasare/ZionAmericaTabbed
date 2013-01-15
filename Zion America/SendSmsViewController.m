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
    MFMessageComposeViewController *controller /*= [[MFMessageComposeViewController alloc] init]*/;
    /*if([MFMessageComposeViewController canSendText])
	{
		controller.body = @"Hello from Mugunth";
		controller.recipients = [NSArray arrayWithObjects:@"12345678", @"87654321", nil];
		//controller.messageComposeDelegate = self;
		//[self presentModalViewController:controller animated:YES];
	} */
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
    
}
@end
