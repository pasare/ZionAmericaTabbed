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
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3; //seconds
    //lpgr.delegate = self;
    [_contactTable addGestureRecognizer:lpgr];
    
    //[_contactTable setEditing:YES animated:YES];
    //Notification for when table needs to be updated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSaved:)
                                                 name:@"DataSaved" object:nil];
	// Do any additional setup after loading the view.
    _searching = NO;
    _letUserSelectRow = YES;
    _listOfItems = [[NSMutableArray alloc] init];
    //_tableArray = [[VariableStore sharedInstance] contactsArray];
    //NSLog(@"contactList %@",_tableArray);
}

-(void)viewDidAppear:(BOOL)animated
{
    //_tableArray = [[VariableStore sharedInstance] contactsArray];
   [_contactTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSFetchedResultsController * fetchedResultsController = [[VariableStore sharedInstance ]fetchedContactsController];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    if (_searching)
        return [_listOfItems count];
    else {
        return [_tableArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_searching){
        //Contact *contact = (Contact *) [_listOfItems objectAtIndex:indexPath.row];
        //cell.textLabel.text = [contact name];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else {
        //Contact *contact = (Contact *)[_tableArray objectAtIndex:indexPath.row];
        //cell.textLabel.text = [contact name];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Contact *selectedContact = [[[VariableStore sharedInstance] fetchedContactsController] objectAtIndexPath:indexPath];
    
    if(_searching){
        //selectedContact = [_listOfItems objectAtIndex:indexPath.row];
    }
    else {
        //selectedContact = [_tableArray objectAtIndex:indexPath.row];
    }
    [VariableStore sharedInstance].selectedContact = selectedContact;
    [self performSegueWithIdentifier: @"contactToEmailSegue" sender: self];
}




-(void) dataSaved:(NSNotification *)notification{
    NSError *error;
    [[[VariableStore sharedInstance] fetchedContactsController] performFetch:&error];
    [_contactTable reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_contactTable];
    
    NSIndexPath *indexPath = [_contactTable indexPathForRowAtPoint:p];
    if (indexPath == nil) {
     
    }
    else {
        Contact *contact = [[[VariableStore sharedInstance] fetchedContactsController] objectAtIndexPath:indexPath];
        [VariableStore sharedInstance].updateContact = contact;
            [self performSegueWithIdentifier: @"addContactSegue" sender: self];
        
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [[VariableStore sharedInstance] context];
        NSFetchedResultsController *fetchedResults = [[VariableStore sharedInstance]fetchedContactsController];
        [context deleteObject:[fetchedResults objectAtIndexPath:indexPath]];
        
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController * fetchedResultsController = [[VariableStore sharedInstance] fetchedContactsController];
    NSManagedObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

//Search bar features
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    
    _searching = YES;
    _letUserSelectRow = NO;
    
    //Add the done button.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(doneSearching_Clicked:)];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    
  /*  //Remove all objects first.
    [_listOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        
        _searching = YES;
        _letUserSelectRow = YES;
        [self searchTableView];
    }
    else {
        
        _searching = NO;
        _letUserSelectRow = NO;
    }
    
    [_contactTable reloadData]; */
}

- (void) searchTableView
{
    
    NSString *searchText = _searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    for (NSArray *array in _tableArray)
    {
        [searchArray addObjectsFromArray:array];
    }
    
    for (NSString *sTemp in searchArray)
    {
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [_listOfItems addObject:sTemp];
    }
    searchArray = nil;
}

- (void) doneSearching_Clicked:(id)sender
{
    
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
    _letUserSelectRow = YES;
    _searching = NO;
    
    
    [_contactTable reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
    [self searchTableView];
}
@end
