//
//  CCDataManager.m
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "CCDataManager.h"
#import "CCRatesObject.h"
#import "CurrencyRates.h"

#define     CURCONVERT_SQLITE_DATABASE_NAME                 @"CurConvert.sqlite"
#define     CURCONVERT_DATA_MODEL_NAME                      @"CurConvert"

#define     kCDCurrencyRates                                @"CurrencyRates"

@interface CCDataManager ()

@property (nonatomic, weak) NSThread *coreDataThread;

- (BOOL)saveChanges:(NSError **)error;
- (NSArray *)fetchData:(NSFetchRequest *)fetchRequest withError:(NSError **)error;

+ (NSString *)databasePath;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation CCDataManager {
    NSRecursiveLock *_saveLock;
}

static CCDataManager *_sharedDataManager;
static NSPersistentStoreCoordinator *__persistentStoreCoordinator;
static NSManagedObjectModel *__managedObjectModel;

+ (nullable CCDataManager *)sharedDataManager {
    @synchronized([CCDataManager class]) {
        
        // Initialize the shared object if it does not already exist
        if(!_sharedDataManager) {
            NSLog(@"Creating Data Manager");
            _sharedDataManager  = [[CCDataManager alloc] init];
        }
        
        NSLog(@"Returning shared Data Manager");
        return _sharedDataManager;
    }
    
    return nil;
}

- (id)init {
    if(self = [super init]) {
        // Initalize lock
        _saveLock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

+ (void)cleanDataManager {
    // Clear the persistent store and model
    if(__persistentStoreCoordinator) {
        __persistentStoreCoordinator = nil;
    }
    if(__managedObjectModel) {
        __managedObjectModel = nil;
    }
    
    // Then clear the MOC
    [[self sharedDataManager]cleanDataManager];
}

- (void)cleanDataManager {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_managedObjectContext) {
        self.managedObjectContext = nil;
    }
}

- (void)dealloc {
    // Clean MOC
    [self cleanDataManager];
}

#pragma mark -
#pragma mark Core Data stack

- (BOOL)saveChanges:(NSError **)error {
    [_saveLock lock];

    BOOL returnStatus;
    
    // Try to save the the MOC. Print errors to log
    @try {
        returnStatus     = [self.managedObjectContext save:error];
        if(!returnStatus && error) {
            NSLog(@"error in save %@", *error);
        }
    } @catch (NSException *e) {
        // The save action failed
        NSLog(@"Failed To SaveChanges -> %@", [e reason]);
    } @finally {
        [_saveLock unlock];
        
        return returnStatus;
    }
}

- (NSArray *)fetchData:(NSFetchRequest *)fetchRequest withError:(NSError **)error {
    [_saveLock lock];

    NSArray *result = nil;
    
    // Try to fetch from the MOC
    @try {
        result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:error];
    } @catch (NSException *e) {
        // The fetch failed
        NSLog(@"Failed To Fetch Data %@", [e reason]);
    } @finally {
        [_saveLock unlock];
        return result;
    }
}

+ (NSString *)databasePath {
    // Get the database path from the documents directory
    NSArray *paths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath  = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *dbPath = [basePath stringByAppendingPathComponent:CURCONVERT_SQLITE_DATABASE_NAME];
    
    return dbPath;
}

+ (NSManagedObjectModel *)managedObjectModel {
    
    // If the model does not exist, create it from the bundle
    if(__managedObjectModel == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:CURCONVERT_DATA_MODEL_NAME ofType:@"momd"];
        
        NSURL *momURL = [NSURL fileURLWithPath:path isDirectory:YES];
        __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return [CCDataManager persistentStoreCoordinator];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized(self) {
        
        // Create a new persistent store coordinator if it does not exist
        if(__persistentStoreCoordinator == nil) {
            NSLog(@"Creating local persistent store.");
            
            NSURL *storeUrl = [NSURL fileURLWithPath:[CCDataManager databasePath]];
            
            NSLog(@"Store URL is: %@", storeUrl);
            NSError *error;
            
            NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                               [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            
            NSManagedObjectModel *model = [CCDataManager managedObjectModel];
            
            __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
            
            // Add the store to the coordinator
            if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:storeUrl
                                                                 options:optionsDictionary
                                                                   error:&error]) {
                // Handle error if it fails to be added to the coordinator
                if(error && [error localizedDescription]) {
                    NSLog(@"Error getting persistentStoreCoordinator - %@  %@", [error localizedDescription], [error userInfo]);
                }
            }
        }
        
        return __persistentStoreCoordinator;
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    @synchronized([CCDataManager class]) {
        
        // If the context does not already exist
        if(_managedObjectContext == nil) {
            
            // Set up new MOC by adding observers and setting thread
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleMerge:) name:NSManagedObjectContextDidSaveNotification object:nil];
            self.coreDataThread = [NSThread currentThread];
            NSLog(@"coreDataThread %@", self.coreDataThread);
            
            // Get the coordinator
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if(coordinator != nil) {
                // Bind the MOC to the persistant store
                self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                self.managedObjectContext.persistentStoreCoordinator = coordinator;
                NSLog(@"created MOC %@", self.managedObjectContext);
            }
        }
        
        return _managedObjectContext;
    }
    
    return nil;
}

- (void)handleMerge:(NSNotification *)mergeNotification {
    if(_managedObjectContext != nil) {
        if(_managedObjectContext != mergeNotification.object) {
            // Merge everythhing on the CoreData thread
            [self performSelector:@selector(doMerge:) onThread:self.coreDataThread withObject:mergeNotification waitUntilDone:NO];
        } else {
            NSLog(@"MOCs are equal");
        }
    }
}

- (void)doMerge:(NSNotification *)mergeNotification {
    if([[(NSManagedObjectContext *)[mergeNotification object] persistentStoreCoordinator] isEqual:self.managedObjectContext.persistentStoreCoordinator]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:mergeNotification];
    }
}

- (void)dumpAllManagedObjects {
    // As a general rule we should never dump a db in a release version
#ifdef DEBUG
    
    // Get all records
    NSArray *results = [self getAllCurrencyRates];
    
    // If we've got records
    if(results && [results count] > 0) {
        // Print them all to the console
        NSLog(@"%@", results);
    } else {
        NSLog(@"CD error dumping records.");
    }
#endif
}

#pragma mark - Data Model Objects

- (nullable NSArray *)getAllCurrencyRates {
    // Construct a fetch request to get all records
    NSError *error  = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCDCurrencyRates inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Fetch all records
    NSArray *results = [self fetchData:fetchRequest withError:&error];
    
    // Handle errors if we encounter any
    if(error) {
        NSLog(@"cd error: %@, %@", error, [error userInfo]);
        
        NSDictionary *mocExceptionDict = [NSDictionary dictionaryWithObject:error forKey:@"CurConvertExceptionError"];
        NSException *mocException = [NSException exceptionWithName:NSLocalizedString(@"CurConvertException", @"")
                                                            reason:NSLocalizedString(@"CurConvertExceptionReason", @"")
                                                          userInfo:mocExceptionDict];
        @throw mocException;
    }
    
    // Check results
    if(results && [results count] > 0) {
        NSLog(@"CD retrieved %ld records", [results count]);
        return results;
    } else {
        NSLog(@"CD retrieved no records.");
        return nil;
    }
}

- (void)deleteAllCurrencyRates {
    NSError *error  = nil;
    
    // Get all records
    NSArray *results = [self getAllCurrencyRates];
    
    // If we've got records
    if(results && [results count] > 0) {
        NSLog(@"Retrieved all records for deletion");
        
        // Loop through and delete all of them
        for (CurrencyRates *cdCurrencyRates in results) {
            [self.managedObjectContext deleteObject:cdCurrencyRates];
            
            if(![self saveChanges:&error]) {
                NSLog(@"CD error saving changes: %@", error);
            }
        }
    }
}

- (CurrencyRates *)saveNewCurrencyRates:(CCRatesObject *)currencyRateObject {
    NSError *error = nil;
    BOOL wasSaveSuccess = NO;
    
    // Create new cd entity to add to DB
    CurrencyRates *cdCurrencyRates = [NSEntityDescription insertNewObjectForEntityForName:kCDCurrencyRates
                                                          inManagedObjectContext:self.managedObjectContext];
    
    // Set properties
    cdCurrencyRates.baseName = currencyRateObject.baseCurrencyName;
    cdCurrencyRates.rateData = currencyRateObject.exchangeRates;
    cdCurrencyRates.timestamp = currencyRateObject.timestamp;
    
    // Try to save to MOC
    @try {
        wasSaveSuccess = [self saveChanges:&error];
    } @catch (NSException *e) {
        NSLog(@"Save error: %@, %@", e, [e reason]);
    } @finally {
        // Return the CD object if we were successful
        if(wasSaveSuccess) {
            NSLog(@"Finished saving object.");
            return cdCurrencyRates;
        } else {
#ifdef DEBUG
            // Print out the full error for debug
            if(error && [error localizedDescription]) {
                NSLog(@"could not save episode because %@", [error localizedDescription]);
            }
#endif
            return nil;
        }
    }
}

- (CurrencyRates *)updateCurrencyRates:(nonnull CCRatesObject *)currencyRateObject {
    NSError *error = nil;
    BOOL wasSaveSuccess = NO;
    
    // Grab the existing CD object to update
    CurrencyRates *cdCurrencyRates = currencyRateObject.cdCurrencyRates;
    
    // If we somehow do not have a CD object yet, this has not been saved yet, so we must insert instead of updating
    if (cdCurrencyRates == nil) {
        cdCurrencyRates = [self saveNewCurrencyRates:currencyRateObject];
        return cdCurrencyRates;
    } else {
        // Otherwise, just update the properties and save it
        cdCurrencyRates.baseName = currencyRateObject.baseCurrencyName;
        cdCurrencyRates.rateData = currencyRateObject.exchangeRates;
        cdCurrencyRates.timestamp = currencyRateObject.timestamp;
        
        // Try to save to MOC
        @try {
            wasSaveSuccess = [self saveChanges:&error];
        } @catch (NSException *e) {
            NSLog(@"Update error: %@, %@", e, [e reason]);
        } @finally {
            // Return the CD object if we were successful
            if(wasSaveSuccess) {
                NSLog(@"Finished updating object.");
                return cdCurrencyRates;
            } else {
    #ifdef DEBUG
                // Print out the full error for debug
                if(error && [error localizedDescription]) {
                    NSLog(@"could not save episode because %@", [error localizedDescription]);
                }
    #endif
                return nil;
            }
        }
    }
}

- (void)deleteCurrencyRates:(nonnull CCRatesObject *)currencyRateObject {
    
    // Grab the existing CD object to update
    CurrencyRates *cdCurrencyRates = currencyRateObject.cdCurrencyRates;
    
    // If we somehow do not have a CD object yet, this has not been saved yet, so we must insert instead of updating
    if (cdCurrencyRates != nil) {
        // Try to delete from the  MOC
        @try {
            [self.managedObjectContext deleteObject:cdCurrencyRates];
        } @catch (NSException *e) {
            NSLog(@"Delete error: %@, %@", e, [e reason]);
        } @finally {
            NSLog(@"Finished deleting object.");
        }
    }
}

@end
