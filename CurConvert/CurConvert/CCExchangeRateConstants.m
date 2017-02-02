//
//  CCExchangeRateConstants.m
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "CCExchangeRateConstants.h"

NSString *const CC_CURRENCY_KEY_AUD = @"AUD";
NSString *const CC_CURRENCY_KEY_BGN = @"BGN";
NSString *const CC_CURRENCY_KEY_BRL = @"BRL";
NSString *const CC_CURRENCY_KEY_CAD = @"CAD";
NSString *const CC_CURRENCY_KEY_CHF = @"CHF";
NSString *const CC_CURRENCY_KEY_CNY = @"CNY";
NSString *const CC_CURRENCY_KEY_CZK = @"CZK";
NSString *const CC_CURRENCY_KEY_DKK = @"DKK";
NSString *const CC_CURRENCY_KEY_EUR = @"EUR";
NSString *const CC_CURRENCY_KEY_GBP = @"GBP";
NSString *const CC_CURRENCY_KEY_HKD = @"HKD";
NSString *const CC_CURRENCY_KEY_HRK = @"HRK";
NSString *const CC_CURRENCY_KEY_HUF = @"HUF";
NSString *const CC_CURRENCY_KEY_IDR = @"IDR";
NSString *const CC_CURRENCY_KEY_ILS = @"ILS";
NSString *const CC_CURRENCY_KEY_INR = @"INR";
NSString *const CC_CURRENCY_KEY_JPY = @"JPY";
NSString *const CC_CURRENCY_KEY_KRW = @"KRW";
NSString *const CC_CURRENCY_KEY_MXN = @"MXN";
NSString *const CC_CURRENCY_KEY_MYR = @"MYR";
NSString *const CC_CURRENCY_KEY_NOK = @"NOK";
NSString *const CC_CURRENCY_KEY_NZD = @"NZD";
NSString *const CC_CURRENCY_KEY_PHP = @"PHP";
NSString *const CC_CURRENCY_KEY_PLN = @"PLN";
NSString *const CC_CURRENCY_KEY_RON = @"RON";
NSString *const CC_CURRENCY_KEY_RUB = @"RUB";
NSString *const CC_CURRENCY_KEY_SEK = @"SEK";
NSString *const CC_CURRENCY_KEY_SGD = @"SGD";
NSString *const CC_CURRENCY_KEY_THB = @"THB";
NSString *const CC_CURRENCY_KEY_TRY = @"TRY";
NSString *const CC_CURRENCY_KEY_USD = @"USD";
NSString *const CC_CURRENCY_KEY_ZAR = @"ZAR";

NSString *NSStringFromCCCurrencyKey(CCCurrencyKey runtimeKey) {
    NSString *value = nil;
    switch(runtimeKey) {
        case CCCurrencyKeyAUD:
            value = CC_CURRENCY_KEY_AUD;
            break;
        case CCCurrencyKeyBGN:
            value = CC_CURRENCY_KEY_BGN;
            break;
        case CCCurrencyKeyBRL:
            value = CC_CURRENCY_KEY_BRL;
            break;
        case CCCurrencyKeyCAD:
            value = CC_CURRENCY_KEY_CAD;
            break;
        case CCCurrencyKeyCHF:
            value = CC_CURRENCY_KEY_CHF;
            break;
        case CCCurrencyKeyCNY:
            value = CC_CURRENCY_KEY_CNY;
            break;
        case CCCurrencyKeyCZK:
            value = CC_CURRENCY_KEY_CZK;
            break;
        case CCCurrencyKeyDKK:
            value = CC_CURRENCY_KEY_DKK;
            break;
        case CCCurrencyKeyEUR:
            value = CC_CURRENCY_KEY_EUR;
            break;
        case CCCurrencyKeyGBP:
            value = CC_CURRENCY_KEY_GBP;
            break;
        case CCCurrencyKeyHKD:
            value = CC_CURRENCY_KEY_HKD;
            break;
        case CCCurrencyKeyHRK:
            value = CC_CURRENCY_KEY_HRK;
            break;
        case CCCurrencyKeyHUF:
            value = CC_CURRENCY_KEY_HUF;
            break;
        case CCCurrencyKeyIDR:
            value = CC_CURRENCY_KEY_IDR;
            break;
        case CCCurrencyKeyILS:
            value = CC_CURRENCY_KEY_ILS;
            break;
        case CCCurrencyKeyINR:
            value = CC_CURRENCY_KEY_INR;
            break;
        case CCCurrencyKeyJPY:
            value = CC_CURRENCY_KEY_JPY;
            break;
        case CCCurrencyKeyKRW:
            value = CC_CURRENCY_KEY_KRW;
            break;
        case CCCurrencyKeyMXN:
            value = CC_CURRENCY_KEY_MXN;
            break;
        case CCCurrencyKeyMYR:
            value = CC_CURRENCY_KEY_MYR;
            break;
        case CCCurrencyKeyNOK:
            value = CC_CURRENCY_KEY_NOK;
            break;
        case CCCurrencyKeyNZD:
            value = CC_CURRENCY_KEY_NZD;
            break;
        case CCCurrencyKeyPHP:
            value = CC_CURRENCY_KEY_PHP;
            break;
        case CCCurrencyKeyPLN:
            value = CC_CURRENCY_KEY_PLN;
            break;
        case CCCurrencyKeyRON:
            value = CC_CURRENCY_KEY_RON;
            break;
        case CCCurrencyKeyRUB:
            value = CC_CURRENCY_KEY_RUB;
            break;
        case CCCurrencyKeySEK:
            value = CC_CURRENCY_KEY_SEK;
            break;
        case CCCurrencyKeySGD:
            value = CC_CURRENCY_KEY_SGD;
            break;
        case CCCurrencyKeyTHB:
            value = CC_CURRENCY_KEY_THB;
            break;
        case CCCurrencyKeyTRY:
            value = CC_CURRENCY_KEY_TRY;
            break;
        case CCCurrencyKeyUSD:
            value = CC_CURRENCY_KEY_USD;
            break;
        case CCCurrencyKeyZAR:
            value = CC_CURRENCY_KEY_ZAR;
            break;
        default:
            break;
    }
    return value;
}
