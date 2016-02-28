//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by David ODW on 16/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import UIKit
import FlagKit

class AddCurrencyViewController: UIViewController {
  
  // MARK: Property
  @IBOutlet var sortingButton: [UIButton]!
  @IBOutlet weak var currencyTableView: UITableView!
  
  let searchController = UISearchController(searchResultsController: nil)
  let libraryAPI = LibraryAPI.sharedInstance
  
  var sortingMode = "CurrencyCode"
  var currencies: [CurrencyCore]?
  var countries: [CountryCore]?
  var chosenCurrencies: [CurrencyDashboard]?
  var isReady : Bool = false
  
  var currenciesSection : [(index: Int, length :Int, title: String)] = Array()
  var countriesSection : [(index: Int, length :Int, title: String)] = Array()
  var currenciesFilteredData: [CurrencyCore]!
  var countriesFilteredData: [CountryCore]!
  
  // MARK: View Controller's Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    definesPresentationContext = true
    navigationItem.titleView = searchController.searchBar
    
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "processCurrenciesItem:", name: "CurrenciesDataUpdate", object: nil)
    
    highlightSortingButtonExceptIndex(0)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
    
    isReady = true
    currencies = self.libraryAPI.getAllCurrencies()
    buildSectionForCurrencies(arrayName: self.currencies!)
    countries = self.libraryAPI.getAllCountries()
    buildSectionForCountries(arrayName: self.countries!)
    
    currenciesFilteredData = currencies!
    countriesFilteredData = countries!
    
    currencyTableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Method
  @IBAction func currencySortingSelectionAction(sender: AnyObject) {
    if sortingButton[0] == sender as! UIButton {
      highlightSortingButtonExceptIndex(0)
      sortingMode = "CurrencyCode"
      self.scrollToHeader()
      currencyTableView.reloadData()
    } else if sortingButton[1] == sender as! UIButton {
      highlightSortingButtonExceptIndex(1)
      sortingMode = "Country"
      self.scrollToHeader()
      currencyTableView.reloadData()
    }
  }
  
  func highlightSortingButtonExceptIndex(index : Int) {
    for i in 0 ..< sortingButton.count {
      if i != index {
        sortingButton[i].highlighted = true
      }
    }
  }
  
  func processCurrenciesItem(notification: NSNotification?) {
    dispatch_async(dispatch_get_main_queue(), {
      self.isReady = true
      self.currencies = self.libraryAPI.getAllCurrencies()
      self.buildSectionForCurrencies(arrayName: self.currencies!)
      self.countries = self.libraryAPI.getAllCountries()
      self.buildSectionForCountries(arrayName: self.countries!)
      
      self.currenciesFilteredData = self.currencies!
      self.countriesFilteredData = self.countries!
      
      self.currencyTableView.reloadData()
    })
  }
  
  func checkCurrencyIsExistWithCurrencyCode(currencyCode: String) -> Bool {
    
    if chosenCurrencies!.contains({$0.code == currencyCode}) {
      return true
    }
    return false
  }
  
  // Build indexed table view data for Currency
  func buildSectionForCurrencies(arrayName array: Array<CurrencyCore>) {
    var index = 0
    
    currenciesSection.removeAll()
    for ( var i = 0; i < array.count; i++ ) {
      let commonPrefix = array[i].code!.commonPrefixWithString(array[index].code! , options: .CaseInsensitiveSearch)
      
      if (commonPrefix.characters.count == 0 || i == array.count - 1) {
        let string = array[index].code!.uppercaseString;
        let firstCharacter = string[string.startIndex]
        let title = "\(firstCharacter)"
        let newSection = (index: index, length: i - index, title: title)
        
        currenciesSection.append(newSection)
        
        index = i;
      }
    }
    
  }
  
  // Build indexed table view data for Country
  func buildSectionForCountries(arrayName array: Array<CountryCore>) {
    var index = 0
    
    countriesSection.removeAll()
    for ( var i = 0; i < array.count; i++ ) {
      let commonPrefix = array[i].name!.commonPrefixWithString(array[index].name! , options: .CaseInsensitiveSearch)
      
      if (commonPrefix.characters.count == 0 || i == array.count - 1) {
        let string = array[index].name!.uppercaseString;
        let firstCharacter = string[string.startIndex]
        let title = "\(firstCharacter)"
        let newSection = (index: index, length: i - index, title: title)
        
        countriesSection.append(newSection)
        
        index = i;
      }
    }
  }
  
  // Filter the data based on the user input
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    if sortingMode == "CurrencyCode" {
      currenciesFilteredData = currencies!.filter { currency in
        return currency.code!.lowercaseString.containsString(searchText.lowercaseString)
      }
    } else if sortingMode == "Country" {
      countriesFilteredData = countries!.filter { country in
        return country.name!.lowercaseString.containsString(searchText.lowercaseString)
      }
    }
    currencyTableView.reloadData()
  }
  
  deinit {
    if let superView = searchController.view.superview
    {
      superView.removeFromSuperview()
    }
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension AddCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if searchController.active && searchController.searchBar.text != "" {
      return 1
    } else if sortingMode == "CurrencyCode" && isReady {
      return currenciesSection.count
    } else if sortingMode == "Country" && isReady {
      return countriesSection.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.active && searchController.searchBar.text != "" && sortingMode == "CurrencyCode" {
      return currenciesFilteredData.count
    } else if searchController.active && searchController.searchBar.text != "" && sortingMode == "Country" {
      return countriesFilteredData.count
    } else if sortingMode == "CurrencyCode" && isReady {
      return currenciesSection[section].length
    } else if sortingMode == "Country" && isReady {
      return countriesSection[section].length
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CurrencyCell") as! CurrencyCell
    chosenCurrencies = libraryAPI.getAllChosenCurrencies()!
    
    if searchController.active && searchController.searchBar.text != "" && sortingMode == "CurrencyCode" {
      let currency = currenciesFilteredData[indexPath.row]
      
      if checkCurrencyIsExistWithCurrencyCode(currency.code!) {
          cell.accessoryType = .Checkmark
      } else {
        cell.accessoryType = .None
      }
      
      if currency.majorCountry!.isEmpty && currency.majorContinent!.isEmpty {
        cell.imageView?.image = UIImage(flagImageForSpecialFlag: .World)
      } else if !currency.majorCountry!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorCountry!) {
          cell.imageView?.image = image
        } else if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.imageView?.image = image
        }
      } else if !currency.majorContinent!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.imageView?.image = image
        }
      }
      
      let currencyCode = currenciesFilteredData[indexPath.row].code!
      let currencyName = currenciesFilteredData[indexPath.row].name!
      cell.currency.text = "\(currencyCode) - \(currencyName)"
      
    } else if searchController.active && searchController.searchBar.text != "" && sortingMode == "Country" {
      let country = countriesFilteredData[indexPath.row]
      
      if checkCurrencyIsExistWithCurrencyCode(country.currency!.code!) {
        cell.accessoryType = .Checkmark
      } else {
        cell.accessoryType = .None
      }
      
      if let image = UIImage(flagImageWithCountryCode: country.code!) {
        cell.imageView?.image = image
      } else {
        cell.imageView?.image = UIImage(flagImageWithCountryCode: country.continentCode!)
      }
      
      cell.currency.text = "\(country.name!) (\(country.currency!.code!))"
      
    } else if sortingMode == "CurrencyCode" && isReady {
      let currency = currencies![currenciesSection[indexPath.section].index + indexPath.row]
      
      if checkCurrencyIsExistWithCurrencyCode(currency.code!) {
        cell.accessoryType = .Checkmark
      } else {
        cell.accessoryType = .None
      }
      
      if currency.majorCountry!.isEmpty && currency.majorContinent!.isEmpty {
        cell.imageView?.image = UIImage(flagImageForSpecialFlag: .World)
      } else if !currency.majorCountry!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorCountry!) {
          cell.imageView?.image = image
        } else if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.imageView?.image = image
        }
      } else if !currency.majorContinent!.isEmpty {
        if let image = UIImage(flagImageWithCountryCode: currency.majorContinent!) {
          cell.imageView?.image = image
        }
      }
      
      let currencyCode = currencies![currenciesSection[indexPath.section].index + indexPath.row].code!
      let currencyName = currencies![currenciesSection[indexPath.section].index + indexPath.row].name!
      cell.currency.text = "\(currencyCode) -  \(currencyName)"

    } else if sortingMode == "Country" && isReady {
      let country = countries![countriesSection[indexPath.section].index + indexPath.row]
      
      if checkCurrencyIsExistWithCurrencyCode(country.currency!.code!) {
        cell.accessoryType = .Checkmark
      } else {
        cell.accessoryType = .None
      }
      
      if let image = UIImage(flagImageWithCountryCode: country.code!) {
        cell.imageView?.image = image
      } else {
        cell.imageView?.image = UIImage(flagImageWithCountryCode: country.continentCode!)
      }

      cell.currency.text = "\(country.name!) (\(country.currency!.code!))"
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if searchController.active && searchController.searchBar.text != "" {
      return nil
    } else if sortingMode == "CurrencyCode" && isReady {
      return currenciesSection[section].title
    } else if sortingMode == "Country" && isReady {
      return countriesSection[section].title
    }
    
    return nil
  }
  
  func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    if searchController.active && searchController.searchBar.text != "" {
      return nil
    } else if sortingMode == "CurrencyCode" && isReady {
      return currenciesSection.map { $0.title }
    } else if sortingMode == "Country" && isReady {
      return countriesSection.map { $0.title }
    }
    
    return nil
  }
  
  func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    return index
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    
    if searchController.active && searchController.searchBar.text != "" && sortingMode == "CurrencyCode" {
      let currency = currenciesFilteredData[indexPath.row]
      toggleSelectedRowActionAtCell(cell, withCurrencyCode: currency.code!)
    } else if searchController.active && searchController.searchBar.text != "" && sortingMode == "Country" {
      let country = countriesFilteredData[indexPath.row]
      toggleSelectedRowActionAtCell(cell, withCurrencyCode: country.currency!.code!)
    } else if sortingMode == "CurrencyCode" && isReady {
      let currency = currencies![currenciesSection[indexPath.section].index + indexPath.row]
      toggleSelectedRowActionAtCell(cell, withCurrencyCode: currency.code!)
      
    } else if sortingMode == "Country" && isReady {
      let country = countries![countriesSection[indexPath.section].index + indexPath.row]
      toggleSelectedRowActionAtCell(cell, withCurrencyCode: country.currency!.code!)
      
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    tableView.reloadData()
  }
  
  func scrollToHeader() {
    self.currencyTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
  }
  
  // Check and uncheck cell's accessoryType and process actions
  func toggleSelectedRowActionAtCell(cell: UITableViewCell?, withCurrencyCode currencyCode: String) {
    if (cell!.accessoryType == .None) {
      libraryAPI.saveChosenCurrencyWithCurrencyCode(currencyCode)
      cell!.accessoryType = .Checkmark
    } else {
      let result = libraryAPI.deleteChosenCurrencyWithCurrencyCode(currencyCode)
      if result.isSuccess {
        cell!.accessoryType = .None
      } else {
        displayAlertForLessThanTwoCurrenciesSelected(withErrorMessage: result.errorMessage)
      }
    }
  }
  
  // Display an alert when less than two chosen currencies is selected
  func displayAlertForLessThanTwoCurrenciesSelected(withErrorMessage message: String) {
    let alertController = UIAlertController(title: "Min 2 Currencies Selected" , message: message, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}

// MARK: UISearchBarDelegate, UISearchResultsUpdating
extension AddCurrencyViewController: UISearchBarDelegate, UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
