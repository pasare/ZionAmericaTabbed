//
//  SendVideoControllerViewController.h
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WordPressConnection.h"
#import "VariableStore.h"
#import "VideoDetailViewController.h"

@interface SendVideoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property UIAlertView *statusAlert;
@property UIAlertView *failedVideoAlert;
@property NSMutableArray *tableArray;
@property NSMutableArray *englishArray;
@property NSMutableArray *spanishArray;
@property NSMutableArray *listOfItems;
@property NSArray *englishSorted;
@property NSArray *spanishSorted;
@property BOOL searching;
@property BOOL letUserSelectRow;

- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;
- (void) loadVideoList:(NSArray*) wpposts;
@end
