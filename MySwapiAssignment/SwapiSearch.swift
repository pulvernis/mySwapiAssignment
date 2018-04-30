//
//  SwapiSearch.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 26/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation
import Alamofire

let baseUrl = "https://swapi.co/api/"

class SwapiSearch {
    
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
            // initialize totalPeopleInEachPageInSwapiApi only at first time calling
            if modelShared.totalNumOfPeopleInEachPageInSwapiApi == nil {
                if let jsonCharactersResults = jsonResult["results"] as? [[String:Any]] {
                    modelShared.totalNumOfPeopleInEachPageInSwapiApi = jsonCharactersResults.count
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

    static func getSwapiTypeFromUrlPage(swapiType: UrlSwapiType, fromPage: Int, getAllNextPages: Bool) {
        
        // This inside func used after we ger result from swapi by alamofire
        func getResultSwapiTypeUrlPage(tempNamesByUrlsDict: [String:String], swapiType: UrlSwapiType) {
            
            switch swapiType {
            case .VEHICLES:
                // forEach: will iterate every key value from tempDict.
                // inside that closure we had all keys values to the other dict (vehiclesNameByUrl)
                tempNamesByUrlsDict.forEach { modelShared.vehiclesNamesByUrlsDict[$0] = $1 } // add dict to dict
            case .MOVIES:
                tempNamesByUrlsDict.forEach { modelShared.moviesNamesByUrlsDict[$0] = $1 }
            case .STAR_SHIPS:
                tempNamesByUrlsDict.forEach { modelShared.starshipsNamesByUrlsDict[$0] = $1 }
            case .HOME_WORLD:
                tempNamesByUrlsDict.forEach { modelShared.homeworldNamesByUrlsDict[$0] = $1 }
            }
        }
        
        let swapiTypeStr = swapiType.rawValue
        let urlPage = "\(baseUrl)\(swapiTypeStr)?page=\(fromPage)"
        Alamofire.request(urlPage).responseJSON(completionHandler: { (response) in
            guard response.error == nil else {
                print("Error in getting data api from url: \(urlPage), message: \(response.error!.localizedDescription)")
                return
            }
            
            if let jsonResult = response.result.value as? [String: Any] {
                var tempNamesByUrlsDict: [String:String] = [:] // will assigned with 10 urls/names per page
                
                var name = "name"
                if swapiType == .MOVIES { // movies/films in swapi have "title" instead of "name"
                    name = "title"
                }
                
                if let resultArr = jsonResult["results"] as? [[String: Any]] {
                    for (index, _) in resultArr.enumerated() {
                        if let name = resultArr[index][name] as? String,
                            let url = resultArr[index]["url"] as? String {
                            tempNamesByUrlsDict[url] = name
                        }
                    }
                }
                
                // invoke inside func (look up)
                getResultSwapiTypeUrlPage(tempNamesByUrlsDict: tempNamesByUrlsDict, swapiType: swapiType)
                
                if getAllNextPages {
                    
                    if let next = jsonResult["next"] as? String {
                        let nextPage = fromPage + 1
                        print("*\nurlPage: \(next)")
                        self.getSwapiTypeFromUrlPage(swapiType: swapiType, fromPage: nextPage, getAllNextPages: true) // recursion
                    }
                }
            }
        })
        
    }
    
    enum UrlSwapiType: String {
        case VEHICLES = "vehicles/"
        //case PEOPLE = "people/"
        case MOVIES = "films/"
        case STAR_SHIPS = "starships/"
        case HOME_WORLD = "planets/"
    }
    
    // 2 Unused Methods of Class Model
    
    /*func getAllPeopleFromSwapiApi(fromPageNumber: Int) {
     let pageNum = "?page=\(fromPageNumber)" // each page give 10 characters
     let url = "\(baseUrl)people/\(pageNum)"
     
     Alamofire.request(url).responseJSON(completionHandler: { (response) in
     guard response.error == nil else {
     print("Error in getting data api from url: \(self.homeworldUrlPage), message: \(response.error?.localizedDescription)")
     return
     }
     
     if let json = response.result.value as? [String:Any] {
     if let jsonCharactersResults = json["results"] as? [[String:Any]] {
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
     
     let character = Character(name: name, gender: gender, urlForCharacter: urlForCharacter, height: height, mass: mass, eyeColor: eyeColor, hairColor: hairColor, skinColor: skinColor, birthYear: birthYear, homeworldUrl: homeworldUrl, vehiclesUrlArr: vehiclesUrlArr, starshipsUrlArr: starshipsUrlArr, moviesUrlArr: moviesUrlArr)
     self.people.append(character)
     }
     
     }
     
     if (json["next"] as? String) != nil {
     let nextPageNumber = fromPageNumber+1
     self.getAllPeopleFromSwapiApi(fromPageNumber: nextPageNumber)
     }
     }
     })
     }*/
    
    /*func getHomeworldNamesByUrl(homeworldUrlOfCharacter homeworldUrl: String) {
     
     Alamofire.request(homeworldUrl).responseJSON(completionHandler: { (response) in
     guard response.error == nil else {
     print("Error in getting data api from url: \(homeworldUrl), message: \(response.error?.localizedDescription)")
     return
     }
     
     if let json = response.result.value as? [String: Any] {
     
     if let homeworldStr = json["name"] as? String {
     print("homeworldStr: \(homeworldStr)")
     }
     
     }
     
     })
     
     }*/
    
    
    
}
