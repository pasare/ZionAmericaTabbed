//
//  VideoDetailViewController.m
//  Zion America
//
//  Created by Patrick Asare on 12/28/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "VideoDetailViewController.h"

@interface VideoDetailViewController ()

@end

@implementation VideoDetailViewController

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
    //Create the failed message alert
    _failedAlert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Message Sent Sucessfully, God bless you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil ];
    
    //Get the url and name of the video
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:41/255.0f blue:92/255.0f alpha:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedPosts = [defaults objectForKey:@"posts"];
    NSString *videoName = [[VariableStore sharedInstance]videoName ];
    NSDictionary *videoInfo;
	_videoLabel.text = videoName;
    //Retrieve the video information
    for (id currentPost in savedPosts)
    {
        if ([[currentPost objectForKey:@"post_title"] isEqualToString:videoName])
        {
            videoInfo = currentPost;
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendSms:(id)sender {
    
    if ([VariableStore sharedInstance].selectedContactName == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save History?" message:@"In order to save the history please provide the contacts name" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:@"Don't Save",nil];
         alert.alertViewStyle = UIAlertViewStylePlainTextInput;
         [alert show];
    }
    else {
        [self composeSms];
    }
}

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
	if (!result) {
        [self dismissViewControllerAnimated:YES completion:^(void){}];
    }
    switch (result)
	{
		case MessageComposeResultCancelled:
            
			break;
            
		case MessageComposeResultSent:{
            
            _recipients = controller.recipients;
            
            //Check if the contact that was texted exists and save if it dosent
            //[self saveContact];
            
            
            //add item to history
            [self saveHistory];
            
            //Display successful sms message
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSaved" object:nil];
            [VariableStore sharedInstance].selectedContactName = nil;
            [VariableStore sharedInstance].selectedContactPhone = nil;
            [VariableStore sharedInstance].selectedContactEmail = nil;
            [self dismissViewControllerAnimated:YES completion:^(void){}];
            [_failedAlert show];
            
            
            
			break;
        }
		case MessageComposeResultFailed:
            [_failedAlert setMessage:@"SMS sending failed"];
            [_failedAlert show];
			break;
		default:
            [_failedAlert setMessage:@"Unable to send message at this time"];
            [_failedAlert show];
			break;
	}

}

/*-(void) saveContact {
    //If recipients is empty than the contact does not exist in the address book
    if (![_recipients count]) {
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        NSArray *nameParts = [_contactName componentsSeparatedByString:@" "];
        NSString *firstName = [nameParts objectAtIndex:0];
        NSString *lastName = [nameParts objectAtIndex:1];
        
        ABRecordRef person = ABPersonCreate();
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), nil);
        if (lastName != nil && ![lastName isEqualToString:@""])
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), nil);
        
        //create the phone number
        ABMutableMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        bool didAddPhone = ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFTypeRef)(_contactPhone), kABPersonPhoneMobileLabel, NULL);
        
        if(didAddPhone){
            ABRecordSetValue(person, kABPersonEmailProperty, phoneMultiValue, nil);
        }
        
        
        
        
        //if the person hits the save button than continue. Otherwise exit.
        /*if (_contactPhone != nil && _contactName != nil) {
            
            //Save the contact
            CFRelease(phoneMultiValue);
            ABAddressBookAddRecord(addressBook, person, &error);
            ABAddressBookSave(addressBook, &error);
            
            //Add the contact to the group
            [self CheckIfGroupExistsWithName:@"Zion America"];
            
            ABRecordRef zionAmericaGroup = ABAddressBookGetGroupWithRecordID(addressBook, _groupId);
            ABGroupAddMember(zionAmericaGroup, person, &error);
            ABAddressBookSave(addressBook, &error);
            
            CFRelease(person);
            CFRelease(addressBook);
            _contactPhone = nil;
        }
    }
} */
-(void) saveHistory{
    NSError *error;
    History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:[[VariableStore sharedInstance] context]];
    [history setDate:[NSDate date]];
    
    if ([VariableStore sharedInstance].selectedContactName != nil)
        [history setRecipient:[VariableStore sharedInstance].selectedContactName];
    else {
           [history setRecipient:@"Unknown"];
    }
    
    [history setVideo:[[VariableStore sharedInstance] videoName ]];
    //save the newly created history item
    if (![[[VariableStore sharedInstance] context] save:&error]) {
        // Handle the error.
    }
    history = nil;
}

-(void) composeSms {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.delegate = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *wpposts = [defaults objectForKey:@"posts"];
    NSString * videoUrl;
    NSString *videoName = [[VariableStore sharedInstance] videoName ];
    if([MFMessageComposeViewController canSendText])
	{
        for (NSDictionary *post in wpposts) {
            if ([[post objectForKey:@"post_title"] isEqualToString:videoName]) {
                videoUrl = [post objectForKey:@"link"];
            }
        }
        
        NSString *bodyText =[[NSString alloc] initWithFormat:@"\rPlease enjoy this video titled: %@\r%@",videoName,videoUrl];
		controller.body = bodyText;
		controller.recipients = [NSArray arrayWithObjects:[VariableStore sharedInstance].selectedContactPhone, nil];
		controller.messageComposeDelegate = self;
        //controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self presentViewController:controller animated:YES completion:^(void){}];
	}
}
//Check for group name
-(void) CheckIfGroupExistsWithName:(NSString*)groupName {
    
    
    BOOL hasGroup = NO;
    //checks to see if the group is created ad creats group for HiBye contacts
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
    
    //CFRelease(currentCheckedGroup);
    CFRelease(groupLists);
    CFRelease(addressBook);
}

-(void) createNewGroup:(NSString*)groupName {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef newGroup = ABGroupCreate();
    ABRecordSetValue(newGroup, kABGroupNameProperty,(__bridge CFTypeRef)(groupName), nil);
    ABAddressBookAddRecord(addressBook, newGroup, nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(addressBook);
    
    //!!! important - save groupID for later use
    _groupId = ABRecordGetRecordID(newGroup);
    CFRelease(newGroup);
}

//method for the alert with input box
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Save"])
    {
        [VariableStore sharedInstance].selectedContactName = [alertView textFieldAtIndex:0].text;
        //_contactPhone = [alertView textFieldAtIndex:1].text;
        [self composeSms];
    }
    else if ([title isEqualToString:@"Don't Save"])
        [self composeSms];
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
