//
//  Contact.h
//  Zion America
//
//  Created by Patrick Asare on 2/17/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;

-(bool) duplicateContact:(Contact *)contact;

@end
