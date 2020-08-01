//
//  DatabaseProtocol.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 7/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    
    case remove
    
    case update
}

enum ListenerType {
    case user
    
    case advert
    
    case all
    
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onUserChange(change: DatabaseChange, user: User)
    
    func onAdvertChange(change: DatabaseChange, adverts: [Advertisement])

}

protocol DatabaseProtocol: AnyObject {
    var currentUser: User {get}
    
    func cleanup()

    // Used as a way to initiate the log in process
    func userLogIn()

    // Adds a new channel for firebase with the user identity (UID)
    func addChannel(channel: MessageChannel, user: User)
    
    // Adds the above channel to a user
    func addChannelToUser(channel: MessageChannel, user: User) -> Bool
    
    // Used to retrieve user information
    func retrieveUser(uid: String, completion: @escaping (User) -> Void)
    
    // Used to query the firebase to get relevant adverts
    func retrieveAdverts(sport: String, completion: @escaping ([Advertisement]) -> Void)
    
    // Adds advertisements to Firebase
    func addAdvert(advert: Advertisement) -> Advertisement
    
    // Used for making changes to a user's advertisements
    func editAdvert(advert: Advertisement) -> Advertisement
    
    // When the user registers, this is called ot create an account for them
    func addUser(userName: String, email: String, phoneNumber: String, location: String) -> User
    
    // Used for making changes to a user
    func editUser(user: User) -> User

    // Adds the advertisement the user has created to their Firebase Document
    func addAdvertToUser(advert: Advertisement, user: User) -> Bool
    
    // Used when the user deletes an advertisement
    func deleteAdvert(advert: Advertisement)
    
    // After deleting the advert from FIrebase, this is used to delete the advert reference from the user document
    func removeAdvertFromUser(advert: Advertisement)
    
    // Used for listening to changes in the database
    func addListener(listener: DatabaseListener)
    
    // Used to remove listeners
    func removeListener(listener: DatabaseListener)
    
}
