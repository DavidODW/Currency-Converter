//
//  LibraryAPI.swift
//  Currency Converter
//
//  Created by David ODW on 17/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import UIKit
import CoreData

class LibraryAPI: NSObject {
  class var sharedInstance: LibraryAPI {
    struct Singleton {
      static let instance = LibraryAPI()
    }
    
    return Singleton.instance
  }
  
  private let currencyManager: CurrencyManager
  private let currencyRatesManager: CurrencyRatesManager
  
  override init() {
    currencyManager = CurrencyManager()
    currencyRatesManager = CurrencyRatesManager()
    
    super.init()
  }
  
  // MARK: Currency and Country
  func getAllCurrencies() -> [CurrencyCore]? {
    return currencyManager.getCurrencies()
  }
  
  func getCurrencyInformationWithCurrencyCode(currencyCode: String) -> CurrencyCore? {
    return currencyManager.getCurrencyInformationWithCurrencyCode(currencyCode)
  }
  
  func getAllCountries() -> [CountryCore]? {
    return currencyManager.getCountries()
  }
  
  func saveChosenCurrencyWithCurrencyCode(currencyCode: String) {
    return currencyManager.saveChosenCurrencyWithCurrencyCode(currencyCode)
  }
  
  func deleteChosenCurrencyWithCurrencyCode(currencyCode: String) -> (isSuccess: Bool, errorMessage: String) {
    return currencyManager.deleteChosenCurrencyWithCurrencyCode(currencyCode)
  }
  
  func swapChosenCurrencyWithFirstAtPosition(position: Int) {
    return currencyManager.swapChosenCurrencyWithFirstAtPosition(position)
  }
  
  func saveCurrencyAmountWithCurrencyCode(currencyCode: String, amount: String) {
    return currencyManager.saveCurrencyAmountWithCurrencyCode(currencyCode, amount: amount)
  }
  
  func getAllChosenCurrenciesCount() -> Int {
    return currencyManager.getAllChosenCurrenciesCount()
  }
  
  func getAllChosenCurrencies() -> [CurrencyDashboard]? {
    return currencyManager.getAllChosenCurrencies()
  }
  
  // MARK: CurrencyRates
  func getExchangeRateFromBaseCurrency(base:String, toCurrency to:String, withAmount amount: String) -> (exchangeRate: String, totalAmount: String) {
    return currencyRatesManager.getExchangeRateFromBaseCurrency(base, toCurrency: to, withAmount: amount)
  }
}
