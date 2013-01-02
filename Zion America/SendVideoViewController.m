//
//  SendVideoControllerViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "SendVideoViewController.h"

@interface SendVideoViewController ()

@end

@implementation SendVideoViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add the searchbar to the view
    //_videoTable.tableHeaderView = _searchBar;
    _searching = NO;
    _letUserSelectRow = YES;
    _listOfItems = [[NSMutableArray alloc] init];
    
    
    //UIAlert for retrieving video list
	self.statusAlert = [[UIAlertView alloc] initWithTitle:@"Retrieving Video List" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //Insert a spinner on the status alert
    indicator.center = CGPointMake(self.statusAlert.bounds.size.width+140, self.statusAlert.bounds.size.height+100);
    [indicator startAnimating];
    [self.statusAlert addSubview:indicator];
    
    //Create the failed load alert
    self.failedVideoAlert = [[UIAlertView alloc] initWithTitle:@"List Error" message:@"unable to load the video list at this time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    //Load the video list from memory if possible
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *wpposts = [defaults objectForKey:@"posts"];
    
    //Load the video list from memory
    if (wpposts != nil) {
        [self loadVideoList:wpposts];
    }
    //Retrieve video list from server
    else {
        [self.statusAlert show];
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tryRetrieveVideoList) userInfo:nil repeats:NO];
    }
    //If the sync button is press, update the video list
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Sync" style:UIBarButtonItemStylePlain
                                              target:self action:@selector(updateList:)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Retrieve video list from memory
-(void) loadVideoList:(NSArray*) wpposts
{
    //Save the posts to defaults, to keep across sessions
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:wpposts forKey:@"posts"];
    
    if (wpposts != nil) {
        _tableArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        _englishArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        _spanishArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        
        //Find which group the video belongs to
        for (NSDictionary *element in wpposts) {
            if ([[[[element objectForKey:@"terms"]objectAtIndex:0]objectForKey:@"slug"]isEqualToString:@"english"]) {
                [_englishArray addObject:[element objectForKey:@"post_title"]];
            }
            else if ([[[[element objectForKey:@"terms"]objectAtIndex:1]objectForKey:@"slug"]isEqualToString:@"english"]){
                [_englishArray addObject:[element objectForKey:@"post_title"]];
            }
            else {
                [_spanishArray addObject:[element objectForKey:@"post_title"]];
            }
        }
        
        //Sort the smaller arrays and add to sectioning array
        _englishSorted = [_englishArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        _spanishSorted = [_spanishArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [_tableArray addObject:_englishSorted];
        [_tableArray addObject:_spanishSorted];
        [_listOfItems addObjectsFromArray:_englishSorted];
        [_listOfItems addObjectsFromArray:_spanishSorted];
        [_videoTable reloadData];
    }
    else {
        [self.failedVideoAlert show];
    }
}

//Retrieve video list from server
-(void) tryRetrieveVideoList
{
    NSString *server = WPSERVER;
    WordPressConnection *connection = [WordPressConnection alloc];
    NSDictionary *wpposts = [connection getPosts:server username: [[VariableStore sharedInstance] loginID] password:[[VariableStore sharedInstance] loginPass]];
    [self.statusAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    //Save the posts to defaults, to keep across sessions
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:wpposts forKey:@"posts"];

    if (wpposts != nil) {
        _tableArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        _englishArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        _spanishArray = [[NSMutableArray alloc] initWithCapacity:[wpposts count]];
        
        //Find which group the video belongs to
        for (NSDictionary *element in wpposts) {
            if ([[[[element objectForKey:@"terms"]objectAtIndex:0]objectForKey:@"slug"]isEqualToString:@"english"]) {
                [_englishArray addObject:[element objectForKey:@"post_title"]];
            }
            else if ([[[[element objectForKey:@"terms"]objectAtIndex:1]objectForKey:@"slug"]isEqualToString:@"english"]){
                [_englishArray addObject:[element objectForKey:@"post_title"]];
            }
            else {
                [_spanishArray addObject:[element objectForKey:@"post_title"]];
            }
        }
        
        //Sort the smaller arrays and add to sectioning array
        _englishSorted = [_englishArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        _spanishSorted = [_spanishArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [_tableArray addObject:_englishSorted];
        [_tableArray addObject:_spanishSorted];
        [_listOfItems addObjectsFromArray:_englishSorted];
        [_listOfItems addObjectsFromArray:_spanishSorted];
        [_videoTable reloadData];
    }
    else {
        [self.failedVideoAlert show];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searching)
        return 1;
    else
        return [_tableArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_searching)
        return @"Search Results";
    else {
    if(section == 0)
        return @"English";
    else
        return @"Spanish";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searching)
        return [_listOfItems count];
    else {
        NSArray *array = [_tableArray objectAtIndex:section];
        return [array count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (_searching){
        cell.textLabel.text = [_listOfItems objectAtIndex:indexPath.row];
        return cell;
    }
    else {
    //Add the cells by sections
        NSArray *array = [_tableArray objectAtIndex:indexPath.section];
        cell.textLabel.text = [array objectAtIndex:indexPath.row];
        return cell;
    }
}

//Get the selected row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selectedVideo = nil;
    
    if(_searching)
        selectedVideo = [_listOfItems objectAtIndex:indexPath.row];
    else {
        NSArray *array = [_tableArray objectAtIndex:indexPath.section];
        selectedVideo = [array objectAtIndex:indexPath.row];
    }
    [VariableStore sharedInstance].videoName = selectedVideo;
    [self performSegueWithIdentifier: @"videoDetailSegue" sender: self];
}

//Searching methods
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    
    _searching = YES;
    _letUserSelectRow = NO;
    _videoTable.scrollEnabled = NO;
    
    //Add the done button.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self action:@selector(doneSearching_Clicked:)];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_letUserSelectRow)
        return indexPath;
    else
        return nil;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    
    //Remove all objects first.
    [_listOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        
        _searching = YES;
        _letUserSelectRow = YES;
        _videoTable.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        
        _searching = NO;
        _letUserSelectRow = NO;
        _videoTable.scrollEnabled = NO;
    }
    
    [_videoTable reloadData];
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
    _videoTable.scrollEnabled = YES;
    //Recreate the sync button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Sync" style:UIBarButtonItemStylePlain
                                              target:self action:@selector(updateList:)];
    
    
    [_videoTable reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
    [self searchTableView];
}

//update the table
- (void) updateList:(id) sender{
    [_tableArray removeAllObjects];
    [_listOfItems removeAllObjects];
    [_videoTable reloadData];
    [self.statusAlert show];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tryRetrieveVideoList) userInfo:nil repeats:NO];
}

@end
