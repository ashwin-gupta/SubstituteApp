//
//  SendMessage.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MessageKit

class SendMessage: MessageType {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }

}
