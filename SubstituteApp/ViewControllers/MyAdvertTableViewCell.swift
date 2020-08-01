//
//  MyAdvertTableViewCell.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 19/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class MyAdvertTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
