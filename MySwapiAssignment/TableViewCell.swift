//
//  TableViewCell.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 08/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func allMoviesCharacterBtn(_ sender: UIButton) {
    }
    

}
