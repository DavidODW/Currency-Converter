//
//  CurrencyCore+CoreDataProperties.swift
//  Currency Converter
//
//  Created by David ODW on 26/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CurrencyCore {

    @NSManaged var code: String?
    @NSManaged var majorContinent: String?
    @NSManaged var majorCountry: String?
    @NSManaged var name: String?
    @NSManaged var symbol: String?
    @NSManaged var countries: NSSet?

}
