//
//  HomeViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/26/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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

    NSString *server = WPSERVER;
    WordPressConnection *connection = [WordPressConnection alloc];
    NSDictionary *wpusers = [connection getUsers:server username: [[VariableStore sharedInstance] loginID] password:[[VariableStore sharedInstance] loginPass]];
    NSString *username = _userNameLabel.text;
    for (id user in wpusers) {
        if ([[user objectForKey:@"username"]isEqualToString:[[VariableStore sharedInstance]loginID]]) {
            username = [username stringByAppendingString:[user objectForKey:@"first_name"]];
            username = [username stringByAppendingString:@" "];
            username = [username stringByAppendingString:[user objectForKey:@"last_name"]];
        }
    }
    
    _userNameLabel.text = username;
    //NSLog(@"Users %@",wpusers);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
