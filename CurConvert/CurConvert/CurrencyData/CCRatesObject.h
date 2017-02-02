//
//  CCRatesObject.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CurrencyRates;


/*
 * Object used to represent the exchange rates relative to the base currency
 */
@interface CCRatesObject : NSObject

/*
 * The CoreData representation of the object
 */
@property (nonatomic, retain, nullable) CurrencyRates *cdCurrencyRates;

/*
 * The currency type that the exchange rates are relative to
 */
@property (nonatomic, readonly, nonnull) NSString *baseCurrencyName;

/*
 * The exchange rates for the base currency
 */
@property (nonatomic, readonly, nonnull) NSDictionary *exchangeRates;

/*
 * The timestamp representing the last time the exchange rates for this currency were updated
 */
@property (nonatomic, readonly, nonnull) NSDate *timestamp;

/*
 * Saves the exchange rate data for the given currency and returns a fully populated CCRatesObject
 * Param: baseCurrencyName  The name of the currency corresponding to the exchange rates
 * Param: rateData          The exchange rates for this currency
 * Return: An instance of CCRatesObject
 */
+ (instancetype _Nullable)saveRateObjectForCurrency:(NSString * _Nonnull)baseCurrencyName withExchangeRates:(NSDictionary * _Nonnull)rateData;

/*
 * Creates a fully populated CCRatesObject from data retrieved from the local device db
 * Param: cdRatesObj        The a Core Data object representing currency exchange rate that has already been saved on the device 
 * Return: An instance of CCRatesObject
 */
+ (instancetype _Nullable)rateObjectWithSavedData:(CurrencyRates * _Nonnull)cdRatesObj;

/*
 * Initializes a CCRatesObject
 * Note: This does not persist the data on the device
 * Param: baseCurrencyName  The name of the currency corresponding to the exchange rates
 * Param: rateData          The exchange rates for this currency
 * Return: An instance of CCRatesObject
 */
- (instancetype _Nullable)initWithCurrencyName:(NSString * _Nonnull)baseCurrencyName withExchangeRates:(NSDictionary * _Nonnull)rateData;

/*
 * Updates the object using the exchange rate data retrieved from the local device db
 */
- (void)updateWithSavedDetails:(CurrencyRates * _Nonnull)cdRatesObj;

/*
 * Updates the exchange rate data for the currency type and saves on the device
 * Param: rateData          The exchange rates for this currency
 */
- (void)saveUpdatedExchangeRates:(NSDictionary * _Nonnull)rateData;
@end
