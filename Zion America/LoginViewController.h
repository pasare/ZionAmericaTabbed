//
//  Login_ViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLRPCRequest.h"
#import "XMLRPCConnectionManager.h"
#import "XMLRPCResponse.h"
#import "WordPressConnection.h"
#import "Constants.h"
#import "VariableStore.h"


@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UITableView *loginTable;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (copy, nonatomic) NSString *loginID;
@property (copy, nonatomic) NSString *loginPass;
@property UIAlertView *statusAlert;
@property UIAlertView *failedLoginAlert;
@property UITextField *userID;
@property UITextField *userPassword ;
@end


