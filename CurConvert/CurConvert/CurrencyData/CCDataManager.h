//
//  CCDataManager.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyRates;
@class CCRatesObject;

/*
 * Singleton Core Data Manager used for handling access to database
 */
@interface CCDataManager : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, nullable) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong, nullable) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*
 * Returns the shared instance of the data manager
 */
+ (nullable CCDataManager *)sharedDataManager;

/* 
 * Resets the persistent store coordinator, MOM, and MOC
 */
+ (void)cleanDataManager;

/*
 * Prints all records stored in the db to the console log
 * NOTE: this is only available for debug builds
 */
- (void)dumpAllManagedObjects;

/*
 * Retrieves all currency rate records stored on the device
 * Returns an array of CD CurrencyRate objects
 */
- (nullable NSArray<CurrencyRates *> *)getAllCurrencyRates;

/*
 * Deletes all currency rate records stored on the device
 */
- (void)deleteAllCurrencyRates;

/*
 * Saves the exchange rate data for a currency type
 * Param:   currencyRateObject    The object containing the exchange rates for a currency type
 * Return:  A new CD CurrencyRate object if save was successful, nil otherwise
 */
- (nullable CurrencyRates *)saveNewCurrencyRates:(nonnull CCRatesObject *)currencyRateObject;

/*
 * Saves the exchange rate data for an currency type creates a new CD record if one does not exist for the given currency
 * Param:   currencyRateObject    The object containing the exchange rates for a currency type
 * Return:  The updated CD CurrencyRate object if save was successful, nil otherwise
 */
- (nullable CurrencyRates *)updateCurrencyRates:(nonnull CCRatesObject *)currencyRateObject;

/*
 * Deletes the exchange rate record for the given currency type
 * Param:   currencyRateObject    The object containing the exchange rates for a currency type
 */
- (void)deleteCurrencyRates:(nonnull CCRatesObject *)currencyRateObject;

@end
