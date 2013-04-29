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
    _contactsDictionary = [[NSMutableDictionary alloc]init];
    _listOfItems = [[NSMutableArray alloc] init];
    _searchBar.tintColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    _contactTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    //_contactTable.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searching)
        return [_listOfItems count];
    else {
        return [[VariableStore sharedInstance].contactsArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *firstName;
    NSString *lastName;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_searching){
        firstName =(__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([_listOfItems objectAtIndex:indexPath.row]), kABPersonFirstNameProperty);
        lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([_listOfItems objectAtIndex:indexPath.row]), kABPersonLastNameProperty);
    }
    else {
        NSArray *contactsArray = [[VariableStore sharedInstance] contactsArray];
        firstName =(__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([contactsArray objectAtIndex:indexPath.row]), kABPersonFirstNameProperty);
        lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([contactsArray objectAtIndex:indexPath.row]), kABPersonLastNameProperty);
    }
    NSMutableString *personName;
    if (lastName != nil)
        personName = [[NSMutableString alloc] initWithFormat:@"%@ %@",firstName,lastName];
    else
        personName = [[NSMutableString alloc] initWithFormat:@"%@",firstName];
    cell.textLabel.text = personName;
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
    }
    NSString* firstName =(__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([usedArray objectAtIndex:indexPath.row]), kABPersonFirstNameProperty);
    NSString* lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([usedArray objectAtIndex:indexPath.row]), kABPersonLastNameProperty);
    [VariableStore sharedInstance].selectedContactName = [[NSMutableString alloc] initWithFormat:@"%@ %@",firstName,lastName];
    //Get the first non null email
    ABMultiValueRef multiEmail = ABRecordCopyValue((__bridge ABRecordRef)([usedArray objectAtIndex:indexPath.row]), kABPersonEmailProperty);
    [VariableStore sharedInstance].selectedContactEmail = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multiEmail, 0);
    //Get first non null phone number
    ABMultiValueRef multiPhone = ABRecordCopyValue((__bridge ABRecordRef)([usedArray objectAtIndex:indexPath.row]), kABPersonPhoneProperty);
    [VariableStore sharedInstance].selectedContactPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multiPhone, 0);
    
    //[[VariableStore sharedInstance] setContactSelected:YES];
    //if ([[VariableStore sharedInstance] videoSelected])
        //[self performSegueWithIdentifier:@"contactToDetailSegue" sender:self];
    //else
        [self performSegueWithIdentifier: @"contactToEmailSegue" sender: self];
}




-(void) dataSaved:(NSNotification *)notification{
    if ([VariableStore sharedInstance].accessGranted)
        [[VariableStore sharedInstance] displayContacts];
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
    NSArray *contactsArray = [[VariableStore sharedInstance] contactsArray];
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    [searchArray addObjectsFromArray:contactsArray];
    NSString *firstName;
    NSString *lastName;
    NSMutableString *personName;
    for (int i=0; i<[searchArray count]; i++) {
        firstName =(__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([searchArray objectAtIndex:i]), kABPersonFirstNameProperty);
        lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)([searchArray objectAtIndex:i]), kABPersonLastNameProperty);
        personName = [[NSMutableString alloc] initWithFormat:@"%@ %@",firstName,lastName];
    
        NSRange titleResultsRange = [personName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResultsRange.length > 0)
        [_listOfItems addObject:[contactsArray objectAtIndex:i]];
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
    ABPersonViewController *personView = [[ABPersonViewController alloc] init];
    personView.personViewDelegate = self;
    personView.displayedPerson = (__bridge ABRecordRef)([[VariableStore sharedInstance].contactsArray objectAtIndex:indexPath.row]);
    personView.allowsEditing = YES;
    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                               [NSNumber numberWithInt:kABPersonEmailProperty],[NSNumber numberWithInt:kABPersonNoteProperty], nil];
    personView.displayedProperties = displayedItems;
    [self.navigationController pushViewController:personView animated:YES];
    
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
    return NO;
}

@end
