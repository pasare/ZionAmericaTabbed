//
//  VariableStore.h
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "Reachability.h"

@interface VariableStore : NSObject
@property (nonatomic) NSString *loginID;
@property (nonatomic) NSString *loginPass;
@property (nonatomic) NSString *videoName;
@property (nonatomic) CTCoreMessage *selectedEmail;
@property (nonatomic) NSString *selectedContactName;
@property (nonatomic) NSString *selectedContactEmail;
@property (nonatomic) NSString *selectedContactPhone;
@property (nonatomic) NSArray *contactsArray;
@property (nonatomic) Contact *updateContact;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSFetchedResultsController *fetchedContactsController;
@property (nonatomic) NSFetchedResultsController *fetchedHistoryController;
@property ABRecordID groupId;
@property (nonatomic) BOOL accessGranted;

// ADDED BY PHIL BROWNING ------------------------------------------------------
@property (nonatomic) NSString *smtpEmail;
@property (nonatomic) NSString *smtpPassword;
@property (nonatomic) unsigned int smtpPort;
@property (nonatomic) NSString *smtpServer;
@property (nonatomic) NSString *smtpUser;
@property (nonatomic) NSString *zionName;
// END -------------------------------------------------------------------------


+ (VariableStore *)sharedInstance;
- (NSString*) loginID;
- (NSString*) loginPass;
- (NSString*) videoName;
- (CTCoreMessage*) selectedEmail;
- (NSString*) selectedContactName;
- (NSString*) selectedContactEmail;
- (NSString*) selectedContactPhone;
- (NSArray*) contactsArray;
- (Contact*) updateContact;
- (NSManagedObjectContext*) context;
- (NSFetchedResultsController*) fetchedContactsController;
- (NSFetchedResultsController*) fetchedHistoryController;
-(void) displayContacts;
-(void) CheckIfGroupExistsWithName:(NSString*)groupName;
-(BOOL)accessGranted;

// ADDED BY PHIL BROWNING ------------------------------------------------------
- (NSString*) smtpEmail;
- (NSString*) smtpPassword;
- (unsigned int) smtpPort;
- (NSString*) smtpServer;
- (NSString*) smtpUser;
- (NSString*) zionName;
// END -------------------------------------------------------------------------

- (BOOL)connected;
@end
