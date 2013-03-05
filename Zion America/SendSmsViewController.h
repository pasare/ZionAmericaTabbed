//
//  SendSmsViewController.h
//  Zion America
//
//  Created by Patrick Asare on 1/11/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "VariableStore.h"
#import "Contact.h"
#import "History.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface SendSmsViewController : UIViewController<MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property UITextField *phoneName;
@property UITextField *phoneText;
@property UIAlertView *statusAlert;
@property UIAlertView *failedAlert;
@property UITextView *activeView;
@property NSArray *recipients;

@end
