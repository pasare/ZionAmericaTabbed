//
//  VariableStore.h
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>
#import "Contact.h"

@interface VariableStore : NSObject
@property (nonatomic) NSString *loginID;
@property (nonatomic) NSString *loginPass;
@property (nonatomic) NSString *videoName;
@property (nonatomic) CTCoreMessage *selectedEmail;
@property (nonatomic) NSString *selectedContactName;
@property (nonatomic) NSString *selectedContactEmail;
@property (nonatomic) NSString *selectedContactPhone;
@property (nonatomic) Contact *updateContact;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSFetchedResultsController *fetchedContactsController;
@property (nonatomic) NSFetchedResultsController *fetchedHistoryController;

+ (VariableStore *)sharedInstance;
- (NSString*) loginID;
- (NSString*) loginPass;
- (NSString*) videoName;
- (CTCoreMessage*) selectedEmail;
- (NSString*) selectedContactName;
- (NSString*) selectedContactEmail;
- (NSString*) selectedContactPhone;
- (Contact*) updateContact;
- (NSManagedObjectContext*) context;
- (NSFetchedResultsController*) fetchedContactsController;
- (NSFetchedResultsController*) fetchedHistoryController;
@end
