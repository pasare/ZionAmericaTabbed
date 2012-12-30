//
//  VariableStore.m
//  Zion America
//
//  Created by Patrick Asare on 12/27/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import "VariableStore.h"

@implementation VariableStore
+ (VariableStore *)sharedInstance
{
    // the instance of this class is stored here
    static VariableStore *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        // initialize variables here
        //myInstance.loginID
    }
    // return the instance of this class
    return myInstance;
}

- (NSString*) loginID {
    return _loginID;
}

- (NSString*) loginPass {
    return _loginPass;
}

-(NSString*) videoName {
    return _videoName;
}
@end
