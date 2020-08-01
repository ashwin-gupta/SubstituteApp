//
//  ProfileAdvertViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 16/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileAdvertViewController: UIViewController {
    
    // Outlets from Storyboard
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileEmail: UILabel!
    
    @IBOutlet weak var profileNumber: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    var advert: Advertisement?
    var userProfile: User?
    var users: [String] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rounding out the edges of the message button
        messageButton.layer.cornerRadius = 12
        

        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // CHecking that userProfile is not nil just in case
        guard let userProfile = userProfile else {
            fatalError("Found nil unwrapping user profile")
        }
        
        // Setting the details
        profileName.text = userProfile.name
        profileEmail.text = userProfile.email
        profileNumber.text = userProfile.phoneNumber
        
        
    }
    

    @IBAction func messageUser(_ sender: Any) {
        
        // Checking that advert title is not nil
        guard let name = advert?.title else {
            fatalError("Found nil when unwrapping name")
        }

        guard let currentUser = Auth.auth().currentUser?.uid else {
            fatalError("Could not retrieve user id")
        }
        
        let user = self.userProfile!.uid
        
        // Disables users from making a chat with themselves
        if currentUser == user {
            displayErrorMessage("This is your own advertisement")
            return
            
        }
        
        // Adding both user ids to an array which will be used to find the channels
        users.append(currentUser)
        users.append(user!)
        
        // id is set to "" as this will be set when the document is created
        let channel = MessageChannel(id: "", name: name, users: users)
        
        // adding a channel to the user document
        databaseController?.addChannel(channel: channel, user: userProfile!)
        
        // Perform a segue to send the user to the messages table view
        self.performSegue(withIdentifier: "profileMessageSegue", sender: nil)

    }
    
    // Used to display error messages if the user 
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
