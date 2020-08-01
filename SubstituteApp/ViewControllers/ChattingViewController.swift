//
//  ChattingViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 25/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

// This View Controller is from FIT3178 Week 9 Messaging Lab

class ChattingViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate, MessageCellDelegate {
    
    // sender and channel information
    var sender: Sender?
    var currentChannel: MessageChannel?
    
    var messagesList = [SendMessage]()
    
    var channelRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputBar.delegate = self
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.sendButton.setTitleColor(.systemOrange, for: .normal)

        // Setting data source and delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        // Setting the channel
        if currentChannel != nil {
            let database = Firestore.firestore()
            channelRef = database.collection("channels").document(currentChannel!.id!).collection("messages")
            
            navigationItem.title = "\(currentChannel!.name)"
            
            
        }
        
        
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Ordering the messages by time
        databaseListener = channelRef?.order(by: "time").addSnapshotListener { (querySnapshot, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // Getting the messages from teh snapshot and converting them into a SendMessage object
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let snapshot = change.document
                    
                    let id = snapshot.documentID
                    let senderID = snapshot["senderID"] as! String
                    let senderName = snapshot["senderName"] as! String
                    
                    let messageText = snapshot["text"] as! String
                    
                    let sentTimestamp = snapshot["time"] as! Timestamp
                    
                    let sentDate = sentTimestamp.dateValue()
                    
                    let sender = Sender(id: senderID, name: senderName)
                    
                    let message = SendMessage(sender: sender, messageId: id, sentDate: sentDate, message: messageText)
                    
                    self.messagesList.append(message)
                    
                    self.messagesCollectionView.insertSections([self.messagesList.count - 1])
                    
                }
                
            })
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        databaseListener?.remove()
        
    }
    

    // Messages Data Source
    
    func currentSender() -> SenderType {
        guard let sender = sender else {
            return Sender(id: "", name: "")
        }
        
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messagesList.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes:  [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    //MARK: - Message Input Bar Delegate Functions
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty {
            return
        }
        
        // When the user presses send a new document is added to the collection
        channelRef?.addDocument(data: [
            "senderID" : sender!.senderId,
            "senderName" : sender!.displayName,
            "text" : text,
            "time" : Timestamp(date: Date.init())
        ])
        
        // Setting the input bar back to empty
        inputBar.inputTextView.text = ""
        
    }
    
    // MARK: - MessagesLayoutDelegate
    
    // Setting the layout of the message bubbles
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
        
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
        
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    
}
