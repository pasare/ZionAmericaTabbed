//
//  InboxDetailViewController.m
//  Zion America
//
//  Created by Patrick Asare on 1/4/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "InboxDetailViewController.h"

@interface InboxDetailViewController ()

@end

@implementation InboxDetailViewController

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
    [_bodyView setBackgroundColor:[UIColor clearColor]];
    _toLabel.layer.borderColor = [[UIColor grayColor] CGColor];;
    _toLabel.layer.borderWidth = 1.0;
    
    CTCoreMessage *currentEmail = [[VariableStore sharedInstance]selectedEmail];
    NSString *body = [currentEmail body];
    NSMutableString *fromText = [NSMutableString stringWithString:_fromLabel.text];
    NSMutableString *toText = [NSMutableString stringWithString:_toLabel.text];
    [fromText appendString:[[[currentEmail from] anyObject] name]];
    [toText appendString:[[[currentEmail to] anyObject]name]];
    _fromLabel.text = fromText;
    _toLabel.text = toText;
    _subjectLabel.text= [currentEmail subject];
    
    [_bodyView loadHTMLString:[body description] baseURL:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
