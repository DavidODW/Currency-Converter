//
//  CurrencyRatesManager.swift
//  Currency Converter
//
//  Created by David ODW on 26/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class CurrencyRatesManager: NSObject {
  let accessKey: String = "cf29830bb1c4f47e9e7f7830373be96a"
  let url: String = "http://www.apilayer.net/api/live"
  
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  override init() {
    super.init()
    
    requestCurrencyRates()
  }
  
  // Sending GET request to API for requesting currency exchange rates
  func requestCurrencyRates() {
    Alamofire.request(.GET, url, parameters: ["access_key": accessKey, "format": 1])
      .responseJSON { response in
        
        switch response.result {
        case .Success:
          if let data = response.data {
            do {
              let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
              
              guard let currencyRatesData = CurrencyRate(json: json) else {
                print("Error initializing object")
                return
              }
              
              self.persistCurrencyExchangeRatesWithData(currencyRatesData)
              
              let notification = NSNotification(name: "CurrencyRatesUpdate", object: nil)
              NSNotificationCenter.defaultCenter().postNotification(notification)
              
            } catch {
              print("Failed to initialize the data")
            }
          }
        case .Failure(let error):
          print(error)
        }
    }
  }
  
  // Persist all the currency exchanges rates after getting response from API
  func persistCurrencyExchangeRatesWithData(currencyRatesData: CurrencyRate) {
    deleteRecordsFromEntity("CurrencyRate")
    
    let managedContext = appDelegate.managedObjectContext
    
    let currencyRatesEntity = NSEntityDescription.entityForName("CurrencyRate", inManagedObjectContext: managedContext)
    
    for currencyRate in currencyRatesData.quotes {
      let currencyRateObject = CurrencyRateCore(entity: currencyRatesEntity!, insertIntoManagedObjectContext: managedContext)
      currencyRateObject.setValue(currencyRate.0, forKey: "name")
      currencyRateObject.setValue("\(currencyRate.1)", forKey: "rate")
    }
    
    do {
      try managedContext.save()
    } catch {
      print("Could not save Currency Rate")
    }
  }
  
  // Delete all the records for an entity
  private func deleteRecordsFromEntity(entityName: String) {
    let managedContext = appDelegate.managedObjectContext
    let coordinator = appDelegate.persistentStoreCoordinator
    
    let fetchRequest = NSFetchRequest(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try coordinator.executeRequest(deleteRequest, withContext: managedContext)
    } catch let error as NSError {
      print(error)
    }
  }
  
  // Get the exchange rate of base currency and target currency
  func getExchangeRateFromBaseCurrency(base:String, toCurrency to:String, withAmount amount:String) -> (exchangeRate: String, totalAmount: String) {
    let managedContext = appDelegate.managedObjectContext
    
    let baseCurrencyPredicate = NSPredicate(format: "name == %@", "USD" + base)
    let toCurrencyPredicate = NSPredicate(format: "name == %@", "USD" + to)

    let baseCurrencyFetchRequest = NSFetchRequest(entityName: "CurrencyRate")
    baseCurrencyFetchRequest.predicate = baseCurrencyPredicate
    
    let toCurrencyFetchRequest = NSFetchRequest(entityName: "CurrencyRate")
    toCurrencyFetchRequest.predicate = toCurrencyPredicate
    
    do {
      let baseCurrencyResults = try managedContext.executeFetchRequest(baseCurrencyFetchRequest)
      let toCurrencyResults = try managedContext.executeFetchRequest(toCurrencyFetchRequest)
      
      let baseCurrency = baseCurrencyResults[0] as! CurrencyRateCore
      let toCurrency = toCurrencyResults[0] as! CurrencyRateCore
      
      let exchangeRate = Float(toCurrency.rate)! / Float(baseCurrency.rate)!
      let totalAmount = Float(amount)! * exchangeRate
      return (exchangeRate.format(".4"), totalAmount.format(".4"))
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
    
    return ("", "")
  }
}

// Extension for specify the decimal places of Float
extension Float {
  func format(f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}
