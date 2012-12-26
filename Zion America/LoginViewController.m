//
//  Login_ViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *userID;
- (IBAction)ProcessLogin:(id)sender;
@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to control the text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.userID) {
        [theTextField resignFirstResponder];
        [self.userPassword becomeFirstResponder ];
    }
    else if (theTextField == self.userPassword) {
        [theTextField resignFirstResponder];
        [self ProcessLogin:self];
    }
    return YES;
}

- (IBAction)ProcessLogin:(id)sender {
    self.loginID = self.userID.text;
    self.loginPass = self.userPassword.text;
    self.errorLabel.hidden = false;
    UIViewController *NextViewController = [[UIViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:NextViewController animated:YES];
}

@end
