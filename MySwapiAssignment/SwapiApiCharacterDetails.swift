//
//  SwapiApiCharacterDetails.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 05/05/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation
import Alamofire

struct SwapiApiCharacterDetails {
    
    static func getAllPeopleInPageSwapiApi(fromPage: Int, getAllNextPages: Bool, completion:  @escaping () -> ()) {
        
        let pageNum = "?page=\(fromPage)" // each page give 10 characters
        let url = "\(baseUrl)people/\(pageNum)"
        
        Alamofire.request(url).responseJSON { (response) in
            
            if let error = response.error {
                print("*\nError retreiving data from swapi api: \(error.localizedDescription)")
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                return
            }
            
            if getAllNextPages {
                if let next = jsonResult["next"] as? String {
                    let nextPage = fromPage + 1
                    print("*\nUrl Page: \(next)")
                    self.getAllPeopleInPageSwapiApi(fromPage: nextPage, getAllNextPages: true){}// recursion
                }
            }
            
            // all characters in swapi page to people: [Character] in ModelShared
            charactersResultsToModel(jsonResult: jsonResult)
            // initialize totalNumOfPeople only at first time calling
            if modelShared.totalNumOfPeopleInSwapiApi == nil {
                if let totalNumOfPeople = jsonResult["count"] as? Int {
                    modelShared.totalNumOfPeopleInSwapiApi = totalNumOfPeople
                }
            }
            
            // In here (Alamofire.request - response) - after getting and load all characters  into people: [Character] we add completion that will 'escape' from here and load it in tbl in TableViewController
            // If a closure is passed as an argument to a function and it is invoked after the function returns, the closure is escaping
            if !getAllNextPages {
                completion()
            }
            
        }
    }
    
    private static func charactersResultsToModel(jsonResult: [String: Any]) {
        
        var newCharacters:[Character] = []
        if let jsonCharactersResults = jsonResult["results"] as? [[String:Any]] {
            
            for (index, _) in jsonCharactersResults.enumerated(){
                
                let characterResults = jsonCharactersResults[index]
                
                guard
                    let name = characterResults["name"] as? String,
                    let gender = characterResults["gender"] as? String,
                    let urlForCharacter = characterResults["url"] as? String,
                    let height = characterResults["height"] as? String,
                    let mass = characterResults["mass"] as? String,
                    let eyeColor = characterResults["eye_color"] as? String,
                    let hairColor = characterResults["hair_color"] as? String,
                    let skinColor = characterResults["skin_color"] as? String,
                    let birthYear = characterResults["birth_year"] as? String,
                    let homeworldUrl = characterResults["homeworld"] as? String,
                    let vehiclesUrlArr = characterResults["vehicles"] as? [String],
                    let starshipsUrlArr = characterResults["starships"] as? [String],
                    let moviesUrlArr = characterResults["films"] as? [String]
                    else {
                        return
                }
                
                let character = Character(name: name, gender: gender, height: height, mass: mass, eyeColor: eyeColor, hairColor: hairColor, skinColor: skinColor, birthYear: birthYear, homeworldUrl: homeworldUrl, urlForCharacter: urlForCharacter, vehiclesUrlArr: vehiclesUrlArr, starshipsUrlArr: starshipsUrlArr, moviesUrlArr: moviesUrlArr)
                newCharacters.append(character)
            }
            
            // add 10 characters to self.people instead 1 every time, it will make if statement inside didSet in people to check only after 10 characters is added to people property
            modelShared.people.append(contentsOf: newCharacters)
        }
    }
    
}
