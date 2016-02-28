//
//  CurrencyRate.swift
//  Currency Converter
//
//  Created by David ODW on 26/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import Foundation
import Gloss

public struct CurrencyRate: Decodable {
  public let quotes: JSON
  
  public init?(json: JSON) {
    guard let quotes: JSON = "quotes" <~~ json
      else { return nil }
    self.quotes = quotes
  }
}