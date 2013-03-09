//
//  HistoryViewController.m
//  Zion America
//
//  Created by Patrick Asare on 2/23/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

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
    _historyTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    [_historyTable setBackgroundView:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Notification for when table needs to be updated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSaved:)
                                                 name:@"DataSaved" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSError *error;
    [[[VariableStore sharedInstance] fetchedHistoryController] performFetch:&error];
    [_historyTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
} */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSFetchedResultsController * fetchedResultsController = [[VariableStore sharedInstance ]fetchedHistoryController];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyCell";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[HistoryCell class]])
        {
            cell = (HistoryCell *)currentObject;
            break;
        }
    }
    
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void) dataSaved:(NSNotification *)notification{
    NSError *error;
    [[[VariableStore sharedInstance] fetchedHistoryController] performFetch:&error];
    [_historyTable reloadData];
}

- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchedResultsController = [[VariableStore sharedInstance] fetchedHistoryController];
    NSManagedObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
    [self calculateDate:[object valueForKey:@"date"]];
    [[cell recipLabel] setText:[[object valueForKey:@"recipient"] description]];
    [[cell videoLabel] setText:[[object valueForKey:@"video"] description]];
    [[cell timeLabel] setText:[self calculateDate:[object valueForKey:@"date"]]];
    //cell.textLabel.text = [[object valueForKey:@"recipient"] description];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
}

-(NSString *)calculateDate:(NSDate *)calendarDate {
    NSCalendar *calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    NSDate *date = [NSDate date];
    NSTimeInterval secondsBetween = [date timeIntervalSinceDate:calendarDate];
    int numberOfDays = secondsBetween / 86400;
    NSString * dateString;
    
    
    //If it occured today than put the time
    if (numberOfDays <= 0) {
        dateString = [NSDateFormatter localizedStringFromDate:calendarDate
                                                    dateStyle:NSDateFormatterNoStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    }
    //If it occured during this week than put the day
    else if (numberOfDays < 7) {
        NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:calendarDate];
        int dayOfWeek = [weekdayComponents weekday];
        switch (dayOfWeek) {
            case 1:
                dateString = @"Sunday";
                break;
            case 2:
                dateString = @"Monday";
                break;
            case 3:
                dateString = @"Tuesday";
                break;
            case 4:
                dateString = @"Wednesday";
                break;
            case 5:
                dateString = @"Thursday";
                break;
            case 6:
                dateString = @"Friday";
                break;
            case 7:
                dateString = @"Saturday";
                break;
        }
    }
    //more than a week old put the date
    else {
        dateString = [NSDateFormatter localizedStringFromDate:calendarDate
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterNoStyle];
    }
    return dateString;
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
    
    NSPredicate *predicate = nil;
    if ([searchString length]) {
        if (searchOption == 0){
            predicate = [NSPredicate predicateWithFormat:@"recipient contains[cd] %@ OR video contains[cd] %@", searchString, searchString];
        }
        else {
            // docs say keys are case insensitive, but apparently not so.
            predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", [[controller.searchBar.scopeButtonTitles objectAtIndex:searchOption] lowercaseString], searchString];
        }
    }
    [[[VariableStore sharedInstance] fetchedHistoryController].fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![[[VariableStore sharedInstance] fetchedHistoryController] performFetch:&error]) {
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
    
    [[[VariableStore sharedInstance] fetchedHistoryController].fetchRequest setPredicate:nil];
    [[[VariableStore sharedInstance] fetchedHistoryController] performFetch:&error];
    [_historyTable reloadData];
	
}
@end
