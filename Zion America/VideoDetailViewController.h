//
//  VideoDetailViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/28/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDetailViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIButton *sendSMS;
@property (weak, nonatomic) IBOutlet UIButton *sendEmail;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property NSString *selectedVideo;
@end
