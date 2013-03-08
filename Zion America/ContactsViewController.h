//
//  ContactsViewController.h
//  Zion America
//
//  Created by Patrick Asare on 1/6/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableStore.h"
#import "Contact.h"
#import "SendVideoViewController.h"
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate,UIActionSheetDelegate, ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *contactTable;
@property (nonatomic, retain) UIActionSheet *sheet;
@property (nonatomic, retain) NSMutableDictionary *contactsDictionary;
@property (nonatomic, retain) NSMutableArray *listOfItems;
@property UIAlertView *successContactAlert;
@property ABRecordID groupId;

@end
