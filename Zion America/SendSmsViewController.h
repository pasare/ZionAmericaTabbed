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

@interface SendSmsViewController : UIViewController<MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneName;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property UIAlertView *statusAlert;
@property UIAlertView *failedAlert;

@end
