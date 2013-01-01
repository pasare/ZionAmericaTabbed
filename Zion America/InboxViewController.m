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
	CTCoreAccount *account = [[CTCoreAccount alloc] init];
    [account connectToServer:@"mail.marylandzion.org" port:143 connectionType:CONNECTION_TYPE_PLAIN authType:IMAP_AUTH_TYPE_PLAIN login:@"info@marylandzion.org" password:@"M4ryl4ndZ1on!"];
    CTCoreFolder *inbox = [account folderWithPath:@"INBOX"];
    NSArray *messageList = [inbox messagesFromUID:1 to:0 withFetchAttributes:nil];
    for (CTCoreMessage *message in messageList) {
        NSLog(@"message %@",message.to);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
