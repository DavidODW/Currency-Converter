//
//  CurrencyDashboard+CoreDataProperties.swift
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

extension CurrencyDashboard {

    @NSManaged var amount: String?
    @NSManaged var code: String?
    @NSManaged var orderPosition: NSNumber?

}
