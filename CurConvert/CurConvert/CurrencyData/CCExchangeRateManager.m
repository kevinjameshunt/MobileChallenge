//
//  CCExchangeRateManager.m
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "CCExchangeRateManager.h"
#import "CCExchangeRateConstants.h"
#import "CCRatesObject.h"
#import "CCDataManager.h"
#import "CurrencyRates.h"

// Fixer.io constants for constructing requests
#define kFixerBaseURL               @"https://api.fixer.io/"
#define kFixerUrlComponentLatest    @"latest"
#define kFixerUrlComponentBaseCur   @"base"
#define kFixerUrlComponentSymbols   @"symbols"

#define kFixerResponseDataRatesKey  @"rates"

#define kTimeCompare30Min 1800 // 60sec * 30

@implementation CCExchangeRateManager {
    NSMutableDictionary *_currencyExchangeRates;
    NSTimer *_updateTimer;
}

static CCExchangeRateManager *_sharedExchangeRateManager;

+ (nullable CCExchangeRateManager *)sharedExchangeRateManager; {
    @synchronized([CCExchangeRateManager class]) {
        
        // Initialize the shared object if it does not already exist
        if(!_sharedExchangeRateManager) {
            NSLog(@"Creating Rate Retriever");
            _sharedExchangeRateManager  = [[CCExchangeRateManager alloc] init];
        }
        
        NSLog(@"Returning shared Rate Retriever");
        return _sharedExchangeRateManager;
    }
    
    return nil;
}

- (id)init {
    if(self = [super init]) {
        // Initalize working dictionary of exchange rates
        _currencyExchangeRates = [NSMutableDictionary dictionary];
        NSArray *cdRatesArray = [[CCDataManager sharedDataManager] getAllCurrencyRates];
        
        for (CurrencyRates *cdRateObj in cdRatesArray) {
            CCRatesObject *rateObj = [CCRatesObject rateObjectWithSavedData:cdRateObj];
            [_currencyExchangeRates setObject:rateObj forKey:rateObj.baseCurrencyName];
        }
    }
    
    return self;
}

- (BOOL)isRateDataFreshForCurrency:(nonnull NSString *)currencyName {
    // Get exchange rates for currency request
    CCRatesObject *rateObj = [_currencyExchangeRates objectForKey:currencyName];
    
    // If we have exchange rate data, check the timestamp
    if (rateObj) {
        NSDate *lastUpdateTimestamp = rateObj.timestamp;
        NSDate *currentTime = [NSDate date];
        NSTimeInterval timeDiff = [currentTime timeIntervalSinceDate:lastUpdateTimestamp];
        
        // If it is older than 30 minutes, it is not fresh
        if (timeDiff > kTimeCompare30Min) {
            return NO;
        } else {
            return YES;
        }
    } else {
        // If we do not have an exchange rate, it is most definitely not fresh, return false
        return NO;
    }
}

- (void)checkAndUpdateAllExchangeRatesWithcallback:(nullable CCAllRateRetrievalRequestCompleted)callback {
    NSMutableArray *errorArray = [NSMutableArray array];
    
    // Loop through each currency type and retrieve its exchanges rates relative to all other currencies
    for (int i=0; i < CCCurrencyKeyCount; i++) {
        NSString *currencyName = NSStringFromCCCurrencyKey(i);
        // This method will save the new data so that is persisted AND update the working cache if they need to be refreshed
        [self retrieveRatesForCurrency:currencyName callback:^(CCRatesObject * _Nullable rateObject, NSError * _Nullable error) {
            if (error) {
                [errorArray addObject:error];
            }
        }];
    }
    
    if ([errorArray count] > 0) {
        NSLog(@"We have encountered %ld errors while updating all exchange rates", [errorArray count]);
        callback(errorArray);
    } else {
        callback(nil);
    }
}

- (void)retrieveRatesForCurrency:(nonnull NSString *)currencyName callback:(nullable CCRateRetrievalRequestCompleted)callback {
    
    if ([self isRateDataFreshForCurrency:currencyName]) {
        
        // If the exchange rate data we have is less than 30 minutes old, return it immediately
        CCRatesObject *rateObj = [_currencyExchangeRates objectForKey:currencyName];
        if (callback) {
            callback(rateObj, nil);
        }
        
    } else { // If not, we must retrieve new data.
        
        // Construct the URL to retrieve the latest exchange rates for the requested currency name
        NSString *requestUrl = [NSString stringWithFormat:@"%@%@?%@=%@", kFixerBaseURL, kFixerUrlComponentLatest, kFixerUrlComponentBaseCur, currencyName];
        NSURLRequest *networkRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        
        // Make an asynchronous network call
        [NSURLConnection sendAsynchronousRequest:networkRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               NSLog(@"Fixer.io request returned with response: %@ /nData: %@", response, data);
                               
                               // If we have data and there is no error
                               if (!connectionError && data) {
                                   
                                   // Process the response data
                                   NSError *readError = nil;
                                   NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&readError];
                                   if (readError != nil || responseDict == nil) {
                                       NSLog(@"There was an issue parsing the data: %@. \nError: %@", data, readError);
                                       if (callback) {
                                           callback(nil, connectionError);
                                       }
                                       
                                   } else {
                                       
                                       // Retrieve rates list from responseDict
                                       NSDictionary *ratesDict = [responseDict objectForKey:kFixerResponseDataRatesKey];
                                       
                                       // If we have a dictionary of exchange rates
                                       if (ratesDict && [ratesDict count] > 0) {
                                           
                                           CCRatesObject *ratesObject = [_currencyExchangeRates objectForKey:currencyName];
                                           
                                           // Check to see if we already an existing rates object
                                           if (ratesObject) {
                                               // If it already exists, we just want to update it
                                               [ratesObject saveUpdatedExchangeRates:ratesDict];
                                           } else {
                                               // Save the new CCRatesObject
                                               ratesObject = [CCRatesObject saveRateObjectForCurrency:currencyName withExchangeRates:ratesDict];
                                           }

                                           // If we have saved or updated the object successfully, keep it in the working cache and pass it to the callback
                                           if (ratesObject != nil) {
                                               [_currencyExchangeRates setObject:ratesObject forKey:ratesObject.baseCurrencyName];
                                               if (callback) {
                                                   callback(ratesObject, nil);
                                               }
                                           } else {
                                               // Notify caller that there was an error so UI can display
                                               NSLog(@"There was an issue with storing the new data: %@. \nError: %@", data, connectionError);
                                               if (callback) {
                                                   callback(nil, nil); // We should construct our own NSError object here
                                               }
                                           }
                                       } else { // Notify caller that there was an error so UI can display
                                           NSLog(@"There were no exchange rates in the response: %@.", ratesDict);
                                           if (callback) {
                                               callback(nil, nil); // We should construct our own NSError object here
                                           }
                                       }
                                   }
                                   
                               } else { // Notify caller that there was an error so UI can display
                                   NSLog(@"There was an issue with retrieving the data: %@. \nError: %@", data, connectionError);
                                   if (callback) {
                                       callback(nil, connectionError);
                                   }
                               }
                           }];
    }
}

- (CCRatesObject *)ratesForCurrency:(nonnull NSString *)currencyName {
    return [_currencyExchangeRates objectForKey:currencyName];
}

- (void)stopUpdateTimer {
    if (_updateTimer != nil) {
        NSLog(@"Invalidate update timer: %@", _updateTimer);
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
}

- (void)startUpdateTimer {
    // Stop the update timer if it has been started previously
    [self stopUpdateTimer];

    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeCompare30Min
                                                       target:self
                                                     selector:@selector(handleUpdateTimerTriggered:)
                                                     userInfo:nil
                                                      repeats:YES];
    NSLog(@"Starting update timer: %@", _updateTimer);
}

- (void)handleUpdateTimerTriggered:(NSTimer *)timer {
    // Attempt to refresh all rate records
    [self checkAndUpdateAllExchangeRatesWithcallback:^(NSArray<NSError *> * _Nullable errorList) {
        
        // Check errors
        if (errorList && [errorList count] > 0) {
            // If there are errors, display a message on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Just put the errors in the log
                NSLog(@"%ld currencies encountered errors while updating to the latest exchange rates.", [errorList count]);
                
            });
        }
    }];
}

@end
