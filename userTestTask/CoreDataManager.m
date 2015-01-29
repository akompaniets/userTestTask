//
//  CoreDataManager.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager()

@property (strong, nonatomic) NSManagedObjectContext *writerContext;

@end

@implementation CoreDataManager

#pragma mark - Core Data stack

@synthesize mainContext = _mainContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (CoreDataManager *)sharedManager
{
    static CoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    
    return manager;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"userTestTask" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"userTestTask.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
#if DEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainContext
{
        if (_mainContext != nil)
        {
            return _mainContext;
        }
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.writerContext;
    
        return _mainContext;
}

- (NSManagedObjectContext *)writerContext
{
    if (!_writerContext)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (!coordinator)
        {
            return nil;
        }
        _writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_writerContext setPersistentStoreCoordinator:coordinator];
    }
    return _writerContext;
}

#pragma mark - Core Data Saving support

- (BOOL)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.mainContext;
    if (managedObjectContext != nil)
    {
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if ([managedObjectContext save:&error])
            {
#if DEBUG
                NSLog(@"Main Context Saved!");
#endif
            }
        }];
    }
    __block NSError *error = nil;
    [self.writerContext performBlockAndWait:^{
        
        if ([self.writerContext save:&error])
        {
#if DEBUG
            NSLog(@"Writer Context Saved!");
#endif
        };
    }];
    return !error ? YES : NO;
}

@end
