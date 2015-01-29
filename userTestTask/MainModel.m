//
//  MainModel.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "MainModel.h"
#import "NetworkManager.h"
#import "CoreDataManager.h"
#import "UserData.h"

@interface MainModel()

@property(strong, nonatomic) NetworkManager *networkManager;
@property(strong, nonatomic) CoreDataManager *coreDataManager;
@property(strong, nonatomic) NSManagedObjectContext *moc;
@property(strong, nonatomic) NSSet *userIDs;

@end

@implementation MainModel


#pragma mark -

- (NSManagedObjectContext *)moc
{
    if (!_moc)
    {
    _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _moc.parentContext = self.coreDataManager.mainContext;
    }
    return _moc;
}

- (void)fetchUsersWithCompletion:(void(^)(BOOL success))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if (!self.networkManager && !self.coreDataManager) {
            self.networkManager = [NetworkManager new];
            self.coreDataManager = [CoreDataManager sharedManager];
        }
        
        if (isFirstRun)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRun];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self.networkManager fetchUserDataWithCompletion:^(NSArray *array, NSError *error) {
            
            NSSet *filteredSet;
           
            if (!isFirstRun)
            {
                self.userIDs = [self fetchAllUsersID];
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject isEqualToNumber:[NSNumber numberWithInteger:0]])
                    {
                        return NO;
                    }
                    else
                    {
                        return YES;
                    }
                }];
                filteredSet = [self.userIDs filteredSetUsingPredicate:predicate];
            }
            
            if (array)
            {
                if ([array count] != [filteredSet count])
                {
                    [self handleFetchedData:array];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(YES);
                });
            }
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(NO);
                });
            }
        }];
    });
}

- (void)handleFetchedData:(NSArray *)data
{
    NSInteger usersCount = [self.userIDs count];
        
    if (!usersCount) {
        for (NSDictionary *dict in data)
        {
            [self handleUserDictionary:dict];
        }
    }
    else
    {
        for (NSDictionary *dict in data)
        {
            if (![self.userIDs containsObject:[dict objectForKey:@"id"]])
            {
                [self handleUserDictionary:dict];
            }
        }
    }
    
    if ([self.moc hasChanges])
    {
        [self.moc performBlockAndWait:^{
            NSError *error = nil;
            if (![self.moc save:&error])
            {
                NSLog(@"Error saving context -- %@", [error userInfo]);
            }
        }];
        [[CoreDataManager sharedManager] saveContext];
    }
}

- (void) handleUserDictionary:(NSDictionary *)dict
{
    UserData *user = [NSEntityDescription insertNewObjectForEntityForName:@"UserData"
                                                   inManagedObjectContext:self.moc];
    user.name = [dict objectForKey:@"name"];
    user.phone = [dict objectForKey:@"phone"];
    user.userName = [dict objectForKey:@"username"];
    user.userID = [NSNumber numberWithInteger:[[dict valueForKey:@"id"] integerValue]];
    user.lat = [NSNumber numberWithFloat:[[dict valueForKeyPath:@"address.geo.lat"] floatValue]];
    user.lng = [NSNumber numberWithFloat:[[dict valueForKeyPath:@"address.geo.lng"] floatValue]];
}

- (NSSet *) fetchAllUsersID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID != 0"];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:self.moc];
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"userID"]];
    
    NSError *error = nil;
    NSArray *fetchedArray = [self.moc executeFetchRequest:request error:&error];
    
    NSMutableSet *temp = [[NSMutableSet alloc] init];
    for (NSDictionary *currentUser in fetchedArray)
    {
        [temp addObject:[currentUser objectForKey:@"userID"]];
    }
    
    if (error) {
#ifdef DEBUG
        NSLog(@"Erro fetching: %@", [error userInfo]);
#endif
    }
    return [temp copy];
}


@end
