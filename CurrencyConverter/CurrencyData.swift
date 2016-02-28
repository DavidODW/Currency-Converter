//
//  Currencies.swift
//  Currency Converter
//
//  Created by David ODW on 16/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import Foundation
import Gloss

public struct CurrencyData: Decodable {
  public let id: String!
  public let currency: [Currency]?
  
  public init?(json: JSON) {
    id = "id" <~~ json
    currency = "currency" <~~ json
  }
}
