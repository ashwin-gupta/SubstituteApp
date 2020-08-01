//
//  RegisterViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 9/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth
// Mapkit is important to ensure that the user is putting in a valid location
import MapKit

// Similar to Gallery App Log In in Week 9

class RegisterViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    weak var databaseController: DatabaseProtocol?
    
    var handle: AuthStateDidChangeListenerHandle?
    var indicator = UIActivityIndicatorView()
    var newUser: User?
    
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    // Function used to display error messages
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the indicator view
        indicatorView.isHidden = true
        indicatorView.color = UIColor.systemOrange
        indicatorView.hidesWhenStopped = true
        
        // Setting the delegate to self so that the location text field is limited to 4 characters
        locationTextField.delegate = self
        
        registerButton.layer.cornerRadius = 12
        
        //  Access to data base
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Dismisses the keyboard when tapping background
        self.hideKeyboardWhenTappedAround() 


    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Listening to changes to the authentication, if the user is logged in, this will then pass the segue
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if (user != nil) {
                self.performSegue(withIdentifier: "registeredSegue", sender: nil)
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)

    }
    
    
    @IBAction func registerAccount(_ sender: Any) {

        // Unwrapping the text fields and ensuring there are no nils
        // These ensure that these fields are not left empty and show an alert for each error
        guard let name = nameTextField.text else {
            displayErrorMessage("Please enter a name")
            return
        }
        
        guard let phoneNumber = phoneTextField.text else {
            displayErrorMessage("Please enter a phone number")
            return
        }
        
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        
        guard let email = emailTextField.text else {
            displayErrorMessage("Please enter an email address")
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
        
        indicatorView.startAnimating()
        
        // Since the length of location has been checked we can check the value of the postcode
        // This will check if this postcode is within Australia or not and only create a user if it is.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationTextField.text

        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let response = response {
                
                if response.mapItems[0].placemark.countryCode != "AU" {
                    
                    self.displayErrorMessage("Please enter a valid postcode")
                    self.indicatorView.stopAnimating()
                    
                    return
                } else {
                    
                    // This is placed here as the app can only create a user if location requirements are met
                    // In this case the location is 4 numnbers long and is in Australia
                    self.newUser?.name = name
                    self.newUser?.phoneNumber = phoneNumber
                    self.newUser?.email = email
                    self.newUser?.location = location
                    
                    // Creating the user in Firebase
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if let error = error {
                                self.displayErrorMessage(error.localizedDescription)
                                
                            } else if  Auth.auth().currentUser?.uid != nil {
                                // Logging the user in after creating the user
                                self.databaseController?.userLogIn()
                                let _ = self.databaseController?.addUser(userName: name, email: email, phoneNumber: phoneNumber, location: location)

                            }

                    }
                    // Stops the indicator view from animating
                    self.indicatorView.stopAnimating()
                    // Popping the navigation view controller
                    self.navigationController?.popViewController(animated: true)
                    return
                }
            }

        }
    

        }
        
    
    // From Stack Overflow
    // Used to restrict user input to 4
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
        
}
    




