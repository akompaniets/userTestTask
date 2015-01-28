//
//  ViewController.m
//  userTestTask
//
//  Created by Andrey Kompaniets on 10.12.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "MainViewController.h"
#import "UserCell.h"
#import "UserData.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import <CoreData/CoreData.h>
#import "UserDetailViewController.h"
#import "MainModel.h"
#import "CoreDataManager.h"
#import <RKDropdownAlert/RKDropdownAlert.h>
#import <SVPullToRefresh/SVPullToRefresh.h>


@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) JGProgressHUD *hud;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation MainViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"user_list", nil);
    self.tableView.backgroundColor = [UIColor clearColor];
   
    __weak typeof(self) weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf fetchUsersData];
    }];
    
    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = NSLocalizedString(@"loading", nil);
    
    if (isFirstRun)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstRun];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self fetchUsersData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Fetching User Data

- (void)fetchUsersData
{
    MainModel *model = [[MainModel alloc] init];
   
        [self.hud showInView:self.view];
    
    [model fetchUsersWithCompletion:^(BOOL success) {
        if (success)
        {
            [self.hud dismissAnimated:YES];
            [self.tableView.pullToRefreshView stopAnimating];
        }
        else
        {
            [self.hud dismissAnimated:YES];
            [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                           message:NSLocalizedString(@"error_internet_connection", nil)
                   backgroundColor:[UIColor redColor]
                         textColor:[UIColor whiteColor]];
        }
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController sections][section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * const cellID = @"userCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UserCell *userCell = (UserCell *)cell;
    UserData *currentUser = [self.fetchedResultsController fetchedObjects][indexPath.row];
    userCell.name.text = currentUser.name;
    userCell.userName.text = currentUser.userName;
    userCell.userPhone.text = currentUser.phone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"userDetail"])
    {
        UserDetailViewController *detailVC = segue.destinationViewController;
        UserData *user = [self.fetchedResultsController fetchedObjects][[self.tableView indexPathForSelectedRow].row];
        detailVC.currentUser = user;
        
    }
}

#pragma mark - CoreData init

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        _managedObjectContext = [[CoreDataManager sharedManager] mainContext];
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:10];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userID"
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"Test"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Fetching error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}    


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
//    if ([[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]== 0)
//    {
//        [self fetchUsersData];
//    }
}

@end
