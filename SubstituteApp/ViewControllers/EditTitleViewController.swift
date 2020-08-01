//
//  EditTitleViewController.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class EditTitleViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var advert = Advertisement()
    var delegate: AdvertChangedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Hides the keyboard when the user taps outside the text field
        self.hideKeyboardWhenTappedAround()
        
        // Setting the title to the title of the advert
        titleTextField.text = advert.title
        saveButton.layer.cornerRadius = 10

        
    }
    
    @IBAction func saveTitle(_ sender: Any) {
        if titleTextField.text != "" {
            advert.title = titleTextField.text!
            
            // Pass the advert back to the main edit screen and set newAdvert to false to set up
            delegate?.advertChanged(advert)
            
            navigationController?.popViewController(animated: true)
            
            return
        
        }
    }
    

}
