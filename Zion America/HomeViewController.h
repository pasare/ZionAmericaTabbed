//
//  HomeViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/26/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordPressConnection.h"
#import "VariableStore.h"

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *displayEmailCount;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;


@end
