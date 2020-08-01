//
//  HomeSearchViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 15/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Extension for all View Controllers to allow uesrs to tap out of a text field by tapping the background
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        
        // Setting up a gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        // Allows tapping on other objects
        tap.cancelsTouchesInView = false
        
        // Adding the gesture
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        // Dismisses the keyboard
        view.endEditing(true)
    }
}




class HomeSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    
    var databaseController: DatabaseProtocol?
  
 
    // This sport string will be used to pass the sport that user is looking for
    var sport: String?
    
    // INdicator view used to load advertisements
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // Setting the inests of the collection view controller
    private let sectionInsets = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    private let itemsPerRow: CGFloat = 3
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var sportCollectionView: UICollectionView!
    
    let sportArray = ["Soccer", "Tennis", "Cricket", "Basketball", "Volleyball", "Rugby", "Baseball", "Golf", "Other"]
    

    var adverts: [Advertisement]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Dismisses the keyboard when tapping background
        self.hideKeyboardWhenTappedAround() 
        
        // Styling the buttonto be rounded
        searchButton.layer.cornerRadius = 12
        
        // Indicator to give feedback to the user that the view is loading
        indicatorView.isHidden = true
        indicatorView.color = UIColor.systemOrange
        
        locationField.delegate = self
        
        // Setting the font style and size for the app
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange, NSAttributedString.Key.font: UIFont(name: "SFSportsNightNS", size: 38)!]

        navigationController?.navigationBar.tintColor = UIColor.systemOrange
        
        // Title of the home screen
        navigationItem.title = "Substitute"
        
        // Setting the collection view and data source to this view controller
        sportCollectionView.dataSource = self
        sportCollectionView.delegate = self
        
        // Setting up database controller access
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        // We log in as the current user id
        let userID = Auth.auth().currentUser?.uid
        
        // Ensuring userID is not nil before logging in
        if userID != nil {
            databaseController?.userLogIn()
        }
        
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sportArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sportCell", for: indexPath) as! SportCollectionViewCell
        
        // Setting the values of each cell
        let cellSport = sportArray[indexPath.row]
        cell.sportLabel.text = cellSport
        cell.sportLabel.font = .boldSystemFont(ofSize: 18)
        cell.sportImage.image = UIImage(named: cellSport)
        cell.layer.cornerRadius = 12
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Setting the sport value of the searched array to that of inside the array at which the user has tapped on
        sport = sportArray[indexPath.row]
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = .systemOrange
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        // Setting the sizing of the collectionView
        let paddingSpace = sectionInsets.left * (itemsPerRow)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    @IBAction func searchAdvert(_ sender: Any) {
        
        indicatorView.startAnimating()
        
        // If sport is not chosen this will throw an error
        guard let selectedSport = sport else {
            displayErrorMessage("Please select a sport")
            return
        }
        
        
        if locationField.text == "" {
            displayErrorMessage("Enter a valid postcode")
            return
        }
        databaseController?.retrieveAdverts(sport: selectedSport, completion: { (advert) in
            
            // Completion handler to get all adverts with the selected sport
            self.adverts = advert
            
            self.indicatorView.hidesWhenStopped = true
            self.indicatorView.stopAnimating()
            
            self.performSegue(withIdentifier: "searchAdvertSegue", sender: nil)
            
        })
        

    }
    
    // Function used to display error messages
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - TextFieldDelegate Function
    // This function is used to limit the characters in the location text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == locationField {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        } else {
            return true
        }

        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchAdvertSegue" {
            let destination = segue.destination as? ResultsTableViewController
            // Passing the adverts we got from Firebase to the next VC
            destination?.allAdverts = adverts!
            destination?.location = locationField.text!
        }
    }
    

}
