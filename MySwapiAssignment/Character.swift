//
//  Character.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 05/05/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation

struct Character {
    let name, gender, height, mass, eyeColor, hairColor, skinColor, birthYear, homeworldUrl: String
    let urlForCharacter: String
    let vehiclesUrlArr: [String] // need to call api again to get vehicles name chatacter owned
    let starshipsUrlArr: [String] // need to call api again to get starships names character owned
    let moviesUrlArr: [String]
    
}
