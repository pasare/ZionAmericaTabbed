//
//  ContactsViewController.h
//  Zion America
//
//  Created by Patrick Asare on 1/6/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property NSArray *tableArray;
@property NSMutableArray *listOfItems;
@property BOOL searching;
@property BOOL letUserSelectRow;
@end
