//
//  CCRatesObject.m
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "CCRatesObject.h"
#import "CCDataManager.h"
#import "CurrencyRates.h"

@implementation CCRatesObject

+ (instancetype)saveRateObjectForCurrency:(NSString *)baseCurrencyName withExchangeRates:(NSDictionary *)rateData {

    // Create new instance of CCRatesObject
    CCRatesObject *ratesObject = [[CCRatesObject alloc] initWithCurrencyName:baseCurrencyName withExchangeRates:rateData];
    
    // Save the new data in the CCDatamanager
    CurrencyRates *cdRatesObj = [[CCDataManager sharedDataManager] saveNewCurrencyRates:ratesObject];
    ratesObject.cdCurrencyRates = cdRatesObj;
    
    // Return the new object
    return ratesObject;
}

+ (instancetype)rateObjectWithSavedData:(CurrencyRates *)cdRatesObj {
    // Initialize the new object from CD and return it
    CCRatesObject *ratesObject = [[CCRatesObject alloc] initWithCurrencyName:cdRatesObj.baseName withExchangeRates:(NSDictionary *)cdRatesObj.rateData];
    ratesObject.cdCurrencyRates = cdRatesObj;
    
    return ratesObject;
}

- (instancetype)initWithCurrencyName:(NSString * _Nonnull)baseCurrencyName withExchangeRates:(NSDictionary *)rateData {
    _timestamp = [NSDate date]; // We only update the timestamp when creating the record, or updating an existing record
    _baseCurrencyName = baseCurrencyName;
    _exchangeRates = rateData;
    
    return self;
}

- (void)updateWithSavedDetails:(CurrencyRates * _Nonnull)cdRatesObj {
    _timestamp = cdRatesObj.timestamp;
    _baseCurrencyName = cdRatesObj.baseName;
    _exchangeRates = (NSDictionary *)cdRatesObj.rateData;
    _cdCurrencyRates = cdRatesObj;
}

- (void)saveUpdatedExchangeRates:(NSDictionary * _Nonnull)rateData {
    // Update fields
    _exchangeRates = rateData;
    _timestamp = [NSDate date]; // We only update the timestamp when creating the record, or updating an existing record
    
    // Save the new data in the CCDatamanager
    CurrencyRates *cdRatesObj = [[CCDataManager sharedDataManager] updateCurrencyRates:self];
    _cdCurrencyRates = cdRatesObj;
}

@end
