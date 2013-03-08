//
//  Zion_AmericaAppDelegate.h
//  Zion America
//
//  Created by Patrick Asare on 12/25/12.
//  Copyright (c) 2012 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "VariableStore.h"

@interface Zion_AmericaAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@property (strong, nonatomic) UIWindow *window;

@end
