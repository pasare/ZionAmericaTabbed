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

- (BOOL) accessGranted{
    return _accessGranted;
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
    
    _accessGranted = NO;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        //First time access granted
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            _accessGranted = granted;
            });
        }
        // Authorized access
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            _accessGranted = YES;
        }
        else {
            //Access has been denied
            UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to access contacts, in order to be fully functional this application requires access to contacts" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
            [failedAlert show];
        }
    }
    //Legacy device access request is not required
    else {
        _accessGranted = YES;
    }
    
    
    if (_accessGranted) {
        NSArray *tempContactsArray;
        NSMutableArray *returnedContactsArray = [[NSMutableArray alloc] init];
        [self CheckIfGroupExistsWithName:@"Zion America"];
        ABRecordRef zionAmericaGroup = ABAddressBookGetGroupWithRecordID(addressBook,[[VariableStore sharedInstance] groupId]);
        tempContactsArray = (__bridge_transfer NSArray*)ABGroupCopyArrayOfAllMembersWithSortOrdering(zionAmericaGroup, kABPersonSortByFirstName);
        NSString *firstName=@"";
        NSString *lastName=@"";
        NSMutableString *fullName;
        for (int i=0; i<[tempContactsArray count]; i++) {
            firstName =(__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([tempContactsArray objectAtIndex:i]) , kABPersonFirstNameProperty);
            lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([tempContactsArray objectAtIndex:i]), kABPersonLastNameProperty);
            if (lastName != nil )
                fullName = [[NSMutableString alloc] initWithFormat:@"%@ %@",firstName,lastName];
            else
                fullName = [[NSMutableString alloc] initWithFormat:@"%@",firstName ] ;
            [returnedContactsArray addObject:fullName];
        }
        [[VariableStore sharedInstance] setContactsArray:returnedContactsArray];
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

//Check network connection
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}
@end
