//
//  AddContactViewController.h
//  Zion America
//
//  Created by Patrick Asare on 2/14/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "VariableStore.h"

@interface AddContactViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *saveContactButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@property (weak, nonatomic) IBOutlet UITextField *contactName;
@property UIAlertView *failedContactAlert;
@property UIAlertView *successContactAlert;
@end
