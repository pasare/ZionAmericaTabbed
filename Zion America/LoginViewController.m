//
//  Login_ViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController()
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

- (void)viewDidAppear:(BOOL)animated {
    //self.navigationController.tabBarController =nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    _copyrightLabel.text = [NSString stringWithFormat:@"\u00A9 %@ Zion America, All Rights Reserved",yearString];
    //set background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Zion America v2_login_bg only_no text_2.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    

    _loginTable.backgroundColor = [UIColor clearColor];
    [_loginTable setBackgroundView:nil];
    //Create the logging in alert
    self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Verifying Login Information" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the failed login alert
    self.failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Incorrect username or password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Method to control the text fields

-(void)dismissKeyboard
{
    [ _userID resignFirstResponder];
    [ _userPassword resignFirstResponder];
}

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


- (IBAction)ProcessLogin:(id)sender
{
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
        if(![[VariableStore sharedInstance] connected]) {
            UIAlertView *noaccess = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"An active internet connection is required to use this application" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
            [noaccess show];
        }else{
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
        
        //Retieve the contacts
        [[VariableStore sharedInstance] displayContacts];
        
        NSLog(@"Authenticated");
        
        // ADDED BY PHIL BROWNING ----------------------------------------------
        NSMutableDictionary *emailCredentials = [connection getEmailCredentials:server username:globals.loginID password:globals.loginPass];
        
        if (emailCredentials != nil && [emailCredentials count]) {
            globals.zionName = emailCredentials[@"name"];
            globals.smtpEmail = emailCredentials[@"email"];
            globals.smtpPassword = emailCredentials[@"smtp_pass"];
            globals.smtpPort = [emailCredentials[@"smtp_port"] unsignedIntValue];
            globals.smtpServer = emailCredentials[@"smtp_server"];
            globals.smtpUser = emailCredentials[@"smtp_user"];
        }
        
        // END -----------------------------------------------------------------
        
        [self performSegueWithIdentifier: @"loginSegue" sender: self];
    } else {
        [self.failedLoginAlert show];
        NSLog(@"Bad login or password");
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if( cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (indexPath.row == 0) {
        _userID = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
        _userID.autocorrectionType = UITextAutocorrectionTypeNo;
        [_userID setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_userID setReturnKeyType:UIReturnKeyNext];
        _userID.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.textLabel.text = @"Username";
        cell.accessoryView = _userID ;
    }
    if (indexPath.row == 1) {
        _userPassword = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
        _userPassword.secureTextEntry = YES;
        _userPassword.autocorrectionType = UITextAutocorrectionTypeNo;
        [_userPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_userPassword setReturnKeyType:UIReturnKeyDone];
        cell.textLabel.text = @"Password";
        cell.accessoryView = _userPassword;
    }
    _userID.delegate = self;
    _userPassword.delegate = self;
    
    
    [_loginTable addSubview:_userID];
    [_loginTable addSubview:_userPassword];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
