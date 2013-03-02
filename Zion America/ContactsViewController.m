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
    _searchBar.tintColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    _contactTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    [_contactTable setBackgroundView:nil];
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
    NSFetchedResultsController * fetchedResultsController = [[VariableStore sharedInstance ]fetchedContactsController];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    return cell;
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Contact *contact = [[[VariableStore sharedInstance] fetchedContactsController] objectAtIndexPath:indexPath];
    [VariableStore sharedInstance].selectedContact = contact;
    
    /*UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];
    SendVideoViewController *controller = (SendVideoViewController*)[mainStoryboard
                                                                     instantiateViewControllerWithIdentifier: @"sendVideoView"];
    [self.navigationController pushViewController:controller animated:YES]; */
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

//Code for search feature
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSInteger searchOption = controller.searchBar.selectedScopeButtonIndex;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString* searchString = controller.searchBar.text;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
    _searching = YES;
    NSPredicate *predicate = nil;
    if ([searchString length]) {
        if (searchOption == 0){ 
            predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR email contains[cd] %@", searchString, searchString];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", [[controller.searchBar.scopeButtonTitles objectAtIndex:searchOption] lowercaseString], searchString];
        }
    }
    [[[VariableStore sharedInstance] fetchedContactsController].fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![[[VariableStore sharedInstance] fetchedContactsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSError *error;
	searchBar.text = nil;
	[searchBar resignFirstResponder];
    _searching = NO;
    [[[VariableStore sharedInstance] fetchedContactsController].fetchRequest setPredicate:nil];
    [[[VariableStore sharedInstance] fetchedContactsController] performFetch:&error];
    [_contactTable reloadData];
	
}

//Index view on right hand side
/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if(_searching)
        return nil;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:UITableViewIndexSearch];
    [tempArray addObject:@"A"];
    [tempArray addObject:@"B"];
    [tempArray addObject:@"C"];
    [tempArray addObject:@"D"];
    [tempArray addObject:@"E"];
    [tempArray addObject:@"F"];
    [tempArray addObject:@"G"];
    [tempArray addObject:@"H"];
    [tempArray addObject:@"I"];
    [tempArray addObject:@"J"];
    [tempArray addObject:@"K"];
    [tempArray addObject:@"L"];
    [tempArray addObject:@"M"];
    [tempArray addObject:@"N"];
    [tempArray addObject:@"O"];
    [tempArray addObject:@"P"];
    [tempArray addObject:@"Q"];
    [tempArray addObject:@"R"];
    [tempArray addObject:@"S"];
    [tempArray addObject:@"T"];
    [tempArray addObject:@"U"];
    [tempArray addObject:@"V"];
    [tempArray addObject:@"W"];
    [tempArray addObject:@"X"];
    [tempArray addObject:@"Y"];
    [tempArray addObject:@"Z"];
    
    return tempArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        [tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
        return -1;
    }
    return index;
} */
@end
