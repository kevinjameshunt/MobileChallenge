//
//  CCExchangeRateConstants.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * List of all currencies available. This can be expanded by adding to the enum as well as the adding a corresponding string below
 */
typedef NS_ENUM(NSInteger, CCCurrencyKey) {
    CCCurrencyKeyAUD = 0,   // Start at zero for enumeration purposes
    CCCurrencyKeyBGN,
    CCCurrencyKeyBRL,
    CCCurrencyKeyCAD,
    CCCurrencyKeyCHF,
    CCCurrencyKeyCNY,
    CCCurrencyKeyCZK,
    CCCurrencyKeyDKK,
    CCCurrencyKeyEUR,
    CCCurrencyKeyGBP,
    CCCurrencyKeyHKD,
    CCCurrencyKeyHRK,
    CCCurrencyKeyHUF,
    CCCurrencyKeyIDR,
    CCCurrencyKeyILS,
    CCCurrencyKeyINR,
    CCCurrencyKeyJPY,
    CCCurrencyKeyKRW,
    CCCurrencyKeyMXN,
    CCCurrencyKeyMYR,
    CCCurrencyKeyNOK,
    CCCurrencyKeyNZD,
    CCCurrencyKeyPHP,
    CCCurrencyKeyPLN,
    CCCurrencyKeyRON,
    CCCurrencyKeyRUB,
    CCCurrencyKeySEK,
    CCCurrencyKeySGD,
    CCCurrencyKeyTHB,
    CCCurrencyKeyTRY,
    CCCurrencyKeyUSD,
    CCCurrencyKeyZAR,
    CCCurrencyKeyCount     // By keeping this at the end of the enum, we always have it's size
};

/*
 * Convenience method for converting enum to a usable string
 */
OBJC_EXPORT NSString *NSStringFromCCCurrencyKey(CCCurrencyKey runtimeKey);

OBJC_EXTERN NSString *const CC_CURRENCY_KEY_AUD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_BGN;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_BRL;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_CAD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_CHF;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_CNY;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_CZK;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_DKK;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_EUR;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_GBP;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_HKD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_HRK;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_HUF;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_IDR;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_ILS;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_INR;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_JPY;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_KRW;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_MXN;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_MYR;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_NOK;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_NZD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_PHP;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_PLN;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_RON;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_RUB;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_SEK;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_SGD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_THB;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_TRY;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_USD;
OBJC_EXTERN NSString *const CC_CURRENCY_KEY_ZAR;
