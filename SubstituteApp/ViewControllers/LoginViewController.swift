//
//  LoginViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 8/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    var registeredUser: User?
    var databaseController: DatabaseProtocol?
    
    
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    

    @IBOutlet weak var loginBtn: UIButton!
    
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBAction func loginButton(_ sender: Any) {
        guard let password = passwordTextField.text else {
            displayErrorMessage("Please enter a password")
            return
        }
        
        guard let email = emailTextField.text else {
            displayErrorMessage("Please enter an email address")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            }
        }
        
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidesBottomBarWhenPushed = true
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if (user != nil) {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.passwordTextField.resignFirstResponder()
                self.emailTextField.resignFirstResponder()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismisses the keyboard when tapping background
        self.hideKeyboardWhenTappedAround() 
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Rounding out the edges of buttons
        loginBtn.layer.cornerRadius = 12
        registerBtn.layer.cornerRadius = 12
        

        
    }
    

    // Used to show errors 
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
