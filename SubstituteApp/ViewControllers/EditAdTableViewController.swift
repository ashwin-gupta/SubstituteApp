//
//  EditAdTableViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class EditAdTableViewController: UITableViewController, AdvertChangedDelegate {
    
    // These are defined to help with setting up sections below
    let SECTION_TITLE = 0
    let SECTION_DETAIL = 1
    let SECTION_SPORT = 2
    let SECTION_LOCATION = 3
    let SECTION_DATE = 4
    
    let CELL_TITLE = "editTitleCell"
    let CELL_DETAIL = "editDetailCell"
    let CELL_SPORT = "editSportCell"
    let CELL_LOCATION = "editLocationCell"
    let CELL_DATE = "dateCell"
    
    
    var advertChanged: Bool = false
    var existingAd: Bool = false
    
    var advert = Advertisement()
    var currentUser: User?
    
    weak var databaseController: DatabaseProtocol?
    

    
    func advertChanged(_ editedAdvert: Advertisement) {
        advert = editedAdvert
        advertChanged = true
        
        // Reloading the tableview to display the changed information
        tableView.reloadData()
        
        // Setting the title of the view to the title of the advertisement
        navigationItem.title = advert.title
    }
    

    
    @IBAction func saveAdvert(_ sender: Any) {

        // Adding a new advertisement document through Firebase Controller
        if existingAd == false && advertChanged == true {

            let _ = databaseController?.addAdvert(advert: advert)
            
            navigationController?.popViewController(animated: true)
        
        // Editing an existing advertisement document through Firebase Controller
        } else if existingAd == true {
            let _ = databaseController?.editAdvert(advert: advert)
            navigationController?.popViewController(animated: true)
        }

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the navigation title to "New Ad" if the user is making a new ad
        if existingAd == false {
            
            // Initialising a new object of Advertisement
            advert = Advertisement()
            navigationItem.title = "New Ad"
            
        } else {
            
            // If the advertisement is not new, set the navigation title to the title of the ad
            navigationItem.title = advert.title
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 5 sections for each type of cell
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // We will only ever have one row in each section
        return 1
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Setting up a date formatted, so that new advertisements have the right format for dates
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyy"
        
        let titleCell = tableView.dequeueReusableCell(withIdentifier: CELL_TITLE, for: indexPath)
        
        let detailCell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath)
        
        let sportCell = tableView.dequeueReusableCell(withIdentifier: CELL_SPORT, for: indexPath)
        
        let locationCell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        
        let dateCell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE, for: indexPath)
        

        // Setting a default value for title field
        if indexPath.section == SECTION_TITLE && advert.title == "" {

            // Default set up for new ads
            titleCell.textLabel?.textColor = .secondaryLabel
            titleCell.textLabel?.text = "Enter title for advertisement"

            return titleCell

        } else if indexPath.section == SECTION_TITLE && advert.title != "" {

            // Set up the name of the prexisting ad here
            titleCell.textLabel?.textColor = .label
            titleCell.textLabel?.text = advert.title

            return titleCell
        }

        if indexPath.section == SECTION_DETAIL && advert.details == "" {

            detailCell.textLabel?.textColor = .secondaryLabel
            
            detailCell.textLabel?.text = "Enter details for your ad"

            return detailCell

        } else if indexPath.section == SECTION_DETAIL && advert.details != "" {

            // Set up the details of the prexisting ad here
            detailCell.textLabel?.numberOfLines = 0
            detailCell.textLabel?.text = advert.details

            return detailCell
        }

        if indexPath.section == SECTION_SPORT && advert.sport == "" {

            sportCell.textLabel?.textColor = .secondaryLabel
            sportCell.textLabel?.text = "Select your sport"

            return sportCell
            
        } else if indexPath.section == SECTION_SPORT && advert.sport != "" {

            // Set the sport of the prexisting sport
            sportCell.textLabel?.text = advert.sport

            return sportCell
        }

        if indexPath.section == SECTION_LOCATION && advert.location == "" {

            locationCell.textLabel?.textColor = .secondaryLabel
            locationCell.textLabel?.text = "Select your post code"

            return locationCell
        } else if indexPath.section == SECTION_LOCATION && advert.location != "" {

            // Set up the location of the prexisting ad
            locationCell.textLabel?.text = advert.location
            
            return locationCell

        }
        
        if advert.date == "" {
            
            let todayDate = formatter.string(from: date)
            dateCell.textLabel?.textColor = .secondaryLabel
            
            dateCell.textLabel?.text = todayDate
            dateCell.selectionStyle = .none
            
            // For new adverts, set the date of creation to today
            advert.date = todayDate
            
            return dateCell
        
        } else {
            
            // Configure the date to the user upload date
            dateCell.textLabel?.textColor = .secondaryLabel
            dateCell.textLabel?.text = advert.date
            dateCell.selectionStyle = .none
            
            return dateCell
        }
        
    }
    
    // This sets the headers to their respective names
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_TITLE:
            return "Title:" // This will appear above the cell
            
        case SECTION_DETAIL:
            return "Details:"
            
        case SECTION_SPORT:
            return "Sport:"
            
        case SECTION_LOCATION:
            return "Location:"
            
        case SECTION_DATE:
            return "Date:"

        default:
            return nil
        }
     }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Passing the advertisement and delegate to the Edit View Controllers
        if segue.identifier == "editTitleSegue" {
            let destination = segue.destination as! EditTitleViewController
            destination.advert = advert
            destination.delegate = self
            
        } else if segue.identifier == "editDetailSegue" {
            let destination = segue.destination as! EditDetailsViewController
            destination.advert = advert
            destination.delegate = self
            
        } else if segue.identifier == "editSportsSegue" {
            let destination = segue.destination as! EditSportsViewController
            destination.advert = advert
            destination.delegate = self
            
        } else if segue.identifier == "editLocationSegue" {
            let destination = segue.destination as! EditLocationViewController
            destination.advert = advert
            destination.delegate = self
        }
    }
    

}
