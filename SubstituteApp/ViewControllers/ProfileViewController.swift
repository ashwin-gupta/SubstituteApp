//
//  ProfileViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class ProfileViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var editSaveButton: UIBarButtonItem!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // Will be used to toggle the edit and save button
    var editDetailsFlag: Bool = false
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allowing the uesr to tap out of the keyboard by tapping the background
        self.hideKeyboardWhenTappedAround()
        
        // Setting up the indicator view
        indicatorView.isHidden = true
        indicatorView.color = UIColor.systemOrange
        indicatorView.hidesWhenStopped = true
        
        // Setting the delegate to self so that the field is limited to 4 characters
        locationTextField.delegate = self
        
        // Using user defaults to fill in details
        let defaults = UserDefaults.standard
        
        // Setting the font and colour of the navigation bar
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 38)!]
    
        navigationItem.title = "Profile"
  
        
        // Setting up database controller access in order to make changes to the user's file
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Setting the values of the text field based on UserDefaults
        nameTextField.text = defaults.object(forKey: "name") as? String
        
        emailTextField.text = defaults.object(forKey: "email") as? String
        
        phoneTextField.text = defaults.object(forKey: "number") as? String

        locationTextField.text = defaults.object(forKey: "location") as? String
        
        // Disabling text fields so that the user doesnt accidentally change information
        nameTextField.isEnabled = false
        nameTextField.textColor = .secondaryLabel
        
        emailTextField.isEnabled = false
        emailTextField.textColor = .secondaryLabel
        
        phoneTextField.isEnabled = false
        phoneTextField.textColor = .secondaryLabel
        
        locationTextField.isEnabled = false
        locationTextField.textColor = .secondaryLabel
        
        
        
    }
    
    @IBAction func editProfileButton(_ sender: Any) {
        // Decides the state of the button
        editDetailsFlag = !editDetailsFlag
        let user = User()
        
        if editDetailsFlag == true {
            // Enabling the text fields for editing and setting the edit button to save for good usability
            navigationItem.rightBarButtonItem?.title = "Save"
            nameTextField.isEnabled = true
            nameTextField.textColor = .label
            
            emailTextField.isEnabled = true
            emailTextField.textColor = .label
            
            phoneTextField.isEnabled = true
            phoneTextField.textColor = .label
            
            locationTextField.isEnabled = true
            locationTextField.textColor = .label
            
        } else {
            
            guard let name = nameTextField.text else {
                displayErrorMessage("Please enter a valid name")
                return
            }
            
            guard let email = emailTextField.text else {
                displayErrorMessage("Please enter an email address")
                return
            }
            
            guard let phone = phoneTextField.text else {
                displayErrorMessage("Please enter a phone number")
                return
            }
            
            guard let location = locationTextField.text else {
                displayErrorMessage("Please enter a valid location")
                return
            }
            
            if location.count != 4 {
                displayErrorMessage("Please enter a 4 digit location")
                return
            }
            
            // Provides feedback to the user
            indicatorView.startAnimating()
            
            // Since the length of location has been checked we can check the value of the postcode
            // This will check if this postcode is within Australia or not and only create a user if it is.
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = locationTextField.text

            let search = MKLocalSearch(request: request)
            
            search.start { [self] (response, error) in
                if let response = response {
                    
                    if response.mapItems[0].placemark.countryCode != "AU" {
                        
                        self.displayErrorMessage("Please enter a valid postcode")
                        self.indicatorView.stopAnimating()
                        
                        return
                    } else {
                        
                        // Making the changes to the view and editing the user
                        self.navigationItem.rightBarButtonItem?.title = "Edit"
                        user.name = name
                        user.email = email
                        user.phoneNumber = phone
                        user.location = location
                        
                        let title = "Edit User?"
                        let message = "Are you sure you want to edit the user? This cannot be reversed!"
                        
                        self.displayAlertUser(title: title, message: message, user: user)
                        
                        // Disabling the text fields again
                        self.nameTextField.isEnabled = false
                        self.nameTextField.textColor = .secondaryLabel
                        
                        self.emailTextField.isEnabled = false
                        self.emailTextField.textColor = .secondaryLabel
                        
                        self.phoneTextField.isEnabled = false
                        self.phoneTextField.textColor = .secondaryLabel
                        
                        self.locationTextField.isEnabled = false
                        self.locationTextField.textColor = .secondaryLabel
    

                        }
                        
                        self.indicatorView.stopAnimating()
                        // Popping the navigation view controller
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                }


            
            
        }
    }
    
    // Double checking that the user wants to make this change by showing an alert
    func displayAlertUser(title: String, message: String, user: User) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (_) in
            
            if let _ = self.databaseController?.editUser(user: user) {
                
                let alert = UIAlertController(title: "Edit Successful", message: "User information edited", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Function used to display error messages
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // This function is used to limit the characters in the location text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == locationTextField {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        } else {
            return true
        }

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
