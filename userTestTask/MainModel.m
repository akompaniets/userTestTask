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
#import "Company.h"

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
        
        CGFloat appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
        if (appVersion == 2.0 && !isSynchronizedDB && !isFirstRun)
        {
            [self synchronizeDataBase];
        }
        
        if (!self.networkManager && !self.coreDataManager) {
            self.networkManager = [NetworkManager new];
            self.coreDataManager = [CoreDataManager sharedManager];
        }
        
        [self.networkManager fetchUserDataWithCompletion:^(NSArray *array, NSError *error) {
            
            NSSet *filteredSet;
           
            if (!isFirstRun)
            {
                self.userIDs = [self fetchAllUsersID];
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject isEqualToNumber:[NSNumber numberWithInteger:DefaultUserID]])
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
    if (isFirstRun)
    {
        NSMutableSet *temp = [[NSMutableSet alloc] init];
        for (NSDictionary *dict in data)
        {
            [temp addObject:[dict objectForKey:@"company"]];
        }
        [self handleCompaniesList:[temp copy]];
    }
    
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
    if (isFirstRun)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRun];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) handleCompaniesList:(NSSet *)data
{
//    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    moc.parentContext = [CoreDataManager sharedManager].mainContext;
    
    for (NSDictionary *dict in data) {
        Company *company = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:self.moc];
        
        company.name = [dict objectForKey:@"name"];
        company.bs = [dict objectForKey:@"bs"];
        company.catchPhrase = [dict objectForKey:@"catchPhrase"];
    }
    
    [self.moc performBlockAndWait:^{
        NSError *error;
        [self.moc save:&error];
        if (error)
        {
#if DEBUG
            NSLog(@"Saving error - %@", [error userInfo]);
#endif
        }
    }];
    
    [[CoreDataManager sharedManager] saveContext];

    
}

- (void) handleUserDictionary:(NSDictionary *)dict
{
    UserData *user = [NSEntityDescription insertNewObjectForEntityForName:@"UserData"
                                                   inManagedObjectContext:self.moc];

    NSString *companyName = [dict valueForKeyPath:@"company.name"];
    Company *company = [self fetchCompanyByName:companyName];
    
    user.name = [dict objectForKey:@"name"];
    user.phone = [dict objectForKey:@"phone"];
    user.userName = [dict objectForKey:@"username"];
    user.userID = [NSNumber numberWithInteger:[[dict valueForKey:@"id"] integerValue]];
    user.lat = [NSNumber numberWithFloat:[[dict valueForKeyPath:@"address.geo.lat"] floatValue]];
    user.lng = [NSNumber numberWithFloat:[[dict valueForKeyPath:@"address.geo.lng"] floatValue]];
    user.company = company;
}

- (void) fetchAllCompaniesWithCompletitionBlock:(void (^)(NSArray *))block
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        moc.parentContext = [CoreDataManager sharedManager].mainContext;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];
        [request setEntity:description];
        [request setResultType:NSDictionaryResultType];
        [request setPropertiesToFetch:@[@"name"]];
        
        NSError *error = nil;
        NSArray *fetchedArray = [moc executeFetchRequest:request error:&error];
        NSMutableArray *temporary = [NSMutableArray array];
        for (NSDictionary *dict in fetchedArray) {
            [temporary addObject:[dict objectForKey:@"name"]];
        }
        if (error) {
#ifdef DEBUG
            NSLog(@"Erro fetching: %@", [error userInfo]);
#endif
        }
        else if (block)
        {
            block([temporary copy]);
        }
    });
}

- (NSSet *) fetchAllUsersID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID != %d", DefaultUserID];
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

#pragma mark - User Managing

- (BOOL)createNewUserWithDictionary:(NSDictionary *)user
{
    __block BOOL result;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
//        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        moc.parentContext = [[CoreDataManager sharedManager] mainContext];
        
        NSManagedObjectContext *moc = self.moc;
        
        NSString *comapnyName = [user objectForKey:@"company"];
        
        Company *currentCompany = [self fetchCompanyByName:comapnyName];
        
        UserData *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:moc];
        newUser.name = [user objectForKey:@"name"];
        newUser.userName = [user objectForKey:@"userName"];
        newUser.phone = [user objectForKey:@"phone"];
        newUser.lat = [user objectForKey:@"lat"];
        newUser.lng = [user objectForKey:@"lng"];
        newUser.company = currentCompany;
        newUser.userID = [NSNumber numberWithInteger:DefaultUserID];

        [moc performBlockAndWait:^{
            NSError *error;
            [moc save:&error];
            if (error)
            {
#if DEBUG
                NSLog(@"Saving error - %@", [error userInfo]);
#endif
            }
        }];
        
        if ([[CoreDataManager sharedManager].mainContext hasChanges])
        {
            result = [[CoreDataManager sharedManager] saveContext] ? YES : NO;
            
        }
    });
    
    return result;

}

- (Company *) fetchCompanyByName:(NSString *)name
{
//    NSManagedObjectContext *moc = [[CoreDataManager sharedManager] mainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [request setEntity:description];
    [request setResultType:NSManagedObjectResultType];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *obj = [self.moc executeFetchRequest:request error:&error];
    Company *currentCompany;
    if (!error)
    {
        currentCompany = (Company *)obj[0];
    }
    
    return currentCompany;
}

- (BOOL)commitChangesForUser:(UserData *)user
{
    BOOL result;
    if ([[CoreDataManager sharedManager].mainContext hasChanges])
    {
       result = [[CoreDataManager sharedManager] saveContext];
    }
    
    return result;
}

- (BOOL)deleteUser:(UserData *)user
{
    [[CoreDataManager sharedManager].mainContext deleteObject:user];

    return [[CoreDataManager sharedManager] saveContext];
}


#pragma mark - CoreData Synchronization

- (void) synchronizeDataBase
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        moc.parentContext = [CoreDataManager sharedManager].mainContext;
        
        NSFetchRequest *companyRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:moc];
        [companyRequest setEntity:description];
        
        NSError *error = nil;
        NSArray *companies = [moc executeFetchRequest:companyRequest error:&error];
        
        NSFetchRequest *userRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:moc];
        [userRequest setEntity:desc];
        
        NSArray *allUsers = [moc executeFetchRequest:userRequest error:nil];
        
        for (Company *comp in companies)
        {
            for (UserData *user in allUsers)
            {
                if ([comp.name isEqualToString:user.companyName])
                {
                    [comp addUsersObject:user];
                }
            }
        }
        
        [moc performBlockAndWait:^{
            NSError *error = nil;
            [moc save:&error];
        }];
        
        if ([[CoreDataManager sharedManager] saveContext])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSyncDB];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

@end
