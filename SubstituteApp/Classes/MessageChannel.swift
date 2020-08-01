//
//  MessageChannel.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class MessageChannel: NSObject {
    
    var id: String?
    var name: String
    var users: [String]
    
    
    init(id: String, name: String, users: [String]) {
        self.id = id
        self.name = name
        self.users = users
        
    }

}
