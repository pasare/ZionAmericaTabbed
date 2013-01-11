//
//  VariableStore.h
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface VariableStore : NSObject
@property (nonatomic) NSString *loginID;
@property (nonatomic) NSString *loginPass;
@property (nonatomic) NSString *videoName;
@property (nonatomic) CTCoreMessage *selectedEmail;
@property (nonatomic) NSDictionary *selectedContact;
+ (VariableStore *)sharedInstance;
- (NSString*) loginID;
- (NSString*) loginPass;
- (NSString*) videoName;
- (CTCoreMessage*) selectedEmail;
- (NSDictionary*) selectedContact;
@end
