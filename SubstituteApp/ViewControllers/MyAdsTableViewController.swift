//
//  MyAdsTableViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase

// Some of this view controller code is similar to Superhero Labs in Week 4

class MyAdsTableViewController: UITableViewController, DatabaseListener{
    
    // As we are only focused on the user's ads we set the listener to user
    var listenerType: ListenerType = .user
    
    // Function used to add adverts to the table view when created
    func addAdvert(_ advert: Advertisement) {
        adverts.append(advert)
        tableView.insertRows(at: [IndexPath(row:adverts.count - 1, section: 0)], with: .fade)
    }
    
    
    var adverts: [Advertisement] = []
    weak var databaseController: DatabaseProtocol?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Setting the title to the custom font
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 38)!]
        
        
        // Setting the small title to the custom font
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 25)!]

        // Setting the colour of the navigation bar items to orange
        navigationController?.navigationBar.tintColor = UIColor.systemOrange
        navigationItem.title = "My Ads"
  
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
    }
    
    
    // MARK: - Database Listeners
    func onUserChange(change: DatabaseChange, user: User) {
        // When a new advert is added to teh user, this is then called
        adverts = user.advertisements
        tableView.reloadData()
    }
    
    func onAdvertChange(change: DatabaseChange, adverts: [Advertisement]) {
        // Do nothing as there is no reason to call it
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return adverts.count
    }

    // Reusing the "ResultsTableViewCell" as it would bring consistency in terms of design
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myAdCell", for: indexPath) as! ResultsTableViewCell

        // Setting up each cell with advertisement details
        let advert = adverts[indexPath.row]
        cell.titleLabel?.text = advert.title
        cell.detailsLabel.text = advert.details
        cell.detailsLabel.text = advert.details
        cell.dateLabel?.textColor = .secondaryLabel
        cell.dateLabel?.text = advert.date
        cell.iconImageView?.image = UIImage(named: advert.sport)
        

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Allows the deletion of advertisements my swiping. Also gives the user feedback on whether they want to delete the advert
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let advert = adverts[indexPath.row]
            // Delete the row from the data source
            let alertController = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this ad? This cannot be reversed.", preferredStyle: UIAlertController.Style.alert)
            
            
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { (_) in
                // Removing the advertisement from teh user
                self.databaseController?.removeAdvertFromUser(advert: advert)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)

        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "oldAdSegue" {
            let destination = segue.destination as! EditAdTableViewController
            // Passes the selected advert to the next view controller
            destination.advert = adverts[tableView.indexPathForSelectedRow!.row]
            destination.existingAd = true
        }
        
        
        
    }
    

}
