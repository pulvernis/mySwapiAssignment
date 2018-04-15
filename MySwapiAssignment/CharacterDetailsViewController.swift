//
//  CharacterDetailsViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 06/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

class CharacterDetailsViewController: UIViewController {

    @IBOutlet weak var characterNameLabel: UILabel!
    
    @IBOutlet var characterDetails: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let characterFromRowTapped = Model.shared.charcterRowTapped
        
        if let character = characterFromRowTapped {
            characterNameLabel.text = character.name
            
            characterDetails[DetailType.GENDER.rawValue].text = character.gender
            characterDetails[DetailType.BIRTH_YEAR.rawValue].text = character.birthYear
            characterDetails[DetailType.HOME_WORLD.rawValue].text = character.homeworldUrl
            characterDetails[DetailType.EYE_COLOR.rawValue].text = character.eyeColor
            characterDetails[DetailType.HAIR_COLOR.rawValue].text = character.hairColor
            characterDetails[DetailType.SKIN_COLOR.rawValue].text = character.skinColor
            characterDetails[DetailType.HEIGHT.rawValue].text = character.height
            characterDetails[DetailType.MASS.rawValue].text = character.mass
            
            characterDetails[DetailType.VEHICLES.rawValue].sizeToFit()
            if !character.vehiclesUrlArr.isEmpty {
                var textForLabel = character.vehiclesUrlArr[0]
                for (index, vehicle) in character.vehiclesUrlArr.enumerated() {
                    if index>1 {
                        textForLabel += "\n\(vehicle)"
                    }
                }
                characterDetails[DetailType.VEHICLES.rawValue].text = textForLabel
            } else {
                characterDetails[DetailType.VEHICLES.rawValue].text = "has no vehicles"
            }
            
            characterDetails[DetailType.STARSHIPS.rawValue].sizeToFit()
            if !character.starshipsUrlArr.isEmpty {
                var textForLabel = character.starshipsUrlArr[0]
                for (index, starship) in character.starshipsUrlArr.enumerated(){
                    if index>1 {
                        textForLabel += "\n\(starship)"
                    }
                }
                characterDetails[DetailType.STARSHIPS.rawValue].text = textForLabel
            } else {
                characterDetails[DetailType.STARSHIPS.rawValue].text = "has no starships"
            }
            
            
        }
        
        
        
    }

}

// Arranging enum DetailType: 
// By the order of setting the details in storyboard in @IBOutlet var characterDetails: [UILabel]!
enum DetailType: Int {
    case GENDER
    case BIRTH_YEAR
    case HOME_WORLD
    case EYE_COLOR
    case HAIR_COLOR
    case SKIN_COLOR
    case HEIGHT
    case MASS
    case VEHICLES
    case STARSHIPS
    
    /*func getName() -> String {
        switch self {
        case .GENDER:
            return "gender"
        case .BIRTH_YEAR:
            return "birthYear"
        case .HOME_WORLD:
            return "Homeworld"
            
        }
    }*/
    
}
