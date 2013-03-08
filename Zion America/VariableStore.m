//
//  VariableStore.m
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "VariableStore.h"

@implementation VariableStore
+ (VariableStore *)sharedInstance
{
    // the instance of this class is stored here
    static VariableStore *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

- (NSString*) loginID {
    return _loginID;
}

- (NSString*) loginPass {
    return _loginPass;
}

-(NSString*) videoName {
    return _videoName;
}

-(CTCoreMessage *)selectedEmail {
    return _selectedEmail;
}

-(NSString*)selectedContactName {
    return _selectedContactName;
}

-(NSString*)selectedContactEmail {
    return _selectedContactEmail;
}

-(NSString*)selectedContactPhone {
    return _selectedContactPhone;
}

-(NSArray*)contactsArray {
    return _contactsArray;
}

-(Contact *)updateContact {
    return _updateContact;
}

-(NSManagedObjectContext *)context {
    return _context;
}

- (NSFetchedResultsController*) fetchedContactsController{
    return _fetchedContactsController;
}

- (NSFetchedResultsController*) fetchedHistoryController{
    return _fetchedHistoryController;
}

// ADDED BY PHIL BROWNING ------------------------------------------------------
- (NSString*) smtpEmail {
    return _smtpEmail;
}

- (NSString*) smtpPassword {
    return _smtpPassword;
}

- (unsigned int) smtpPort {
    return _smtpServer;
}

- (NSString*) smtpServer {
    return _smtpServer;
}

- (NSString*) smtpUser {
    return _smtpUser;
}

- (NSString*) zionName {
    return _zionName;
}

// END -------------------------------------------------------------------------


//Methods for the iOS addressbook
-(void) displayContacts {
    
    __block BOOL accessGranted = NO;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else {
        accessGranted = YES;
    }
    
    
    if (accessGranted) {
        
        [self CheckIfGroupExistsWithName:@"Zion America"];
        ABRecordRef zionAmericaGroup = ABAddressBookGetGroupWithRecordID(addressBook,_groupId);
        [VariableStore sharedInstance].contactsArray = (__bridge_transfer NSArray*)ABGroupCopyArrayOfAllMembersWithSortOrdering(zionAmericaGroup, kABPersonSortByFirstName);
    }
    //CFRelease(addressBook);
}

//Check for group name
-(void) CheckIfGroupExistsWithName:(NSString*)groupName {
    
    
    BOOL hasGroup = NO;
    //checks to see if the group is created and creates group if it does not exist
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
    CFArrayRef groupLists= ABAddressBookCopyArrayOfAllGroups(addressBook);
    
    for (int i=0; i<groupCount; i++) {
        ABRecordRef currentCheckedGroup = CFArrayGetValueAtIndex(groupLists, i);
        NSString *currentGroupName = (__bridge NSString *)ABRecordCopyCompositeName(currentCheckedGroup);
        
        if ([currentGroupName isEqualToString:groupName]){
            //!!! important - save groupID for later use
            _groupId = ABRecordGetRecordID(currentCheckedGroup);
            hasGroup=YES;
        }
    }
    
    if (hasGroup==NO){
        //id the group does not exist you can create one
        [self createNewGroup:groupName];
    }
    
    CFRelease(addressBook);
}

-(void) createNewGroup:(NSString*)groupName {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef newGroup = ABGroupCreate();
    ABRecordSetValue(newGroup, kABGroupNameProperty,(__bridge CFTypeRef)(groupName), nil);
    ABAddressBookAddRecord(addressBook, newGroup, nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(addressBook);
    
    //save groupId for later use
    _groupId = ABRecordGetRecordID(newGroup);
    CFRelease(newGroup);
}
@end
