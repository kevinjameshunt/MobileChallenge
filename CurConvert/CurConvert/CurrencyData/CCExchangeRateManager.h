//
//  CCExchangeRateManager.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCRatesObject;

/*
 * Callback method for  single request for exchange rate data of a currency
 * Param: rateObject    CCRatesObject representing the data retrieved from the request, nil if an error has been encountered
 * Param: error         NSError object containing details about the error, nil if retrieval and parsing was successful
 */
typedef void(^CCRateRetrievalRequestCompleted)(CCRatesObject * _Nullable rateObject, NSError * _Nullable error);

/*
 * Callback method for request to update all exchange rate data for each currency
 * Param: errorList     An array of NSError objects containing details about the error, nil if retrieval and parsing of all requests was successful
 */
typedef void(^CCAllRateRetrievalRequestCompleted)(NSArray<NSError *> * _Nullable errorList);

/*
 * Singleton used for handling retrieval, parsing, and storage of exchange rates
 * 
 */
@interface CCExchangeRateManager : NSObject

/*
 * Returns the shared instance of the CCExchangeRateManager
 */
+ (nullable CCExchangeRateManager *)sharedExchangeRateManager;

/*
 * Checks to see if the existing exchange rate data for the given currency is still valid
 * Return:  YES if data is still valid, NO if it must be refreshed from the server
 */
- (BOOL)isRateDataFreshForCurrency:(nonnull NSString *)currencyName;

/*
 * Loops through each currency type and attempts to update any exchange data that is out of date
 * Param: callback      A block that is called when all currency types have been checked/updated
 */
- (void)checkAndUpdateAllExchangeRatesWithcallback:(nullable CCAllRateRetrievalRequestCompleted)callback;

/*
 * Checks the given currency type to see if it needs to be updated. If it does, the data will be requested from the server. If not, the existing data stored on the device is passed to the callback
 * Param: currencyName  The name of the currency to retrieve the exchange rates for
 * Param: callback      A block that is called when the data is updated. It is called immediately if the data does not need to be refreshed
 */
- (void)retrieveRatesForCurrency:(nonnull NSString *)currencyName callback:(nullable CCRateRetrievalRequestCompleted)callback;

/*
 * Starts a timer that automatically tries to update any exchange rate data that needs to be refreshed
 */
- (void)startUpdateTimer;

/*
 * Stops the update timer
 */
- (void)stopUpdateTimer;

/*
 * Returns the exchange rate data stored on the device for a given currency type   
 */
- (nullable CCRatesObject *)ratesForCurrency:(nonnull NSString *)currencyName;

@end
