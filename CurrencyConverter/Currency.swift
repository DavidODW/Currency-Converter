//
//  Currency.swift
//  Currency Converter
//
//  Created by David ODW on 16/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import Foundation
import Gloss

public struct Currency: Decodable {
  public let code: String!
  public let name: String!
  public let symbol: String!
  public let major_country: String?
  public let major_continent: String?
  public let country: [Country]?
  
  public init?(json: JSON) {
    code = "code" <~~ json
    name = "name" <~~ json
    symbol = "symbol" <~~ json
    
    guard let country: [Country] = "country" <~~ json,
      major_country: String = "major_country" <~~ json,
      major_continent: String = "major_continent" <~~ json
      else { return nil }
    self.country = country
    self.major_country = major_country
    self.major_continent = major_continent
  }
}
