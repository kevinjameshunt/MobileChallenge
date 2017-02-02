//
//  CurrencyRates+CoreDataProperties.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CurrencyRates.h"

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyRates (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *baseName;
@property (nullable, nonatomic, retain) id rateData;
@property (nullable, nonatomic, retain) NSDate *timestamp;

@end

NS_ASSUME_NONNULL_END
