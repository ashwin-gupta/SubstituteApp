//
//  EditSportsViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class EditSportsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var sportCollectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    let sportArray = ["Soccer", "Tennis", "Cricket", "Basketball", "Volleyball", "Rugby", "Baseball", "Golf", "Other"]

    var advert = Advertisement()
    var delegate: AdvertChangedDelegate?
    private let sectionInsets = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    private let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 12
        
        // Setting the title of the view
        navigationItem.title = "Sport"
        

        
        // Setting the data source and delegate to this view controller
        sportCollectionView.dataSource = self
        
        sportCollectionView.delegate = self

    }
    
    @IBAction func saveSport(_ sender: Any) {
        
        if advert.sport == "" {
            displayErrorMessage("Please choose a sport!")
            return
        } else {

            delegate?.advertChanged(advert)
            navigationController?.popViewController(animated: true)
            return
        }
    }
    
    // Function used to display error messages
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Number of Elements in the Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sportArray.count
    }
    
    // Sets the setting for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sportCell", for: indexPath) as! SportCollectionViewCell
        
        // This is used to set the name and image of the cells
        let cellSport = sportArray[indexPath.row]
        cell.sportLabel.text = cellSport
        cell.sportLabel.font = .boldSystemFont(ofSize: 18)
        cell.sportImage.image = UIImage(named: cellSport)
        cell.layer.cornerRadius = 12
        
        return cell
       
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Setting the sport value of the searched array to that of inside the array at which the user has tapped on
        advert.sport = sportArray[indexPath.row]
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
        
        // Setting the layout and padding of the cell
        let paddingSpace = sectionInsets.left * (itemsPerRow)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

}
