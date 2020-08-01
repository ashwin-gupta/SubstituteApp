//
//  ResultsTableViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 18/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController, UISearchResultsUpdating {

    
    var listenerType: ListenerType = .all
    
    let SECTION_ADVERT = 0
    let SECTION_INFO = 1
    
    var sport: String = ""
    var location: String = ""
    var searchedAdverts: [Advertisement] = []
    var allAdverts: [Advertisement] = []
 
    // This will be used to know whether the user has moved to see the advert or not
    var displayAdFlag = false
    
    weak var databaseController: DatabaseProtocol?

    var selectedAdvert: Advertisement?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        

        selectedAdvert = Advertisement()
        // Setting the title to the custom font
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 20)!]
        
        
        // Search mechanism and setting up the UISearchController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Post Code"
        
        // Setting the search bar to the location that the user entered
        searchController.searchBar.text = location
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set to false every time in order to know which direction the user is going
        displayAdFlag = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /* This is used to empty the values in searched advert flag.
        Only called when user is going to the home screen as I want the user
        to be able to see the ads they searched for after clicking on one and returning
         */
        if displayAdFlag == false {
            allAdverts = []
            searchedAdverts = []
        }
        

    }
    
    // MARK: - Search Controller Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        // Search function finding all the advertisements with the same postcode as the user's search
        // I decided to allow the user to search for one sport but then change the post code to allow for flexibility in search
        if searchText.count > 0 {
            searchedAdverts = allAdverts.filter({ (advert: Advertisement?) -> Bool in
                guard let postcode = advert?.location else {
                    return false
                }
                
                return postcode.lowercased().contains(searchText)
            })
        } else {
            searchedAdverts = []
        }
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        // This is for the section with the adverts
        case SECTION_ADVERT:
            return searchedAdverts.count
        
        // Tells the user how many adverts were found
        case SECTION_INFO:
            return 1
            
        default:
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsTableViewCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        
        // Setting the value of the information cell
        if indexPath.section == 1 {
            if searchedAdverts.isEmpty {
                infoCell.textLabel?.text = "No advertisements found"
                infoCell.textLabel?.textColor = .secondaryLabel
                infoCell.textLabel?.textAlignment = .center
                infoCell.selectionStyle = .none
                
                return infoCell
            } else {
                infoCell.textLabel?.text = "\(searchedAdverts.count) Advertisements Found!"
                infoCell.textLabel?.textColor = .secondaryLabel
                infoCell.textLabel?.textAlignment = .center
                infoCell.selectionStyle = .none
    
                return infoCell
            }
            
            // Setting the values of the advertisement cells
        } else if !searchedAdverts.isEmpty {
            let advertResult = searchedAdverts[indexPath.row]
            
            cell.titleLabel?.text = advertResult.title
            cell.dateLabel.text = advertResult.date
            cell.dateLabel.textColor = .secondaryLabel
            cell.detailsLabel.text = advertResult.details
            cell.iconImageView.image = UIImage(named: advertResult.sport)

            return cell
            
        }
        
        return cell
 
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Set the advert that is selected
        if indexPath.section == SECTION_ADVERT {
            let advert = searchedAdverts[indexPath.row]
            selectedAdvert?.title = advert.title
            selectedAdvert?.date = advert.date
            selectedAdvert?.details = advert.details
            selectedAdvert?.sport = advert.sport
            selectedAdvert?.location = advert.location
            selectedAdvert?.userID = advert.userID
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            
        } else {
            
            // Making the cell unclickable
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayAdSegue" {
            let destination = segue.destination as? DisplayAdViewController
            displayAdFlag = true
            destination?.hidesBottomBarWhenPushed = true
            destination?.selectedAd = selectedAdvert!
            
        }
    }
    
    

}
