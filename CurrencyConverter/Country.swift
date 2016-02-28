//
//  Country.swift
//  Currency Converter
//
//  Created by David ODW on 17/02/2016.
//  Copyright © 2016 David Ong. All rights reserved.
//

import Foundation
import Gloss

public struct Country: Decodable {
  public let name: String
  public let code: String
  public let continent: String
  public let continentCode: String
  
  public init?(json: JSON) {
    guard let name: String = "name" <~~ json,
      code: String = "code" <~~ json,
      continent: String = "continent" <~~ json,
      continentCode: String = "continent_code" <~~ json
      else { return nil }
    
    self.name = name
    self.code = code
    self.continent = continent
    self.continentCode = continentCode
  }
}