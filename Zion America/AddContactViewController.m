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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check if the user is editing the contact
    if ([VariableStore sharedInstance].updateContact != nil) {
        Contact *contact = [[VariableStore sharedInstance] updateContact ];
        _contactName.text = [contact name];
        _phoneNumber.text = [contact phone];
        _emailAddress.text = [contact email];
        _saveContactButton.titleLabel.text = @"Update Contact";
        
    }
    else {
        _contactName.text = @"";
        _phoneNumber.text = @"";
        _emailAddress.text = @"";
    }
	//Create the failed alert
    _failedContactAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The contact already exists!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    //Create the success alert
    _successContactAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"The contact was added successfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //loop through the contact list checking for a duplicate name
        /*for (Contact *currentContact in contactList){
            if ([contact duplicateContact:currentContact ]) {
                duplicate = YES;
            }
        } */
        if (!duplicate){
            NSError *error = nil;
            if (![[[VariableStore sharedInstance] context] save:&error]) {
                // Handle the error.
            }
            [_successContactAlert setMessage:@"The contact was added successfully, God bless you!"];
            [_successContactAlert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [self dismissViewControllerAnimated:YES completion:^(void){}];
        }
        else {
            [_failedContactAlert show];
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

@end
