//
//  SportCollectionViewCell.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 30/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class SportCollectionViewCell: UICollectionViewCell {
    
    // Outlets for image and label
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    
    // Used for giving user feedback on what they have selected
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setting the design of the collection views
        let greyView = UIView(frame: bounds)
        greyView.backgroundColor = .secondarySystemFill
        self.backgroundView = greyView

        // Orange when selected
        let orangeView = UIView(frame: bounds)
        orangeView.backgroundColor = .systemOrange
        self.selectedBackgroundView = orangeView
    }
}
