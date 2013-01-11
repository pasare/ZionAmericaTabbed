//
//  Login_ViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *userID;
@property (nonatomic) NSMutableArray *zionsArray;
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
	
    //Create the logging in alert
    self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Verifying Login Information" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the failed login alert
    self.failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Incorrect username or password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    _zionsArray = [[NSMutableArray alloc] init];
    [_zionsArray addObject:@"Maryland Zion"];
    [_zionsArray addObject:@"DC Zion"];
    [_zionsArray addObject:@"New York Zion"];
    [_zionsArray addObject:@"Deleware Zion"];
    //Display the zion Label, check if a zion has been selected yet.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *zionName = [defaults objectForKey:@"zionName"];
    
    if (zionName != nil) {
        _zionNameLabel.text = zionName;
    }
    
    
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

-(IBAction)changeZion:(id)sender
{
    _zionPicker.hidden = NO;
}

- (IBAction)ProcessLogin:(id)sender
{
    if ([_zionNameLabel.text isEqualToString:@"No Zion Selected Yet"])
    {
        _failedLoginAlert.message = @"Please select your Zion before proceeding";
        [_failedLoginAlert show];
    }
    else {
        if ([_userID.text isEqualToString:@""])
        {
            _failedLoginAlert.message = @"Please enter a username";
            [_failedLoginAlert show];
        }
        else if ([_userPassword.text isEqualToString:@""])
        {
            _failedLoginAlert.message = @"Please enter a password";
            [_failedLoginAlert show];
        }
        else
        {
            [self.statusAlert show];
            [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tryLogin) userInfo:nil repeats:NO];
        }
    }
}

-(void)tryLogin
{
    self.loginID = self.userID.text;
    self.loginPass = self.userPassword.text;
    NSString *server = WPSERVER;
    WordPressConnection *connection = [WordPressConnection alloc];
    BOOL authResult = [connection authenticateUser:server username:self.loginID password: self.loginPass];
    [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
    if (authResult) {
        
        //Load the shared instance for all global variables
        VariableStore *globals =[VariableStore sharedInstance];
        globals.loginID = self.loginID;
        globals.loginPass = self.loginPass;
        
        NSLog(@"Authenticated");
        [self performSegueWithIdentifier: @"loginSegue" sender: self];
    } else {
        [self.failedLoginAlert show];
        NSLog(@"Bad login or password");
    }  
}

//Zion Picker methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [_zionsArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_zionsArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedZion = [_zionsArray objectAtIndex:row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:selectedZion forKey:@"zionName"];
    _zionNameLabel.text = selectedZion;
    _zionPicker.hidden = YES;
}

@end
