//
//  EditLocationViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class EditLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    var advert: Advertisement?
    var delegate: AdvertChangedDelegate?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var checkButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismisses the keyboard when tapping background
        self.hideKeyboardWhenTappedAround()
        
        locationTextField.delegate = self
        locationTextField.text = advert?.location
        saveButton.layer.cornerRadius = 12
        checkButton.layer.cornerRadius = 12
        
        
        navigationItem.title = "Location"
    }
    
    @IBAction func saveLocation(_ sender: Any) {
        
        // Do this check twice as a user might change location text field between check and save
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationTextField.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        var responseResult = true
        
        // Completion handler to ensure there is a
        search.start { (response, error) in
            if let response = response {
                if response.mapItems[0].placemark.countryCode != "AU" {
                    
                    self.displayErrorMessage("Please enter a valid postcode")
                    responseResult = false
                    return
                }
            }
        }
        
        guard let advert = advert else {
            
            // Just in case we check if advert is nil
            fatalError("Failed to unwrap advert")
        }
        
        guard let location = locationTextField.text else {
            fatalError("Failed to unwrap location field")
        }
        
        // Checking that location is not empty
        if location.count == 4 && responseResult == true {
            
            // setting the advert location to the one entered by the user
            advert.location = location
            
            delegate?.advertChanged(advert)
            navigationController?.popViewController(animated: true)
            
            return
            
        } else {
            displayErrorMessage("Enter a valid postcode")
            return
        }
    }
    
    @IBAction func checkLocation(_ sender: Any) {
        // Getting a request using MKLocalSearch to search for the postcode and display into
        
        mapView.removeAnnotations(mapView.annotations)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationTextField.text
        request.region = mapView.region
        
        // Guard to ensure that this can be unwrapped
        guard let location = locationTextField.text else {
            fatalError("Unable to unwrap location")
            
        }
        // Checking that the location is of right length
        if location.count != 4 {
            displayErrorMessage("Please enter a valid postcode")
        
        } else {
            // Searcing for postcode
            let search = MKLocalSearch(request: request)
            
            // Completion handler
            search.start { (response, error) in
                if let response = response {
                    // This checks whether the postcode/request is in Australia
                    if response.mapItems[0].placemark.countryCode != "AU" {
                        // Errormessage and return
                        self.displayErrorMessage("Please enter a valid postcode")
                        return
                    }
                    
                    
                    let latitude = response.boundingRegion.center.latitude
                    let longitude = response.boundingRegion.center.longitude
                    
                    // Adding annotation
                    let annotation = MKPointAnnotation()
                    annotation.title = self.locationTextField.text
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    self.mapView.addAnnotation(annotation)
                    
                    // Setting the region
                    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                }
                
                else {
                    print("Error")
                }
                    
                    
            }
            
        }
        

        
    }
    
    // From Stack Overflow
    // Used to restrict user input to 4
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }

    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
        
        
}



