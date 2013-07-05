//
//  ContactsViewController.m
//  Zion America
//
//  Created by Patrick Asare on 1/6/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "ContactsViewController.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

bool _searching = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //Get the order contacts
    [self getContacts];
    
    _listOfItems = [[NSMutableArray alloc] init];
    _searchBar.tintColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    //_contactTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _contactTable.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    [_contactTable setBackgroundView:nil];
    
    //Create the success alert
    _successContactAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The contact was added successfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    //Notification for when table needs to be updated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSaved:)
                                                 name:@"DataSaved" object:nil];
    
    //get the contacts from the address book
    //[self displayContacts];
}

-(void)viewDidAppear:(BOOL)animated
{
   [_contactTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searching)
        return 1;
    else {
        return [[_contactsDictionary allKeys] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_searching)
        return @"Search Results";
    else
        return [_contactsDictionary keyAtIndex:section];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searching)
        return [_listOfItems count];
    else {
        return [[_contactsDictionary objectAtIndex:section] count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactCell";
    NSArray *currentSection;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_searching){
        cell.textLabel.text = [_listOfItems objectAtIndex:indexPath.row];
    }
    else {
        currentSection = [_contactsDictionary objectAtIndex:indexPath.section];
        cell.textLabel.text = [currentSection objectAtIndex:indexPath.row];
    }
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    return cell;
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *usedArray;
    if(_searching)
        usedArray = _listOfItems;
    else {
        usedArray = [[VariableStore sharedInstance] contactsArray];
        NSArray *currentContacts = [_contactsDictionary objectAtIndex:indexPath.section];
        NSString *contactName = [currentContacts objectAtIndex:indexPath.row];
        [[VariableStore sharedInstance] setSelectedContactName:contactName];
    
        //Retrieve the person
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
        NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(contactName));
        if ((people != nil) && [people count])
        {
            ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
            //Get the first non null email
            ABMultiValueRef multiEmail = ABRecordCopyValue((person), kABPersonEmailProperty);
            [VariableStore sharedInstance].selectedContactEmail = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multiEmail, 0);
            //Get first non null phone number
            ABMultiValueRef multiPhone = ABRecordCopyValue((person), kABPersonPhoneProperty);
            [VariableStore sharedInstance].selectedContactPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multiPhone, 0);
        }
        else
        {
            // Show an alert if contact is not in addressbook
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Could not find the contact in your addressbook"
													   delegate:nil
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:nil];
            [alert show];

        }
    
    }
    //[[VariableStore sharedInstance] setContactSelected:YES];
    //if ([[VariableStore sharedInstance] videoSelected])
        //[self performSegueWithIdentifier:@"contactToDetailSegue" sender:self];
    //else
        [self performSegueWithIdentifier: @"contactToEmailSegue" sender: self];
}




-(void) dataSaved:(NSNotification *)notification{
    if ([VariableStore sharedInstance].accessGranted) {
        [[VariableStore sharedInstance] displayContacts];
        [self getContacts];
    }
    [_contactTable reloadData];
}


- (IBAction)confirmLogout:(id)sender {
    _sheet = [[UIActionSheet alloc] initWithTitle:@"You will be logged out of the system"
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Confirm"
                                otherButtonTitles:nil];
    
    // Show the sheet
    [_sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //Logout confirmed
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier: @"logoutSegue" sender: self];
    }
}

//search methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [_listOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        _searching = YES;
        [self searchTableView];
    }
    else {
        _searching = NO;
    }
    [_contactTable reloadData];
}

- (void) searchTableView {
    
    NSString *searchText = _searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<[[_contactsDictionary allKeys] count]; i++) {
        [searchArray addObjectsFromArray:[_contactsDictionary objectAtIndex:i]];
    }
    NSString *personName;
    for (int i=0; i<[searchArray count]; i++) {
        
        personName = [searchArray objectAtIndex:i];
        NSRange titleResultsRange = [personName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResultsRange.length > 0)
            [_listOfItems addObject:[searchArray objectAtIndex:i]];
    }
    searchArray = nil;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = nil;
	[searchBar resignFirstResponder];
    _searching = NO;
    [_contactTable reloadData];
	
}

//Return an order dictionary of contacts for the contact list
-(void)getContacts {
    NSArray *contacts = [[VariableStore sharedInstance] contactsArray];
    _contactsDictionary = [OrderedDictionary dictionary];
    NSString *firstCharacter;
    NSMutableArray *group;
    int index = 0;
    for (NSString *contact in contacts) {
        firstCharacter = [[contact substringToIndex:1] uppercaseString];
        
        if ([_contactsDictionary valueForKey:firstCharacter] != nil){
            group = [[_contactsDictionary valueForKey:firstCharacter]mutableCopy];
            [group addObject:contact];
            [_contactsDictionary setValue:group forKey:firstCharacter];
        }
        else {
            NSArray *newGroup = [[NSArray alloc]initWithObjects:contact, nil];
            [_contactsDictionary insertObject:newGroup forKey:firstCharacter atIndex:index];
            index++;
        }
    }
}

    
//Add contact functions
- (IBAction)addContact:(id)sender {
    ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
    view.newPersonViewDelegate = self;
    
    UINavigationController *newNavigationController = [[UINavigationController alloc]
                                                       initWithRootViewController:view];
    [self presentViewController:newNavigationController animated:YES completion:^(void){}];
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    if (person) {
        CFErrorRef error = NULL;
        ABRecordID groupId = [[VariableStore sharedInstance] groupId];
        ABRecordRef zionAmericaGroup = ABAddressBookGetGroupWithRecordID(newPersonViewController.addressBook, groupId);
        ABGroupAddMember(zionAmericaGroup, person, &error);
        ABAddressBookSave(newPersonViewController.addressBook, &error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

//Edit contact functions
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Retrieve contact name from dictionary
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    NSArray *contactsGroup = [_contactsDictionary objectAtIndex:indexPath.section];
    NSString *contactName = [contactsGroup objectAtIndex:indexPath.row];
    NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(contactName));
    
    if ((people != nil) && [people count])
    {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        ABPersonViewController *personView = [[ABPersonViewController alloc] init];
        personView.personViewDelegate = self;
        personView.displayedPerson = person;
        personView.allowsEditing = YES;
        NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                               [NSNumber numberWithInt:kABPersonEmailProperty],[NSNumber numberWithInt:kABPersonNoteProperty], nil];
        personView.displayedProperties = displayedItems;
        [self.navigationController pushViewController:personView animated:YES];
    }
    else {
        // Show an alert if contact is not in addressbook
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Could not find the contact in your addressbook"
													   delegate:nil
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:nil];
        [alert show];
    }
    
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
    return NO;
}

@end
