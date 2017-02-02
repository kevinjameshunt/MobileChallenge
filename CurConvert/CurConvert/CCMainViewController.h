//
//  ViewController.h
//  CurConvert
//
//  Created by Kevin Hunt on 2017-01-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * Main view used to display currency exchange rate data
 */
@interface CCMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

/*
 * UITableView use for displaying converted values
 */
@property (strong, nonatomic) IBOutlet UITableView *exchangeRateTableView;

/*
 * Picker used to select currency to be compared
 */
@property (strong, nonatomic) IBOutlet UIPickerView *currencyPickerView;

/*
 * The amount to be converted using the retrieved exchange rate data
 */
@property (strong, nonatomic) IBOutlet UITextField *amountField;

/*
 * Button used to allow user to display/dismiss currency selection picker
 */
@property (strong, nonatomic) IBOutlet UIButton *selectCurrencyBtn;

/*
 * Button used to calculate the converted values of the given amount for the selected currency
 */
@property (strong, nonatomic) IBOutlet UIButton *calculateBtn;

/*
 * Triggered when the user taps the selectCurrencyBtn, displays/dismisses the currency picker
 */
- (IBAction)selectCurrencyBtnPressed:(id)sender;

/*
 * Triggerd when the user taps the calculateBtn, checks if selected currency needs to be refreshed, updates UI with converted values based on amount and selected currency
 */
- (IBAction)calculateBtnPressed:(id)sender;

@end

