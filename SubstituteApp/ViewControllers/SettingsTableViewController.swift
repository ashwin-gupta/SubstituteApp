//
//  SettingsTableViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 28/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    let SECTION_PROFILE = 0
    
    let SECTION_ACK = 1
    
    // Function used to log out of the application
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
        
        self.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the title to a custom font
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 38)!]
        
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 25)!]

        // Setting the navigtation items to orange
        navigationController?.navigationBar.tintColor = UIColor.systemOrange
        navigationItem.title = "Settings"
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 2 for profile, acknowledgements
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 1 row in each section
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        
        let ackCell = tableView.dequeueReusableCell(withIdentifier: "ackCell", for: indexPath)
        
        // Setting a default value for title field
        if indexPath.section == SECTION_PROFILE {
            
            // Setting up the profile cell
            profileCell.textLabel?.text = "Edit Profile"
            

            return profileCell

        } else {

            // Set up the name of acknowledgements cell
            ackCell.textLabel?.text = "Acknowledgements"

            return ackCell
        }
    }
    

    // This sets the headers to their respective names
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_PROFILE:
            return "Profile:" // This will appear above the cell
            
        case SECTION_ACK:
            return "Other:"
            
        default:
            return nil
        }
     }

}
