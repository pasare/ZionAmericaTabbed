//
//  WordPressConnection.m
//  Zion America
//
//  Created by Patrick Asare on 12/26/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "WordPressConnection.h"
@interface WordPressConnection ()
@property (nonatomic,retain)  NSError *error;
@end

@implementation WordPressConnection
@synthesize error;
#pragma XMLRPC Methods

//XMLRPC call to see if the credentials work properly

- (IBAction)actionGetBlogPost:(id) sender username:(NSString *)username password:(NSString *)password{
    
    //XMLRPC call to retreive a single post and push the content to a UIWebView
    //NSString *server = WPSERVER;
    //NSMutableDictionary *returnedPost = [self getPost:server username:username password:password];
    
    //NSString *postDescription = [returnedPost objectForKey:@"description"];
    //NSLog(@"Post Description: %@", postDescription);
    
    
}

//This method is used by our action above to call the getBlogsForUser to verify the user credentials
- (BOOL)authenticateUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
	BOOL result = NO;
    if((xmlrpc != nil) && (username != nil) && (password != nil)) {
		if([self getBlogsForUser:xmlrpc username:username password:password] != nil)
			result = YES;
	}
	return result;
}

- (NSMutableDictionary *)getPost:(NSString *)xmlrpcServer username:(NSString *)username password:(NSString *)password {
    
    NSMutableDictionary *finalData = [[NSMutableDictionary alloc] init];
    NSString *server = WPSERVER;
    
	@try {
        NSMutableArray *args = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], username, password, nil];
        NSString *method = @"wp.getPost";
        XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:server]];
        [request setMethod:method withParameters:args];
        
        NSMutableDictionary *returnedData = [self executeXMLRPCRequest:request];
        
        
		if([returnedData isKindOfClass:[NSArray class]]) {
            finalData = [NSArray arrayWithObjects:returnedData, nil];
		}
        else if([returnedData isKindOfClass:[NSDictionary class]]) {
            finalData = returnedData;
		}
		else if([returnedData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)returnedData;
			NSString *errorMessage = [self.error localizedDescription];
            
			finalData = nil;
            
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
			else if([errorMessage isEqualToString:@"Bad login/pass combination."])
                errorMessage = nil;
		}
		else {
			finalData = nil;
			NSLog(@"method failed: %@", returnedData);
		}
	}
	@catch (NSException * e) {
		finalData = nil;
		NSLog(@"method failed: %@", e);
	}
    
	return finalData;
}

-(NSMutableDictionary *)getPosts:(NSString *)xmlrpcServer username:(NSString *)username password:(NSString *)password {
    
    NSMutableDictionary *finalData = [[NSMutableDictionary alloc] init];
    NSString *server = WPSERVER;
    
	@try {
        NSDictionary *filter =[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1000",@"desc",@"post_name",nil] forKeys:[NSArray arrayWithObjects:@"number",@"order",@"orderby",nil]];
        //NSLog(@"filter: %@", filter);
        
        NSMutableArray *args = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], username, password,filter,nil];
        NSString *method = @"wp.getPosts";
        XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:server]];
        [request setMethod:method withParameters:args];
        
        NSMutableDictionary *returnedData = [self executeXMLRPCRequest:request];
        
		if([returnedData isKindOfClass:[NSArray class]]) {
            finalData = returnedData;//[NSArray arrayWithObjects:returnedData, nil];
        
		}
        else if([returnedData isKindOfClass:[NSDictionary class]]) {
            finalData = returnedData;
		}
		else if([returnedData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)returnedData;
			NSString *errorMessage = [self.error localizedDescription];
            
			finalData = nil;
            
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
			else if([errorMessage isEqualToString:@"Bad login/pass combination."])
                errorMessage = nil;
            }
            else {
                finalData = nil;
                NSLog(@"method failed: %@", returnedData);
		}
	}
	@catch (NSException * e) {
		finalData = nil;
		NSLog(@"method failed: %@", e);
	}
    
	return finalData;
}

- (NSMutableArray *)getBlogsForUser:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
    
    NSMutableArray *usersBlogs = [[NSMutableArray alloc] init];
    
	@try {
		XMLRPCRequest *xmlrpcUsersBlogs = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:xmlrpc]];
		[xmlrpcUsersBlogs setMethod:@"wp.getUsersBlogs" withParameters:[NSArray arrayWithObjects:username, password, nil]];
        
		NSArray *usersBlogsData = [self executeXMLRPCRequest:xmlrpcUsersBlogs];
        //[xmlrpcUsersBlogs release];
        
		if([usersBlogsData isKindOfClass:[NSArray class]]) {
            //[usersBlogs release];
            usersBlogs = [NSArray arrayWithArray:usersBlogsData];
		}
		else if([usersBlogsData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)usersBlogsData;
			NSString *errorMessage = [self.error localizedDescription];
            
			usersBlogs = nil;
            
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            
		}
		else {
			usersBlogs = nil;
			NSLog(@"getBlogsForUrl failed: %@", usersBlogsData);
		}
	}
	@catch (NSException * e) {
		usersBlogs = nil;
		NSLog(@"getBlogsForUrl failed: %@", e);
	}
    
	return usersBlogs;
}

-(NSArray *)getUsers:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
    
    NSArray *wpusers = [[NSArray alloc] init];
    
	@try {
		XMLRPCRequest *xmlrpcUsers = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:xmlrpc]];
		[xmlrpcUsers setMethod:@"wp.getUsers" withParameters:[NSArray arrayWithObjects:[NSNumber numberWithInt:1],username, password, nil]];
        
		NSArray *usersData = [self executeXMLRPCRequest:xmlrpcUsers];
        
		if([usersData isKindOfClass:[NSArray class]]) {
            wpusers = [NSArray arrayWithArray:usersData];
		}
		else if([usersData isKindOfClass:[NSError class]]) {
			self.error = (NSError *)usersData;
			NSString *errorMessage = [self.error localizedDescription];
            
			wpusers = nil;
            
			if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"])
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            
		}
		else {
			wpusers = nil;
			NSLog(@"getUsers failed: %@", usersData);
		}
	}
	@catch (NSException * e) {
		wpusers = nil;
		NSLog(@"getUsers failed: %@", e);
	}
    
	return wpusers;
}

// ADDED BY PHIL BROWNING ------------------------------------------------------
- (NSMutableDictionary *)getEmailCredentials:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
    
    // The array will consist of 4 elements.
    NSMutableDictionary *wpEmailCredentials = [[NSMutableDictionary alloc] init];
    @try {
        XMLRPCRequest *xmlrpcEmailCredentials = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:xmlrpc]];
        [xmlrpcEmailCredentials setMethod:@"myZion.emailCredentials" withParameters:[NSArray arrayWithObjects:username,password, nil]];
        wpEmailCredentials = [self executeXMLRPCRequest:xmlrpcEmailCredentials];
        
        if ([wpEmailCredentials isKindOfClass:[NSDictionary class]]) {
            wpEmailCredentials = [NSMutableDictionary dictionaryWithDictionary:wpEmailCredentials];
        }
        else if ([wpEmailCredentials isKindOfClass:[NSError class]]) {
            self.error = (NSError *)wpEmailCredentials;
            NSString *errorMessage = [self.error localizedDescription];
            wpEmailCredentials = nil;
            
            if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"]) {
				errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            }
        } else {
            wpEmailCredentials = nil;
            NSLog(@"getEmailCredentials failed: No Data\n");
        }
    }
    @catch (NSException *exception) {
        wpEmailCredentials = nil;
        NSLog(@"getEmailCredentials failed %@", exception);
    }
    
    return wpEmailCredentials;
}

- (NSMutableArray *)getMediaLibrary:(NSString *)xmlrpc username:(NSString *)username password:(NSString *)password {
    
    /* Returns the full array of media items on the website:
     *
     * media Item {
     *     int post_parent
     *     string post_title
            string guid
     * }
     */
    NSMutableArray *wpMediaLibrary = [[NSMutableArray alloc] init];
    @try {
        XMLRPCRequest *xmlrpcMediaLibrary = [[XMLRPCRequest alloc] initWithURL:[NSURL URLWithString:xmlrpc]];
        [xmlrpcMediaLibrary setMethod:@"myZion.videoLinks" withParameters:[NSArray arrayWithObjects:username, password, nil]];
        wpMediaLibrary = [self executeXMLRPCRequest:xmlrpcMediaLibrary];
        if ([wpMediaLibrary isKindOfClass:[NSArray class]]) {
            wpMediaLibrary = [NSMutableArray arrayWithArray:wpMediaLibrary];
        }
        else if ([wpMediaLibrary isKindOfClass:[NSError class]]) {
            self.error = (NSError *)wpMediaLibrary;
            NSString *errorMessage = [self.error localizedDescription];
            wpMediaLibrary = nil;
    
            if([errorMessage isEqualToString:@"The operation couldn’t be completed. (NSXMLParserErrorDomain error 4.)"]) {
                errorMessage = @"Your blog's XML-RPC endpoint was found but it isn't communicating properly. Try disabling plugins or contacting your host.";
            }
        } else {
            wpMediaLibrary = nil;
            NSLog(@"wpMediaLibrary failed: No Data\n");
        }
    }
    @catch (NSException *exception) {
        wpMediaLibrary = nil;
        NSLog(@"getMediaLibrary failed %@", exception);
    }
    
    return wpMediaLibrary;
}
// END -------------------------------------------------------------------------

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req {
    NSError *error2 = nil;
	XMLRPCResponse *userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req error:&error2];
	return [userInfoResponse object];
}
@end
