//
//  User.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 6/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

class User: NSObject {

    var id: String?
    var uid: String?
    var name: String = ""
    var advertisements: [Advertisement] = []
    var channels: [MessageChannel] = []
    var email: String = ""
    var phoneNumber: String = ""
    var location: String = ""

}
