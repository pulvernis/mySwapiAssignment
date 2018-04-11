//
//  Model.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 30/03/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - NotificationCenter: key
let dataInModelClassDidUpdateNotification = "dataInModelClassDidUpdateNotification"
let baseUrl = "https://swapi.co/api/"

class Model {
    
    // Create Singleton: by Static Property and Private Initializer
    // Guarantees that only one instance of a class is instantiated. gives u global access and still using properties and methods of an object (not static)
    // The initializer of static properties are executed lazily by default - means that only when we use it first time it get initialized - the same happens in global variables
    
    // WHY NOT TO USE STATIC METHOD:
    // harder to test. If one static method calls another, it is difficult to override what happens in the second.
    
    // WHY SINGLETON:
    // 1.decide what happens when the instance is first accessed, via a private init()
    // 2.decide when this happens, namely when you first use it.
    // 3.much better (in terms of code readability) at keeping track of state.
    
    //  Static Methods benefit -  faster to call
    
    // Summary: use singleton when we need to do some resource intensive process - e.g: accessing db structures, managing network resources
    
    static let shared = Model()
    
    private init() {
    }
    
    var people:[Character] = []
    var moviesNamesByUrlsMap:[String: String] = [:]
    
    var totalNumOfPeopleInSwapiApi: Int? {
        didSet {
            if let totalNumOfPeople = totalNumOfPeopleInSwapiApi {
                totalPagesOfPeopleInSwapiApi = totalNumOfPeople/10 + 1
                // if database was update frequently with num of people i should make an update to the ui by the controller

            }
        }
    }
    
    // initialize from didSet{} when totalNumOfPeopleInSwapiApi is changing
    var totalPagesOfPeopleInSwapiApi: Int?
    
    
    // used it in tbl to load more pages when scroll - don't need it anymore
    // computed properties
    /*var currentlyPageNum: Int {
        return people.count/10
    }*/
    
    
    // because it's private (set) The only way to modify this property is via the requestData() method
    private (set) var characterMovies: [String]?
    private (set) var characterName: String?
    
    //Once we receive data in requestData, we save it in a local variable
    func requestDataForCharacterMovies(rowNumberFromTbl: Int) {
        
        let character = people[rowNumberFromTbl]
        let moviesUrlArr = character.moviesUrlArr
        var moviesStrArr:[String] = [] // does it matter if i do - var moviesStrArr = [String]()
        for movieUrl in moviesUrlArr {
            if let movieStr = moviesNamesByUrlsMap[movieUrl] {
                moviesStrArr.append(movieStr)
            }
        }
        
        self.characterMovies = moviesStrArr
        self.characterName = character.name
        
    }
    
    func getAllPeopleFromPageSwapiApi(pageNumber: Int, completion:  @escaping () -> ()) {
        
        let pageNum = "?page=\(pageNumber)" // each page give 10 characters
        
        let url = "\(baseUrl)people/\(pageNum)"
        
        Alamofire.request(url).responseJSON { (response) in
            
            guard response.error == nil  else {
                print("*\nError retreiving data from swapi api: \(response.error.debugDescription)")
                return
            }
            
            if let json = response.result.value as? [String:Any] {
                //print(json)
                
                if let jsonCharactersResults = json["results"] as? [[String:Any]] {
                
                    for (index, _) in jsonCharactersResults.enumerated(){
                        
                        let characterResults = jsonCharactersResults[index]
                        
                        guard let name = characterResults["name"] as? String else {
                            return
                        }
                        guard let gender = characterResults["gender"] as? String else {
                            return
                        }
                        
                        guard let urlForCharacter = characterResults["url"] as? String else {
                            return
                        }
                        
                        guard let height = characterResults["height"] as? String else {
                            return
                        }
                        
                        guard let mass = characterResults["mass"] as? String else {
                            return
                        }
                        
                        guard let eyeColor = characterResults["eye_color"] as? String else {
                            return
                        }
                        
                        guard let hairColor = characterResults["hair_color"] as? String else {
                            return
                        }
                        
                        guard let skinColor = characterResults["skin_color"] as? String else {
                            return
                        }
                        
                        guard let birthYear = characterResults["birth_year"] as? String else {
                            return
                        }
                        
                        guard let homeworldUrl = characterResults["homeworld"] as? String else {
                            return
                        }
                        
                        guard let vehiclesUrlArr = characterResults["vehicles"] as? [String] else {
                            return
                        }
                        
                        guard let starshipsUrlArr = characterResults["starships"] as? [String] else {
                            return
                        }
                        
                        guard let moviesUrlArr = characterResults["films"] as? [String] else {
                            return
                        }
                        
                        //print("*\nname: \(name), gender: \(gender)")
                        
                        let character = Character(name: name, gender: gender, urlForCharacter: urlForCharacter, height: height, mass: mass, eyeColor: eyeColor, hairColor: hairColor, skinColor: skinColor, birthYear: birthYear, homeworldUrl: homeworldUrl, vehiclesUrlArr: vehiclesUrlArr, starshipsUrlArr: starshipsUrlArr, moviesUrlArr: moviesUrlArr)
                        self.people.append(character)
                        //print("character: \(character)")
                    }
                    
                }
            }
            
            
            // In here (Alamofire.request - response) - after getting and load all characters  into people: [Character] we add completion that will 'escape' from here and load it in tbl
            completion()
            
        }
        
    }
    
    func getTotalNumOfPeopleFromApi(completion:  @escaping () -> ()) {
        Alamofire.request("https://swapi.co/api/people/").responseJSON { (response) in
            
            guard response.error == nil  else {
                print("*\nError retreiving data from swapi api: \(response.error.debugDescription)")
                return
            }
            
            if let json = response.result.value as? [String:Any] {
                
                if let jsonTotalCharactersNumResults = json["count"] as? Int {
                    print("jsonTotalCharactersNumResults = \(jsonTotalCharactersNumResults)")
                    self.totalNumOfPeopleInSwapiApi = jsonTotalCharactersNumResults
                    
                }
            }
            completion()
        }
    }
    
    func getHomeworldNamesByUrl(homeworldUrlOfCharacter homeworldUrl: String) {
        
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
        
    }
    
    var moviesUrlPage = "\(baseUrl)films"
    
    func getAllMoviesUrlsAndNamesFromApi() {
        
        Alamofire.request(moviesUrlPage).responseJSON(completionHandler: { (response) in
            guard response.error == nil else {
                print("Error in getting data api from url: \(self.homeworldUrlPage), message: \(response.error?.localizedDescription)")
                return
            }
            
            var namesByUrlsMap: [String:String] = [:]
            
            if let json = response.result.value as? [String: Any] {
                
                if let moviesArr = json["results"] as? [[String: Any]] {
                    for (index, _) in moviesArr.enumerated() {
                        if let name = moviesArr[index]["title"] as? String {
                            //print("moviesArr: index\(index) - name: \(name)")
                            if let url = moviesArr[index]["url"] as? String {
                                //print("moviesArr: index\(index) - url: \(url)")
                                namesByUrlsMap[url] = name
                            }
                        }
                    }
                }
                print("*\nnamesByUrlsMap: \(namesByUrlsMap)")
                self.moviesNamesByUrlsMap = namesByUrlsMap
                
                if let next = json["next"] as? String {
                    self.homeworldUrlPage = next
                    print("*\nhomeworldUrlPage: \(self.homeworldUrlPage)")
                    self.getAllHomeworldNames() // recursion
                }
            }
            
        })
        
    }
    
    
    var homeworldUrlPage = "\(baseUrl)planets/?page=1"
    
    func getAllHomeworldNames(/*homeworldUrlOfCharacter homeworldUrl: String*/) {
        
        Alamofire.request(homeworldUrlPage).responseJSON(completionHandler: { (response) in
            guard response.error == nil else {
                print("Error in getting data api from url: \(self.homeworldUrlPage), message: \(response.error?.localizedDescription)")
                return
            }
            
            if let json = response.result.value as? [String: Any] {
                
                if let homeworldArr = json["results"] as? [[String: Any]] {
                    for (index, _) in homeworldArr.enumerated() {
                        if let name = homeworldArr[index]["name"] as? String {
                            print("homeworldArr: index\(index) - name: \(name)")
                        }
                    }
                }
                
                if let next = json["next"] as? String {
                    self.homeworldUrlPage = next
                    print("*\nhomeworldUrlPage: \(self.homeworldUrlPage)")
                    self.getAllHomeworldNames() // recursion
                }
            }
            
        })
        
    }
    
    
}

struct Character {
    let name: String
    let gender: String
    let urlForCharacter: String
    let height: String
    let mass: String
    let eyeColor: String
    let hairColor: String
    let skinColor: String
    let birthYear: String
    let homeworldUrl: String
    let vehiclesUrlArr: [String] // need to call api again to get vehicles name chatacter owned
    let starshipsUrlArr: [String] // need to call api again to get starships names character owned
    let moviesUrlArr: [String]
}



