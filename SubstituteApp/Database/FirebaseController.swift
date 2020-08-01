//
//  FirebaseController.swift
//
//  Created by Ashwin Gupta on 7/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/*
 This Firebase Controller is a combination of labs: W04, W09, W10
 
 */

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import UserNotifications



class FirebaseController: NSObject, DatabaseProtocol, UNUserNotificationCenterDelegate {


    var userID: String?
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var advertRef: CollectionReference?
    var userRef: CollectionReference?
    var channelsRef: CollectionReference?
    var advertList: [Advertisement]
    var currentUser: User
    // This instance of a user is used to get the
    var retrieveUser: User?
    var usersCollectionRef: CollectionReference?
    var logInSnapshot: QueryDocumentSnapshot?
    var databaseListener: ListenerRegistration?
    var channels: [MessageChannel]
    
    // These will be used for querying the database and finding the appropriate information
    var queryAdverts = [Advertisement]()
    var retrieveAdvert = Advertisement()
    var notificationGranted = false
    
    let center = UNUserNotificationCenter.current()
    
    override init() {
        FirebaseApp.configure()
        
        // Initialising the variables
        authController = Auth.auth()
        database = Firestore.firestore()
        advertList = [Advertisement]()
        currentUser = User()
        retrieveUser = User()
        channels = [MessageChannel]()

        super.init()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
            
            if granted == true {
                self.notificationGranted = granted
                print("User granted permission")
            } else {
                print("User did not grant permission")
            }
        }

    }
    
    // MARK: - Setup code for Firestore Listeners
    func setUpAdvertListener() {
        advertRef = database.collection("adverts")
        advertRef?.addSnapshotListener{ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self.parseAdvertSnapshot(snapshot: querySnapshot)
            
            // Setting up channel listener as the user listener depends on the channel information
            self.setUpChannelListener()
            
            // Team listener references heroes, so we need to do it after we have parsed heroes
            self.setUpUserListener()
        }
    }
    
    func setUpUserListener() {
        
        userRef = database.collection("users")
        userRef?.whereField("uid", isEqualTo: userID!).addSnapshotListener { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot,
                let userSnapshot = querySnapshot.documents.first else {
                    print("Error fetching user: \(error)")
                    return
                    
            }
            
            self.parseUserSnapshot(snapshot: userSnapshot)
            
            
        }
        
    }
    
    // This is used to get the user's channels and listen to any changes to them
    func setUpChannelListener() {
        userID = authController.currentUser?.uid
        channelsRef = database.collection("channels")
        channelsRef?.whereField("users", arrayContains: userID!).addSnapshotListener {
            (querySnapshot, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.channels.removeAll()
            self.parseChannelSnapshot(snapshot: querySnapshot!)
        }
    }
    
    
    // MARK: - Parse Functions for Firebase Firestore Responses
    func parseAdvertSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let advertID = change.document.documentID
            print(advertID)
            
            var parsedAdvert: Advertisement?
            
            do {
                parsedAdvert = try change.document.data(as: Advertisement.self)
            } catch {
                print("Unable to decode advertisement. Is the advertisement malformed?")
                return
            }
            
            guard let advert = parsedAdvert else {
                print("Document doesn't exist")
                return
            }
            
            // Checks if an advert has been added
            advert.id = advertID
            if change.type == .added {
                advertList.append(advert)
                
                // Used for sending a notification to the user
                // Checks if it is in the same area as the user
                if advert.location == currentUser.location && notificationGranted == true {
                    
                    // Using local notification as push notifications require a Paid Apple Developer Account
                    let content = UNMutableNotificationContent()
                    content.subtitle = "New request for \(advert.sport) near you!"
                    content.title = "Substitute"
                    content.body = "Tap to check it out!"
                    
                    // Trigger which says how long until this notification is shown in the notification center
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                    
                    // Sending the request to notification center
                    let request = UNNotificationRequest(identifier: "substitute.app.uid", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    center.add(request) { (error) in
                        // check for errors
                    }
                    
                }
                
            }
            // Checks the change type
            else if change.type == .modified {
                let index = getAdvertIndexByID(advertID)!
                advertList[index] = advert
            }
            else if change.type == .removed {
                if let index = getAdvertIndexByID(advertID) {
                    advertList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.advert || listener.listenerType == ListenerType.all {
                listener.onAdvertChange(change: .update, adverts: advertList)
            }
        }
    }
    
    // Converts firebase document into a user object
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) {
        currentUser = User()
        
        // We are getting the data from the snapshot and converting it into the user object
        currentUser.name = snapshot.data()["name"] as! String
        currentUser.email = snapshot.data()["email"] as! String
        currentUser.phoneNumber = snapshot.data()["phoneNumber"] as! String
        currentUser.uid = snapshot.data()["uid"] as? String
        currentUser.id = snapshot.documentID
        currentUser.location = snapshot.data()["location"] as! String
        
        // Setting Default Values for the application
        let defaults = UserDefaults.standard
        defaults.set(currentUser.name, forKey: "name")
        
        defaults.set(currentUser.location, forKey: "location")
        
        defaults.set(currentUser.email, forKey: "email")
        
        defaults.set(currentUser.id, forKey: "id")
        
        defaults.set(currentUser.phoneNumber, forKey: "number")
        
        defaults.set(currentUser.uid, forKey: "uid")
        
        if let channelsReferences = snapshot.data()["channels"] as? [DocumentReference] {
            
            // Cycling through the list of channels
            for channel in channelsReferences {
                if let channel = getChannelByID(channel.documentID) {
                    currentUser.channels.append(channel)
                }
            }
        }
        
        if let advertReferences = snapshot.data()["advertisements"] as? [DocumentReference] {
            
        // If the document has a "advertisements" field, add advertisements
            for reference in advertReferences {
                if let advert = getAdvertByID(reference.documentID) {
                    currentUser.advertisements.append(advert)
                }
            }
            
            
            
        }
        
        // Invoking listeners when there are changes
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                listener.onUserChange(change: .update, user: currentUser)
                
            }
        }

    }
    
    // Converting channel Firebase document into an object
    func parseChannelSnapshot(snapshot: QuerySnapshot) {
        snapshot.documents.forEach({snapshot
            in
            let id = snapshot.documentID
            let name = snapshot["name"] as! String
            let users = snapshot["users"] as! [String]
            let channel = MessageChannel(id: id, name: name, users: users)
            self.channels.append(channel)
            
        })
    }
    
    // MARK: - Utility Functions
    func getAdvertIndexByID(_ id: String) -> Int? {
        if let advert = getAdvertByID(id) {
            return advertList.firstIndex(of: advert)
        }

        return nil
    }
    
    func getAdvertByID(_ id: String) -> Advertisement? {
        for advert in advertList {
            if advert.id == id {
                return advert
            }
        }
        
        return nil
    }
    
    func getChannelIndexByID(_ id: String) -> Int? {
        if let channel = getChannelByID(id) {
            return channels.firstIndex(of: channel)
        }

        return nil
    }
    
    func getChannelByID(_ id: String) -> MessageChannel? {
        for channel in channels {
            if channel.id == id {
                return channel
            }
        }
        
        return nil
    }
    
    
    // MARK: - Required Database Functions
    func cleanup() {
    }
    
    func userLogIn(){
        // Begin the log in process
        self.setUpAdvertListener()

    }
    
    // Adds channel to Firebase
    func addChannel(channel: MessageChannel, user: User) {
        
        let name = channel.name
        let users = channel.users
        
        do {
            if let channelsRef = try channelsRef?.addDocument(data : ["name" : name, "users" : users]) {
                
                
                channel.id = channelsRef.documentID
                
                let messageRef = channelsRef.collection("messages")
                
                messageRef.addDocument(data: ["first" : "first"])
                
                // Checking for errors
                if addChannelToUser(channel: channel, user: user) {
                    print("Channel added succesfully")
                } else {
                    print("Channel was not added successfully")
                }
                
                if addChannelToUser(channel: channel, user: currentUser) {
                    print("Channel added succesfully")
                } else {
                    print("Channel was not added successfully")
                }

            } 
        }
        
 
    }
    
    // Adding a channel to the user's document
    func addChannelToUser(channel: MessageChannel, user: User) -> Bool {
        
        guard let channelID = channel.id, let userID = user.id else {
            return false
        }

        // Adds the channel document reference into a user's array of channels
        if let newChannelRef = channelsRef?.document(channelID) {
            userRef?.document(userID).updateData(["channels" : FieldValue.arrayUnion([newChannelRef])]
            )
        }

        return true

    }
    
    // Creates an advert document in Firebase
    func addAdvert(advert: Advertisement) -> Advertisement {
        
        // Force unwrap uid as each advertisement will have a UID, this has been set from VC
        advert.userID = currentUser.uid!
        
        do {
            if let advertRef = try advertRef?.addDocument(from: advert) {
                
                // When the document is successfully added then
                // Get the id of the advert and then pass the addAdvertToUser
                advert.id = advertRef.documentID
                let _ = addAdvertToUser(advert: advert, user: currentUser)

            }
            
        } catch {
            print("Failed to serialize advertisement")
        }
        
        return advert
        
    }
    
    // Function to edit a user's advertisement
    func editAdvert(advert: Advertisement) -> Advertisement {
        
        
        let advertID = advert.id
        let title = advert.title
        let date = advert.date
        let sport = advert.sport
        let location = advert.location
        let details = advert.details
        
        // Don't change uid or id as they remain the same
        advertRef?.document(advertID!).updateData(["title" : title, "date" : date, "sport" : sport, "location" : location, "details" : details], completion: { (error) in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Advert successfully updated")
            }
        })
        
        return advert
    }
    
    // Creates a user in Firebase, used when registering a user
    func addUser(userName: String, email: String, phoneNumber: String, location: String) -> User {
        
        // Setting the data from the passed user information
        let user = User()
        usersCollectionRef = database.collection("users")
        user.name = userName
        user.phoneNumber = phoneNumber
        user.email = email
        user.location = location
        user.uid = authController.currentUser?.uid
        
        
        if let usersCollectionRef = usersCollectionRef?.addDocument(data: ["name" : userName, "uid" : user.uid! ,"phoneNumber" : phoneNumber, "email" : email, "location" : location, "advertisements" : [], "channels" : []]) {
            user.id = usersCollectionRef.documentID
            print(user.id!)
        }
        
        return user
    }
    
    // Editing user details
    func editUser(user: User) -> User {
        let phone = user.phoneNumber
        let email = user.email
        let name = user.name
        let location = user.location
        // We use the current user as we know this is who is making the changes
        let docID = currentUser.id
        
        // Passing a update to Firebase
        userRef?.document(docID!).updateData(["name" : name, "phoneNumber" : phone, "email" : email, "location" : location], completion: { (error) in
            if let error = error {
                print("Error updating user information")
            } else {
                print("User information successfully updated")
            }
        })
        
        return user
    }
    
    // Adding advertisements to the user's document into a user's array of advertisements
    func addAdvertToUser(advert: Advertisement, user: User) -> Bool {

        guard let advertID = advert.id, let userID = user.id else {
            return false
        }
        
        if let newAdvertRef = advertRef?.document(advertID) {
            userRef?.document(userID).updateData( ["advertisements" : FieldValue.arrayUnion([newAdvertRef])]
            )
        }
        
        return true
        
    }
    
    // Deleting adverts if the user's chooses to do so
    func deleteAdvert(advert: Advertisement) {
        if let advertID = advert.id {
            advertRef?.document(advertID).delete()
        }
    }
    
    // When the user deletes an advertisement, the reference must be removed from the user's document as well
    func removeAdvertFromUser(advert: Advertisement) {
        if currentUser.advertisements.contains(advert), let userID = currentUser.id, let advertID = advert.id {
            if let removedRef = advertRef?.document(advertID) {
                userRef?.document(userID).updateData(["advertisements" : FieldValue.arrayRemove([removedRef])]
                )
                
                // Deletes the advert from advert collection
                deleteAdvert(advert: advert)
                
            }
        }
    }
    
    // Cehck for changes in adverts or users
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
            
            listener.onUserChange(change: .update, user: currentUser)
            
        }
        
        if listener.listenerType == ListenerType.advert || listener.listenerType == ListenerType.all {
            listener.onAdvertChange(change: .update, adverts: advertList)
            
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // Type of completion argument is a block that gets passed the user and returns void
    func retrieveUser(uid: String, completion: @escaping (User) -> Void) {
        let reference = database.collection("users")
        
        
        reference.whereField("uid", isEqualTo: uid).addSnapshotListener{ (querySnapshot, error) in
        
            
            guard let querySnapshot = querySnapshot,
                    let userSnapshot = querySnapshot.documents.first else {
                        print("Error fetching user: \(error)")
                        return
                }
                
            // Setting the data of the user being retrieved
            // Force unwrapping as a user might not need to retrieve a user
            self.retrieveUser!.id = userSnapshot.documentID
            self.retrieveUser!.name = userSnapshot.data()["name"] as! String
            self.retrieveUser!.email = userSnapshot.data()["email"] as! String
            self.retrieveUser!.uid = userSnapshot.data()["uid"] as? String
            self.retrieveUser!.phoneNumber = userSnapshot.data()["phoneNumber"] as! String
            self.retrieveUser?.location = userSnapshot.data()["location"] as! String
            // Piece of code that does something with the user
            // Block of code provided for this method
            
            // Executing the completion handler
            completion(self.retrieveUser!)
                
        }
        
    }
    
    // Used to retrieve advertisements that the user has specified
    func retrieveAdverts(sport: String, completion: @escaping ([Advertisement]) -> Void) {
        let reference = database.collection("adverts")

        // Finding all instances of an ad that has the same sport as the user selected
        // Only finding ads based on sport as we allow the user to filter by postcode
        reference.whereField("sport", isEqualTo: sport).addSnapshotListener{ (querySnapshot, error) in
        
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    // Converting document data to an advert object
                    self.retrieveAdvert.title = document.data()["title"] as! String
                    self.retrieveAdvert.details = document.data()["details"] as! String
                    self.retrieveAdvert.date = document.data()["date"] as! String
                    self.retrieveAdvert.location = document.data()["location"] as! String
                    self.retrieveAdvert.userID = document.data()["userID"] as! String
                    self.retrieveAdvert.sport = document.data()["sport"] as! String
                    
                    // Adding the advert to the advert list
                    self.queryAdverts.append(self.retrieveAdvert)
                }
            }
            // Executing the completion handler
            completion(self.queryAdverts)
            
            // This empties out the array after the completion handler so there is no remaining adverts in query adverts
            // Resets itself for another query
            self.queryAdverts = []
                
        }
        
    }
    
    
}
