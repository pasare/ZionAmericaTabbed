//
//  VideoDetailViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/28/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "History.h"

@interface VideoDetailViewController : UIViewController< MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sendSMS;
@property (weak, nonatomic) IBOutlet UIButton *sendEmail;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (strong,retain) UIAlertView *failedAlert;
@property NSArray *recipients;
@property ABRecordID groupId;
@property NSString *contactName;
@property NSString *contactPhone;
@end
