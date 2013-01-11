//
//  SendEmailViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/30/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MailCore/MailCore.h>
#import "Constants.h"

@interface SendEmailViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *emailSubject;
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@property (weak, nonatomic) IBOutlet UITextField *emailName;
@property UITextField *activeField;
@property UITextView *activeView;
@property UIAlertView *statusAlert;
@property UIAlertView *emailAlert;
@end

