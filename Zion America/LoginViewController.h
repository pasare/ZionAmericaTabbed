//
//  Login_ViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (copy, nonatomic) NSString *loginID;
@property (copy, nonatomic) NSString *loginPass;

@end


