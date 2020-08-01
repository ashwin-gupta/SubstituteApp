//
//  EditDetailsViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit


class EditDetailsViewController: UIViewController {
    
    var advert: Advertisement?
    var delegate: AdvertChangedDelegate?

    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allowing the uesr to tap out of the keyboard by tapping the background
        self.hideKeyboardWhenTappedAround()
        
        // Designing the details text field to be more visible
        detailsTextView.backgroundColor = .secondarySystemFill
        detailsTextView.layer.cornerRadius = 12

        // Setting the title of the VC
        navigationItem.title = "Details"
        // Setting the details to the details of the advertisement
        
        if advert?.details == "" {
            detailsTextView.text = "Enter details here!"
        } else {
            detailsTextView.text = advert?.details
            saveButton.layer.cornerRadius = 12
            
            
        }

        
    }
    
    @IBAction func saveDetails(_ sender: Any) {
        if detailsTextView.text != "" {
            advert?.details = detailsTextView.text!

            delegate?.advertChanged(advert!)
            navigationController?.popViewController(animated: true)
            
            return
            
        }
        
    }
    

}
