//
//  HistoryViewController.h
//  Zion America
//
//  Created by Patrick Asare on 2/23/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryCell.h"
#import "VariableStore.h"

@interface HistoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property BOOL searching;
@property NSMutableArray *listOfItems;
@property BOOL letUserSelectRow;
@end
