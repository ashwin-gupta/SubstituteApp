//
//  Sender.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MessageKit

class Sender: SenderType {
    
    var senderId: String
    var displayName: String
    
    init(id: String, name: String) {
        senderId = id
        displayName = name
    }

}
