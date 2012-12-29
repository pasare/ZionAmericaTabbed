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
    NSString *server = WPSERVER;
    NSMutableDictionary *returnedPost = [self getPost:server username:username password:password];
    
    NSString *postDescription = [returnedPost objectForKey:@"description"];
    NSLog(@"Post Description: %@", postDescription);
    
    //[descWebView loadHTMLString:postDescription baseURL:nil];
    //descWebView.delegate = self;
    
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
        
        //[request release];
        
		if([returnedData isKindOfClass:[NSArray class]]) {
            //[finalData release];
            finalData = [NSArray arrayWithObjects:returnedData, nil];
		}
        else if([returnedData isKindOfClass:[NSDictionary class]]) {
            //[finalData release];
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

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req {
    NSError *error2 = nil;
	XMLRPCResponse *userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req error:&error2];
	return [userInfoResponse object];
}
@end
