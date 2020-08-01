//
//  DisplayAdViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit



class DisplayAdViewController: UIViewController, MKMapViewDelegate {

    
    weak var databaseController: DatabaseProtocol?

    
    
    // Outlets for the view controller
    
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    var selectedAd = Advertisement()
    var profile: User?
    let format = DateFormatter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        profileBarButtonItem.isEnabled = false
        
        // Using the app delegate to get access to database functions
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    
        
        // Allowing for multiple lines
        detailsLabel.numberOfLines = 0
        format.dateFormat = "dd/MM/yyyy"
        
        
        // No force unwrapping as the advertisement is set from previous VC
        titleLabel.text = selectedAd.title
        dateLabel.text = "Date Posted: \(selectedAd.date)"
        locationLabel.text = "Post code: \(selectedAd.location)"
        detailsLabel.text = selectedAd.details
        
        navigationItem.title = selectedAd.title
        
        // Second argument completion handler, block fo code tha take user as an argument and when it gets
        databaseController?.retrieveUser(uid: selectedAd.userID, completion: { (user) in
            
            // Completion handler so that the user is retrieved once Firebase has finished retreival
            self.profile = user
            
            // Enabling the button so that the user can click on it once the user has loaded
            self.profileBarButtonItem.isEnabled = true
        })
        
        // Setting the location of the map to the location of the advert
        
        // Tutorial from: https://www.youtube.com/watch?v=vL1FyHB-p7o
        
        // Getting a request using MKLocalSearch to search for the postcode and display into
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = selectedAd.location
        request.region = mapView.region
        
        // This function makes use of Apple Maps and searches for locations
        let search = MKLocalSearch(request: request)
        
        // Completion handler
        search.start { (response, error) in
            if response == nil {
                print("Error")
            }
            else {
                
                // Sets the coodinates for the first element it finds
                let latitude = response!.boundingRegion.center.latitude
                let longitude = response!.boundingRegion.center.longitude
                
                // Annotating the map with this information
                let annotation = MKPointAnnotation()
                annotation.title = self.selectedAd.title
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                self.mapView.addAnnotation(annotation)
 
                // Adding annotation adn setting region plus animation
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                
            }
        }

    }
    

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactInfoSegue" {
            let destination = segue.destination as? ProfileAdvertViewController
                destination?.advert = selectedAd
                destination?.userProfile = profile
        }


    }
    

}
