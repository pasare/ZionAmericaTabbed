//
//  AddContactViewController.m
//  Zion America
//
//  Created by Patrick Asare on 2/14/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "AddContactViewController.h"

@interface AddContactViewController ()

@end

@implementation AddContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated {
    [VariableStore sharedInstance].updateContact = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //set the colors
     self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    _addContactTable.backgroundColor = [UIColor clearColor];
    [_addContactTable setBackgroundView:nil];
    
    //Initalize variables
    _contactName = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _emailAddress = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    _phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 195, 21)];
    
    //Check if the user is editing the contact
    if ([VariableStore sharedInstance].updateContact != nil) {
        Contact *contact = [[VariableStore sharedInstance] updateContact ];
        _contactName.text = [contact name];
        _phoneNumber.text = [contact phone];
        _emailAddress.text = [contact email];
        _saveContactButton.titleLabel.text = @"Update Contact";
        _contactLabel.text = @"Updating Contact";
        NSLog(@"THis is the contact %@",[contact name]);
        
    }
    else {
        _contactName.text = @"";
        _phoneNumber.text = @"";
        _emailAddress.text = @"";
        _saveContactButton.titleLabel.text = @"Save Contact";
        _contactLabel.text = @"Add A Contact";
    }
	//Create the failed alert
    _failedContactAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The contact already exists! Why dont you try updating instead." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    //Create the success alert
    _successContactAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The contact was added successfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    [ _contactName resignFirstResponder];
    [ _emailAddress resignFirstResponder];
    [_phoneNumber resignFirstResponder];
}

- (IBAction)saveContact:(id)sender {
    Contact *contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [contact setName:_contactName.text];
    [contact setEmail:_emailAddress.text];
    [contact setPhone:_phoneNumber.text];
    
    
    BOOL duplicate = NO;
   
     //Save this contact to the contact list
     
    //First check if we are updating a contact or saving a new one
    if ([VariableStore sharedInstance].updateContact != nil) {
        
        NSError *error = nil;
        NSManagedObjectContext *context = [[VariableStore sharedInstance] context];
        [context deleteObject:[[VariableStore sharedInstance] updateContact]];
        if (![[[VariableStore sharedInstance] context] save:&error]) {
            // Handle the error.
        }
        [_successContactAlert setMessage:@"The contact has been updated successfully, God bless you!"];
        [_successContactAlert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
        [self dismissViewControllerAnimated:YES completion:^(void){}];
        
    }
    else {
        NSFetchedResultsController *fetchedContacts = [[VariableStore sharedInstance]fetchedContactsController];
        NSArray *contactList = [fetchedContacts fetchedObjects];
        
        //loop through the contact list checking for a duplicate name
        for (Contact *currentContact in contactList){
            if ([contact duplicateContact:currentContact ]) {
                duplicate = YES;
                break;
            }
        } 
        if (!duplicate){
            NSError *error = nil;
            if (![[[VariableStore sharedInstance] context] save:&error]) {
                // Handle the error.
            }
            [_successContactAlert setMessage:@"The contact was added successfully, God bless you!"];
            [_successContactAlert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            contact = nil;
            [self dismissViewControllerAnimated:YES completion:^(void){}];
        }
        else {
            [_failedContactAlert show];
            //clear the contact so that it does not get saved
            [[[VariableStore sharedInstance]context]deleteObject:contact];
            contact = nil;
            [self dismissViewControllerAnimated:YES completion:^(void){}];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == _contactName) {
        [theTextField resignFirstResponder];
        [_emailAddress becomeFirstResponder ];
    }
    else if (theTextField == _emailAddress) {
        [theTextField resignFirstResponder];
        [_phoneNumber becomeFirstResponder];
    }
    else if (theTextField == _phoneNumber) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

//Create the group cells look for textboxes
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if( cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (indexPath.row == 0) {
        
        _contactName.autocorrectionType = UITextAutocorrectionTypeNo;
        [_contactName setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Name";
        cell.accessoryView = _contactName ;
    }
    if (indexPath.row == 1) {
        
        _emailAddress.autocorrectionType = UITextAutocorrectionTypeNo;
        [_emailAddress setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Email";
        cell.accessoryView = _emailAddress;
    }
    if (indexPath.row == 2) {
        
        _phoneNumber.autocorrectionType = UITextAutocorrectionTypeNo;
        [_phoneNumber setKeyboardType:UIKeyboardTypePhonePad];
        [_phoneNumber setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.textLabel.text = @"Number";
        cell.accessoryView = _phoneNumber;
    }
    _contactName.delegate = self;
    _emailAddress.delegate = self;
    _phoneNumber.delegate = self;
    
    
    [_addContactTable addSubview:_contactName];
    [_addContactTable addSubview:_emailAddress];
    [_addContactTable addSubview:_phoneNumber];
    //cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.backgroundColor = [UIColor colorWithRed:210/255.0f green:226/255.0f blue:245/255.0f alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
