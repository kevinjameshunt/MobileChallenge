//
//  ViewController.m
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "CCMainViewController.h"
#import "CCExchangeRateConstants.h"
#import "CCExchangeRateManager.h"
#import "CCRatesObject.h"

#define kLastSelectedCurrencyKey    @"LastSelectedCurrencyKey"
#define kLastValueKey               @"LastLastValueKey"

typedef NS_ENUM(NSInteger, CCInputActiveState) {
    CCInputActiveStateNone,
    CCInputActiveStateEnteringAmount,
    CCInputActiveStateSelectingCurrency,
    CCInputActiveStateRetrievingData
};

@interface CCMainViewController ()

@end

@implementation CCMainViewController {
    CCInputActiveState _currentUIState;
    CCCurrencyKey _selectedCurrency;
    CCRatesObject *_ratesForSelectedCurrency;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

    // Get last used values and pre-load UI
    self.amountField.text = [[NSUserDefaults standardUserDefaults] valueForKey:kLastValueKey];
    
    NSNumber *currencyKeyNum = [[NSUserDefaults standardUserDefaults] valueForKey:kLastSelectedCurrencyKey];
    _selectedCurrency = (CCCurrencyKey) [currencyKeyNum integerValue];
    
    NSString *selectedCurrencyString = NSStringFromCCCurrencyKey(_selectedCurrency);
    [self.selectCurrencyBtn setTitle:selectedCurrencyString forState:UIControlStateNormal];
    
    
    
    // Update the converted value table
    _ratesForSelectedCurrency = [[CCExchangeRateManager sharedExchangeRateManager] ratesForCurrency:selectedCurrencyString];
    [self.exchangeRateTableView reloadData];
    
    // Update all content
    [self updateAllData];
    
    // Start update timer
    [[CCExchangeRateManager sharedExchangeRateManager] startUpdateTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateAllData {
    // Update UI state
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _currentUIState = CCInputActiveStateRetrievingData;
    
    // Loop through all currencies and check to see if any need refreshing
    [[CCExchangeRateManager sharedExchangeRateManager] checkAndUpdateAllExchangeRatesWithcallback:^(NSArray<NSError *> * _Nullable errorList) {
        
        // Update UI state
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _currentUIState = CCInputActiveStateNone;
        
        // Check errors
        if (errorList && [errorList count] > 0) {
            // If there are errors, display a message on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Create an alert to let the user know there were errors
                NSString *errorMessage = [NSString stringWithFormat:@"%ld currencies encountered errors while updating to the latest exchange rates.", [errorList count]];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error Updating Exchange Rates" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                // Present the alert
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        
        // Update the converted value table
        NSString *selectedCurrencyString = NSStringFromCCCurrencyKey(_selectedCurrency);
        _ratesForSelectedCurrency = [[CCExchangeRateManager sharedExchangeRateManager] ratesForCurrency:selectedCurrencyString];
        [self.exchangeRateTableView reloadData];
    }];
}

- (IBAction)selectCurrencyBtnPressed:(id)sender {
    
    switch (_currentUIState) {
        case CCInputActiveStateEnteringAmount:
            [self.amountField resignFirstResponder]; // Hide the keyboard and then show the picker
        case CCInputActiveStateNone:
            self.currencyPickerView.hidden = NO;
            [self.selectCurrencyBtn setTitle:@"DONE" forState:UIControlStateNormal];
            _currentUIState = CCInputActiveStateSelectingCurrency;
            break;
        case CCInputActiveStateSelectingCurrency: { // Hide the picker and update UI
            _selectedCurrency = [self.currencyPickerView selectedRowInComponent:0];
            self.currencyPickerView.hidden = YES;
            NSString *selectedCurrencyString = NSStringFromCCCurrencyKey(_selectedCurrency);
            [self.selectCurrencyBtn setTitle:selectedCurrencyString forState:UIControlStateNormal];
            _currentUIState = CCInputActiveStateNone;
            break;
        }
        case CCInputActiveStateRetrievingData: // Do nothing if we are retrieving data
            break;
        default:
            break;
    }
}

- (IBAction)calculateBtnPressed:(id)sender {
    
    // As long as we are not already trying to retrieve data
    if (_currentUIState != CCInputActiveStateRetrievingData) {

        // If we were in the process of selecting the currency when pressed, assume the latest selection is the desired one
        if (_currentUIState == CCInputActiveStateSelectingCurrency) {
            _selectedCurrency = [self.currencyPickerView selectedRowInComponent:0];
        }
        
        // Store values to for the next time app is run
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_selectedCurrency] forKey:kLastSelectedCurrencyKey];
        [[NSUserDefaults standardUserDefaults] setObject:self.amountField.text forKey:kLastValueKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Clean up the UI
        [self.amountField resignFirstResponder];
        
        self.currencyPickerView.hidden = YES;
        NSString *selectedCurrencyString = NSStringFromCCCurrencyKey(_selectedCurrency);
        [self.selectCurrencyBtn setTitle:selectedCurrencyString forState:UIControlStateNormal];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        _currentUIState = CCInputActiveStateRetrievingData;
        
        
        // Get the new data
        [[CCExchangeRateManager sharedExchangeRateManager] retrieveRatesForCurrency:selectedCurrencyString callback:^(CCRatesObject * _Nullable rateObject, NSError * _Nullable error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            _currentUIState = CCInputActiveStateNone;
            
            // Update the converted value table
            _ratesForSelectedCurrency = rateObject;
            [self.exchangeRateTableView reloadData];
        }];
    }
}

#pragma mark - Application State Observers

- (void)handleWillEnterForeground {
    NSLog(@"Application received WillEnterForeground. Will check to update all data if necessary.");
    
    // Update all content
    [self updateAllData];
    
    // Start update timer
    [[CCExchangeRateManager sharedExchangeRateManager] startUpdateTimer];
}

- (void)handleDidEnterBackground {
    NSLog(@"Application received DidEnterBackground, stopping update timer");
    
    // Stop the update timer since we are in the background
    [[CCExchangeRateManager sharedExchangeRateManager] stopUpdateTimer];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CCCurrencyKeyCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ExchangeRateCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    // Get the currency to calculate for this cell. Each row corresponds to the enum
    NSString *currencyToCalculate = NSStringFromCCCurrencyKey(indexPath.row);
    
    float valueToExchange = [self.amountField.text floatValue];
    
    // Get the exchange rate
    NSNumber *exchangeRateNum = [_ratesForSelectedCurrency.exchangeRates objectForKey:currencyToCalculate];
    if (exchangeRateNum) {
        // Calculate the value
        float exchangeRate = [exchangeRateNum floatValue];
        float exchangedValue = exchangeRate * valueToExchange;
        
        // Update the labels
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %.02f", currencyToCalculate, exchangedValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Exchange rate: %.05f", exchangeRate];
        
    } else if (indexPath.row == _selectedCurrency) {
        // Show the selected currency value
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %.02f", currencyToCalculate, valueToExchange];
        cell.detailTextLabel.text = @"Exchange rate: 1.00000";
    } else { // If we cannot find the exchange rate, display an error
        NSLog(@"Unable to find excahnge rate for %@", currencyToCalculate);
        cell.textLabel.text = [NSString stringWithFormat:@"%@: 0.00", currencyToCalculate];
        cell.detailTextLabel.text = @"0.00";
    }

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return CCCurrencyKeyCount;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // Since we are using the CCCurrencyKey enum, we can just get the corresponding text for the row number;
    return NSStringFromCCCurrencyKey(row);
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // If we were in the process of selecting the currency when pressed, assume the latest selection is the desired one
    if (_currentUIState == CCInputActiveStateSelectingCurrency) {
        _selectedCurrency = [self.currencyPickerView selectedRowInComponent:0];
    }
    
    // Update the UI
    self.currencyPickerView.hidden = YES;
    NSString *selectedCurrencyString = NSStringFromCCCurrencyKey(_selectedCurrency);
    [self.selectCurrencyBtn setTitle:selectedCurrencyString forState:UIControlStateNormal];
    _currentUIState = CCInputActiveStateEnteringAmount;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    _currentUIState = CCInputActiveStateNone;
    return YES;
}

@end
