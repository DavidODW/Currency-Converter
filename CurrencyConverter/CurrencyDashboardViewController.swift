//
//  CurrencyDashboardViewController.swift
//  Currency Converter
//
//  Created by David ODW on 14/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import UIKit

class CurrencyDashboardViewController: UIViewController {
  
  // MARK: Property
  
  let libraryAPI = LibraryAPI.sharedInstance
  
  var chosenCurrencies: [CurrencyDashboard]?
  var isReady : Bool = false
  var isCurrencyRatesReady : Bool = false
  
  @IBOutlet weak var currencyDashboardTableView: UITableView!
  
  // MARK: View Controller's Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let image = UIImage(named: "logo")
    navigationItem.titleView = UIImageView(image: image)
    
    // Register self as the observer for the notificaion named "CurrencyRatesUpdate"
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "processCurrencyRates:", name: "CurrencyRatesUpdate", object: nil)
    
    currencyDashboardTableView.tableFooterView = UIView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
    
    updateTableView()
  }
  
  // MARK: Method
  // Request the updated data and update the table view
  func updateTableView() {
    updateChosenCurrenciesData()
    isReady = true
    currencyDashboardTableView.reloadData()
  }
  
  // Requested the updated data
  func updateChosenCurrenciesData() {
    chosenCurrencies = libraryAPI.getAllChosenCurrencies()
  }
  
  // Observer selector
  func processCurrencyRates(notification: NSNotification?) {
    isCurrencyRatesReady = true
    currencyDashboardTableView.reloadData()
  }
  
  @IBAction func textFieldChanged(sender: AnyObject) {
    let cell = currencyDashboardTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! BaseCurrencyItemTableViewCell
    
    let textField = sender as! UITextField
    if textField.text!.isEmpty {
      textField.text = "0"
    }
    libraryAPI.saveCurrencyAmountWithCurrencyCode(chosenCurrencies![0].code!, amount: cell.baseCurrencyAmount.text!)
    updateAllCurrencyAmount()
  }
  
  // Update all other currency amount when editing value in text field
  // ATTENTION: Avoid using tableview.reloadData because it will cause text field to lose first responder
  func updateAllCurrencyAmount() {
    let baseCurrency = chosenCurrencies![0]
    
    for i in 1 ..< chosenCurrencies!.count {
      let cell = currencyDashboardTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! CurrencyItemTableViewCell
      let currency = libraryAPI.getCurrencyInformationWithCurrencyCode(chosenCurrencies![i].code!) as CurrencyCore!
      
      let result = libraryAPI.getExchangeRateFromBaseCurrency(baseCurrency.code!, toCurrency: chosenCurrencies![i].code!, withAmount: baseCurrency.amount!)
      cell.currencyAmount.text = "\(currency!.symbol!) \(result.totalAmount)"
      cell.currencyExchangeRate.text = "1 \(baseCurrency.code!) = \(result.exchangeRate) \(currency!.code!)"
      
      // Save the exchange result to prepare current cell prepare for become base currency in the future
      libraryAPI.saveCurrencyAmountWithCurrencyCode(currency!.code!, amount: result.totalAmount)
    }
  }
  
  // When done button in keyboard accessory view is clicked
  func doneButtonClicked() {
    let cell = currencyDashboardTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! BaseCurrencyItemTableViewCell
  
    cell.baseCurrencyAmount.resignFirstResponder()
  }
  
  // Display an alert when less than two chosen currencies is selected
  func displayAlertForLessThanTwoCurrenciesSelected(withErrorMessage message: String) {
    let alertController = UIAlertController(title: "Min 2 Currencies Selected" , message: message, preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in
      self.currencyDashboardTableView.setEditing(false, animated: false)
    }
    
    alertController.addAction(cancelAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension CurrencyDashboardViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isReady {
      return chosenCurrencies!.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let currency = libraryAPI.getCurrencyInformationWithCurrencyCode(chosenCurrencies![indexPath.row].code!) as CurrencyCore!
    
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("BaseCurrencyItemIdentifier") as! BaseCurrencyItemTableViewCell
      
      if currency.majorCountry!.isEmpty && currency.majorContinent!.isEmpty {
        cell.flagImageView.image = UIImage(flagImageForSpecialFlag: .World)
      } else if !currency.majorCountry!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorCountry!) {
          cell.flagImageView.image = image
        } else if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.flagImageView.image = image
        }
      } else if !currency.majorContinent!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.flagImageView.image = image
        }
      }
      
      cell.baseCurrencyAmount.text = "\(chosenCurrencies![indexPath.row].amount!)"
      cell.baseCurrencySymbol.text = "\(currency!.symbol!)"
      addToolBar(cell.baseCurrencyAmount)
      cell.baseCurrencyName.text = "\(currency!.code!) - \(currency!.name!)"
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("CurrencyItemIdentifier") as! CurrencyItemTableViewCell
      
      if currency.majorCountry!.isEmpty && currency.majorContinent!.isEmpty {
        cell.flagImageView.image = UIImage(flagImageForSpecialFlag: .World)
      } else if !currency.majorCountry!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorCountry!) {
          cell.flagImageView.image = image
        } else if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.flagImageView.image = image
        }
      } else if !currency.majorContinent!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.flagImageView.image = image
        }
      }
      
      cell.currencyAmount.text = "Updating"
      cell.currencyExchangeRate.text = "Updating"
      cell.currencyName.text = "\(currency!.code!) - \(currency!.name!)"
      
      if isCurrencyRatesReady {
        // Get the base currency
        let firstCell = chosenCurrencies![0]
        
        // Get the exchange rate of the base's currency code and selected row's currency code
        let result = libraryAPI.getExchangeRateFromBaseCurrency(firstCell.code!, toCurrency: currency!.code!, withAmount: firstCell.amount!)
        
        cell.currencyAmount.text = "\(currency!.symbol!) \(result.totalAmount)"
        cell.currencyExchangeRate.text = "1 \(firstCell.code!) = \(result.exchangeRate) \(currency!.code!)"
        
        // Save the exchange result to prepare current cell prepare for become base currency in the future
        libraryAPI.saveCurrencyAmountWithCurrencyCode(currency!.code!, amount: result.totalAmount)
      }
      
      return cell
    }
    
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.row == 0 { return nil }
    return indexPath
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    libraryAPI.swapChosenCurrencyWithFirstAtPosition(indexPath.row)
    
    let firstRowIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    // Begin the animation of the swap process between base currency and selected currency
    currencyDashboardTableView.beginUpdates()
    currencyDashboardTableView.moveRowAtIndexPath(indexPath, toIndexPath: firstRowIndexPath)
    currencyDashboardTableView.moveRowAtIndexPath(firstRowIndexPath, toIndexPath: indexPath)
    currencyDashboardTableView.endUpdates()
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    
    // Update table view after the animation is almost finish
    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), (300 + Int64(indexPath.row * 10)) * Int64(NSEC_PER_MSEC))
    dispatch_after(time, dispatch_get_main_queue()) {
      self.updateTableView()
    }
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if indexPath.row == 0 {
      return false
    }
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      if libraryAPI.getAllChosenCurrenciesCount() > 2 {
  
        libraryAPI.deleteChosenCurrencyWithCurrencyCode(chosenCurrencies![indexPath.row].code!)
        updateChosenCurrenciesData()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
      } else {
        displayAlertForLessThanTwoCurrenciesSelected(withErrorMessage: "Please add another currency before removing this one.")
      }
    }
  }
}

// MARK: UITextFieldDelegate
extension CurrencyDashboardViewController: UITextFieldDelegate {
  
  // Add Accessory View on top of the keyboard
  func addToolBar(textField: UITextField) {
    let toolBar = UIToolbar()
    toolBar.barStyle = .Default
    toolBar.translucent = true
    let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonClicked")
    let spacer1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
    toolBar.setItems([spacer, doneButton, spacer1], animated: false)
    toolBar.userInteractionEnabled = true
    toolBar.sizeToFit()
    
    textField.delegate = self
    textField.inputAccessoryView = toolBar
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    textField.selectAll(nil)
  }
}
