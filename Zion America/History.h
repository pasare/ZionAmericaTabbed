//
//  History.h
//  Zion America
//
//  Created by Patrick Asare on 2/25/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface History : NSManagedObject
@property (nonatomic, retain) NSString * recipient;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) NSDate * date;
@end
