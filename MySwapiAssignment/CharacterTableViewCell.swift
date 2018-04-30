//
//  CharacterTableViewCell.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 26/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation
import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    // MARK: Delegate-Style - property
    // Add delegate property to custom cell class. Make it weak and optional.
    // Then, wire up the button action to method within the cell to call these delegate method
    
    weak var delegate:TableViewCellDelegate?
    
    @IBOutlet weak var titleLabelCharacterName: UILabel!
    
    @IBOutlet weak var subTitleLabelCharacterGender: UILabel!
    
    @IBOutlet weak var imageviewOfCharacter: UIImageView!
    
    @IBOutlet weak var allMoviesBtn: UIButton!
    
    @IBAction func allMoviesCharacterTappedBtn(_ sender: UIButton) {
        delegate?.tableViewCellDidTapAllMoviesBtn(self) // (self -> CharacterTableViewCell)
    }
    
    @IBAction func birthDayBtn(_ sender: UIButton) {
        delegate?.tableViewCellDidTapBDBtn(self)
    }
    
}
