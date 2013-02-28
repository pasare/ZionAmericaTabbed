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

@interface AddContactViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UITableView *addContactTable;
@property (weak, nonatomic) IBOutlet UIButton *saveContactButton;
@property (nonatomic, retain) UITextField *contactName;
@property (nonatomic, retain) UITextField *emailAddress;
@property (nonatomic, retain) UITextField *phoneNumber;
@property UIAlertView *failedContactAlert;
@property UIAlertView *successContactAlert;
@end
