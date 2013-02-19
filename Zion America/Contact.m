//
//  Contact.m
//  Zion America
//
//  Created by Patrick Asare on 2/17/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic name;
@dynamic email;
@dynamic phone;

-(bool) duplicateContact:(Contact *)contact {
    if ([self.name localizedCaseInsensitiveCompare:contact.name] == NSOrderedSame ) {
        return YES;
    }
    return NO;
}

@end
