//
//  WordPressConnection.h
//  Zion America
//
//  Created by Patrick Asare on 12/26/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCConnection.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnectionManager.h"
#import "XMLRPCResponse.h"
#import "Constants.h"

@interface WordPressConnection : NSObject
- (IBAction)actionGetBlogPost:(id) sender username:(NSString *)username password:(NSString *)password;

- (BOOL)authenticateUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
- (NSMutableDictionary *)getPost:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
- (NSMutableArray *)getBlogsForUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
-(NSMutableDictionary *)getPosts:(NSString *)xmlrpcServer username:(NSString *)username password:(NSString *)password;
-(NSMutableDictionary *)getUsers:(NSString *)xmlrpcServer username:(NSString *)username password:(NSString *)password;
-(NSMutableArray *)getMediaLibrary:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
// ADDED BY PHIL BROWNING ------------------------------------------------------
- (NSMutableDictionary *)getEmailCredentials:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password;
// END -------------------------------------------------------------------------

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req;
@end
