//
//  DataManager.swift
//  Currency Converter
//
//  Created by David ODW on 16/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CurrencyManager: NSObject {
  
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  private var currencies = [Currency]()
  
  override init() {
    super.init()
    
    // Persist default two type of currencies
    self.persistDefaultCurrency()
    
    requestCurrenciesData()
  }
  
  func requestCurrenciesData() {
    getCurrenciesDataFromFileWithSuccess { (data) -> Void in
      var json: [String: AnyObject]
      
      do {
        json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject]
        
        guard let currencyData = CurrencyData(json: json) else {
          print("Error initializing object")
          return
        }
        
        self.currencies = currencyData.currency!
        
        // Checking the JSON's id is same as previous read
        let defaults = NSUserDefaults.standardUserDefaults()
        if let id = defaults.stringForKey("id")
        {
          if id == currencyData.id {
            let notification = NSNotification(name: "CurrenciesDataUpdate", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            return
          }
        }
        
        self.persistCurrencyDataForId(currencyData.id)
        
        let notification = NSNotification(name: "CurrenciesDataUpdate", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
      } catch {
        print(error)
        return
      }
    }
  }
  
  func persistCurrencyDataForId(id: String) {
    // Save the new JSON's id into NSUserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(id, forKey: "id")
    
    // Delete all the records in existing table
    deleteRecordsFromEntity("Country")
    deleteRecordsFromEntity("Currency")
  
    // Insert the new records
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    let currencyEntity = NSEntityDescription.entityForName("Currency", inManagedObjectContext: managedContext)
    let countryEntity = NSEntityDescription.entityForName("Country", inManagedObjectContext: managedContext)
    
    for currency in currencies {
      let currencyObject = CurrencyCore(entity: currencyEntity!, insertIntoManagedObjectContext: managedContext)
      
      currencyObject.setValue(currency.code, forKeyPath: "code")
      currencyObject.setValue(currency.name, forKeyPath: "name")
      currencyObject.setValue(currency.symbol, forKey: "symbol")
      currencyObject.setValue(currency.major_country, forKeyPath: "majorCountry")
      currencyObject.setValue(currency.major_continent, forKeyPath: "majorContinent")
      
      for country in currency.country! {
        let countryObject = CountryCore(entity: countryEntity!, insertIntoManagedObjectContext: managedContext)
        
        countryObject.setValue(country.name, forKeyPath: "name")
        countryObject.setValue(country.code, forKeyPath: "code")
        countryObject.setValue(country.continent, forKeyPath: "continent")
        countryObject.setValue(country.continentCode, forKeyPath: "continentCode")
        
        countryObject.currency = currencyObject
      }
    }
    
    do {
      try managedContext.save()
    } catch let error as NSError  {
      print("Could not save \(error), \(error.userInfo)")
    }
  }
  
  func persistDefaultCurrency() {
    saveChosenCurrencyWithCurrencyCode("MYR")
    saveChosenCurrencyWithCurrencyCode("USD")
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
  
  // MARK: Currency
  
  // Get all the records from Entity "Currency"
  func getCurrencies() -> [CurrencyCore]? {
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Currency")
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let currencies = results as! [CurrencyCore]
      
      return currencies.sort { $0.code < $1.code }
    } catch let error as NSError {
       print("Could not fetch \(error), \(error.userInfo)")
    }
    return nil
  }
  
  func getCurrencyInformationWithCurrencyCode(currencyCode: String) -> CurrencyCore? {
    let managedContext = appDelegate.managedObjectContext
    
    let predicate = NSPredicate(format: "code == %@", currencyCode)
    
    let fetchRequest = NSFetchRequest(entityName: "Currency")
    fetchRequest.predicate = predicate
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let currency = results[0] as! CurrencyCore
      
      return currency
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
    return nil
  }
  
  // MARK: Country
  
  // Get all the records from Entity "Country"
  func getCountries() -> [CountryCore]? {
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Country")
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let countries = results as! [CountryCore]
      
      return countries.sort { $0.name < $1.name }
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
    return nil
  }
  
  // MARK: CurrencyDashboard
  
  // Save Chosen Currency into Entity "CurrencyDashboard"
  func saveChosenCurrencyWithCurrencyCode(currencyCode: String) {
    let managedContext = appDelegate.managedObjectContext
    
    if chosenCurrencyIsExistWithCurrencyCode(currencyCode) {
      return
    }
    
    let currencyDashboardEntity = NSEntityDescription.entityForName("CurrencyDashboard", inManagedObjectContext: managedContext)
    let currencyDashboardItem = NSManagedObject(entity: currencyDashboardEntity!, insertIntoManagedObjectContext: managedContext)
    
    currencyDashboardItem.setValue(currencyCode, forKey: "code")
    currencyDashboardItem.setValue(getAllChosenCurrenciesCount(), forKeyPath: "orderPosition")
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save \(error), \(error.userInfo)")
    }
  }
  
  // Delete a single entity from Entity "CurrencyDashboard"
  func deleteChosenCurrencyWithCurrencyCode(currencyCode: String) -> (isSuccess: Bool, errorMessage: String) {
    
    if getAllChosenCurrenciesCount() == 2 {
      return (false, "Please add another currency before removing this one.")
    }
    
    let managedContext = appDelegate.managedObjectContext
    
    let predicate = NSPredicate(format: "code == %@", currencyCode)
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    fetchRequest.predicate = predicate
    
    do {
      let fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [CurrencyDashboard]
      if let entityToDelete = fetchedEntities.first {
        reorderChosenCurrencyFromPosition(entityToDelete.orderPosition!.integerValue)
        managedContext.deleteObject(entityToDelete)
      }
    } catch {
      print("Failed to fetch the record for delete!")
    }
    
    do {
      try managedContext.save()
    } catch {
      print("Failed to save deleted record")
    }
    
    return (true, "")
  }
  
  // Update the order position of the records behind deleted record
  func reorderChosenCurrencyFromPosition(var position: Int) {
    let managedContext = appDelegate.managedObjectContext
    
    let predicate = NSPredicate(format: "orderPosition > \(position)")
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    fetchRequest.predicate = predicate
    
    do {
      let fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [CurrencyDashboard]
      for currency in fetchedEntities {
        currency.orderPosition = position++
      }
    } catch {
      print("Failed to fetch the record for update!")
    }
    
    do {
      try managedContext.save()
    } catch {
      print("Failed to save updated record")
    }
  }
  
  // Update the order of currency at specific postion and currency at the first position
  func swapChosenCurrencyWithFirstAtPosition(position: Int) {
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    let sortDescriptor = NSSortDescriptor(key: "orderPosition", ascending: true )
    fetchRequest.sortDescriptors = [ sortDescriptor ]
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let currencies = results as! [CurrencyDashboard]
      
      let swapToCurrency = currencies[0]
      let swapFromCurrency = currencies[position]
      
      swapFromCurrency.setValue(1, forKeyPath: "orderPosition")
      swapToCurrency.setValue(position + 1, forKeyPath: "orderPosition")
    } catch {
      print("Could not fetch all the currency dashboard records for swapping!")
    }
    
    do {
      try managedContext.save()
    } catch {
      print("Failed to save swap record")
    }
  }
  
  // Check currency is exist in currency dashboard
  func chosenCurrencyIsExistWithCurrencyCode(currencyCode: String) -> Bool {
    let managedContext = appDelegate.managedObjectContext
    
    let predicate = NSPredicate(format: "code == %@", currencyCode)
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    fetchRequest.predicate = predicate
    
    let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
    
    if count > 0 {
      return true
    }
    
    return false
  }
  
  // Get all the records from Entity "CurrencyDashboard"
  func getAllChosenCurrencies() -> [CurrencyDashboard]? {
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    let sortDescriptor = NSSortDescriptor(key: "orderPosition", ascending: true )
    fetchRequest.sortDescriptors = [ sortDescriptor ]
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let currencies = results as! [CurrencyDashboard]
      
      return currencies
    } catch {
      print("Could not fetch all the currency dashboard records!")
    }
    return nil
  }
  
  func saveCurrencyAmountWithCurrencyCode(currencyCode: String, amount: String) {
    let managedContext = appDelegate.managedObjectContext
    
    let predicate = NSPredicate(format: "code == %@", currencyCode)
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    fetchRequest.predicate = predicate
    
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      let currency = results[0] as! CurrencyDashboard
      
      currency.amount = amount
    } catch {
      print("Could not fetch all the currency dashboard records!")
    }
    
    do {
      try managedContext.save()
    } catch {
      print("Failed to save currency dashboard record with amount")
    }
  }
  
  // Get all the counts of the records from Entity "CurrencyDashboard"
  func getAllChosenCurrenciesCount() -> Int {
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "CurrencyDashboard")
    
    let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
    
    return count
  }
  
  // MARK: JSON
  
  // Read data from json file
  func getCurrenciesDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let filePath = NSBundle.mainBundle().pathForResource("currencies", ofType:"json")
      let data = try! NSData(contentsOfFile:filePath!,
        options: NSDataReadingOptions.DataReadingUncached)
      success(data: data)
    })
  }
}
