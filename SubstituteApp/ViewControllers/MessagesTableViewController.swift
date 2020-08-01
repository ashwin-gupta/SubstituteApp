//
//  MessagesTableViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 18/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class MessagesTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = .user
    
    
    let MESSAGE_SEGUE = "messageContactSegue"
    let MESSAGE_CELL = "messagesCell"
    var currentSender: Sender?
    var channels: [MessageChannel] = []
    

    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        
        // Setting up access to the delegate through database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let user = databaseController?.currentUser
        
        let uid = Auth.auth().currentUser?.uid
        
        // Setting the sender to the current by getting user information
        currentSender = Sender(id: uid!, name: user!.name)
  
        // Setting the colour of the interactive buttons
        navigationController?.navigationBar.tintColor = UIColor.systemOrange

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting the title to a custom font
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 38)!]
        
        
        // Setting the small title to a custom font
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 25)!]

        navigationItem.title = "Messages"
        
        // Shows the tab bar controller once the view returns
        self.tabBarController?.tabBar.isHidden = false
        databaseController?.addListener(listener: self)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // Number of rows is = number of channels
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MESSAGE_CELL, for: indexPath)

        
        // Setting the name of the channel cell
        let channel = channels[indexPath.row]
        cell.textLabel?.text = channel.name
        return cell


    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var channel = MessageChannel(id: "", name: "", users: [])
        channel = channels[indexPath.row]
        
        performSegue(withIdentifier: MESSAGE_SEGUE, sender: channel)
    }


    // MARK: - Database Listeners
    func onUserChange(change: DatabaseChange, user: User) {
        // Updating the channels list when there is a change in the channels
        channels = user.channels

        tableView.reloadData()
    }
    
    func onAdvertChange(change: DatabaseChange, adverts: [Advertisement]) {
        // Do nothing as no changes to adverts
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == MESSAGE_SEGUE {
            
            
            let channel = sender as! MessageChannel
            
            let destination = segue.destination as! ChattingViewController
            
            // Hides the tab bar in the chatting vc
            destination.hidesBottomBarWhenPushed = true
            destination.sender = currentSender
            destination.currentChannel = channel
        }
        
    }


}
