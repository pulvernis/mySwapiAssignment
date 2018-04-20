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
        
        let sharedInstance = Model.shared
        
        let characterFromRowTapped = sharedInstance.charcterRowTapped
        
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
            
            characterDetails[DetailType.VEHICLES.rawValue].text = getTextForLabel(detailType: .VEHICLES, character: character)
            
            characterDetails[DetailType.STARSHIPS.rawValue].text = getTextForLabel(detailType: .STARSHIPS, character: character)
        }
        
    }
    
    func getTextForLabel(detailType: DetailType, character: Character) -> String {
        
         let typeUrlsArr = detailType.getUrlArr(character: character)
        let typeNamesByUrls = detailType.getNameByUrl()
        
        var textForLabel = ""
        var itemNumber = 1
        
        characterDetails[detailType.rawValue].sizeToFit()
        if !typeUrlsArr.isEmpty {
            if let typeStr = typeNamesByUrls[typeUrlsArr[0]] {
                textForLabel = "\(itemNumber). \(typeStr)"
                itemNumber += 1
                
                for (index, typeUrl) in typeUrlsArr.enumerated() {
                    if index>1 {
                        if let extraType = typeNamesByUrls[typeUrl] {
                            textForLabel += "\n\(itemNumber). \(extraType)"
                            itemNumber += 1
                        }
                    }
                }
            }
            return textForLabel
        }
        
        return "Without means"
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
    
    func getUrlArr(character: Character) -> [String] {
        
        switch self {
        case .VEHICLES:
            return character.vehiclesUrlArr
        case .STARSHIPS:
            return character.starshipsUrlArr
        default:
            return []
        }
    }
    
    func getNameByUrl() -> [String:String] {
        switch self {
        case .VEHICLES:
            return Model.shared.vehiclesNamesByUrlsDict
        case .STARSHIPS:
            return Model.shared.starshipsNamesByUrlsDict
        default:
            return [:]
        }
    }
    
}
