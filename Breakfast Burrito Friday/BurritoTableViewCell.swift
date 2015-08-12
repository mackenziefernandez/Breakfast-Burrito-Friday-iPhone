//
//  BurritoTableViewCell.swift
//  Breakfast Burrito Friday
//
//  Created by Mackenzie Fernandez on 3/17/15.
//  Copyright (c) 2015 Mackenzie Fernandez. All rights reserved.
//

import UIKit

class BurritoTableViewCell: UITableViewCell {

    @IBOutlet weak var numberOfBurritosLabel: UILabel!
    @IBOutlet weak var burritoFlavorLabel: UILabel!
    @IBOutlet weak var whoOrderedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
