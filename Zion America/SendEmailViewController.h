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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "History.h"
#import "HTAutocompleteManager.h"
#import "HTAutocompleteTextField.h"
#import "VariableStore.h"

@interface SendEmailViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *sendEmailTable;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (nonatomic, retain) HTAutocompleteTextField *emailName;
@property (nonatomic, retain) UITextField *emailAddress;
@property (nonatomic, retain) UITextField *emailSubject;
@property UITextField *activeField;
@property UITextView *activeView;
@property UIAlertView *statusAlert;
@property UIAlertView *emailAlert;
@property UIAlertView *failedAlert;
@end

