//
//  InboxViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/31/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MailCore/MailCore.h>
#import "VariableStore.h"
#import "InboxCell.h"

@interface InboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *inboxNavigationItem;
@property (weak, nonatomic) IBOutlet UITableView *emailTable;
@property UIAlertView *statusAlert;
@property UIAlertView *failedVideoAlert;
@property NSArray *tableArray;
@property NSMutableArray *listOfItems;
@property BOOL searching;
@property BOOL letUserSelectRow;
@end
