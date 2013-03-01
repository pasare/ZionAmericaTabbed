//
//  VideoDetailViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/28/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "VideoDetailViewController.h"

@interface VideoDetailViewController ()

@end

@implementation VideoDetailViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedPosts = [defaults objectForKey:@"posts"];
    NSString *videoName = [[VariableStore sharedInstance]videoName ];
    NSDictionary *videoInfo;
	_videoLabel.text = videoName;
    //Retrieve the video information
    for (id currentPost in savedPosts)
    {
        if ([[currentPost objectForKey:@"post_title"] isEqualToString:videoName])
        {
            videoInfo = currentPost;
            
        }
    }
    //Set all of the decription labels
    _urlLabel.text = [videoInfo objectForKey:@"link"];
    //NSLog(@"Here I am %@",videoInfo);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
