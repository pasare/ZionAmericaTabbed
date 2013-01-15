//
//  SendSmsViewController.h
//  Zion America
//
//  Created by Patrick Asare on 1/11/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

@interface SendSmsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;

@end
