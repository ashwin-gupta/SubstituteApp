//
//  Advertisement.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 6/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class Advertisement: NSObject, Codable {
    var id: String?
    var userID: String = ""
    var title: String = ""
    var details: String = ""
    var sport: String = ""
    var location: String = ""
    var date: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        
        case title
        
        case userID
        
        case details
        
        case sport
        
        case location
        
        case date
    }
    
}
