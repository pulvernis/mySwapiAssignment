//
//  Model.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 30/03/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.

/*
 Model:
 1. Class Using Singleton:
 2. Struct of Character - get append to property class (array of Characters called people)
 3. Using Alamofire:
 A. getAllPeopleInPageSwapiApi() - method that get 10 characters in each @escaping closure for loading to tbl
 B. getSwapiTypeFromUrlPage() - get in the background one page of type with optional of getting all the next pages (type can be vehicles, homeworlds, starships or movies but not people)
 */


// Create Singleton: by Static Property and Private Initializer
// Guarantees that only one instance of a class is instantiated. gives u global access and still using properties and methods of an object (not static)
// The initializer of static properties are executed lazily by default - means that only when we use it first time it get initialized (the same happens in global variables)

// WHY NOT TO USE STATIC METHOD:
// harder to test. If one static method calls another, it is difficult to override what happens in the second.

// WHY SINGLETON:
// 1. decide what happens when the instance is first accessed, via a private init()
// 2. decide when this happens, namely when you first use it.
// 3. much better (in terms of code readability) at keeping track of state.

//  Static Methods benefit -  faster to call

// Summary: use singleton when we need to do some resource intensive process - e.g: accessing db structures, managing network resources

import Foundation
import Alamofire

let baseUrl = "https://swapi.co/api/"

class Model {
    
    static let shared = Model()
    
    private init() {
        // MARK: PopUp by BD btn - NotificationCenter - addObserver in Model init()
        NotificationCenter.default.addObserver(forName: .characterBirthDay, object: nil, queue: nil,
                                               using: passingDataOfCellNumber)
    }
    
    var totalNumOfPeopleInSwapiApi: Int? { // initialize only once - when i get the first page of people
        didSet {
            if let totalNumOfPeople = totalNumOfPeopleInSwapiApi { // ambivalent to - if it's not nil
                totalPagesOfPeopleInSwapiApi = totalNumOfPeople/10 + 1
            }
        }
    }
    
    // initialize from didSet{} when totalNumOfPeopleInSwapiApi is changing
    // Use for TVC
    private (set) var totalPagesOfPeopleInSwapiApi: Int?
    
    private (set) var people:[Character] = [] {
        didSet {
            if people.count == totalNumOfPeopleInSwapiApi {
                // MARK: NotificationCenter - sending a signal that he get all people/characters
                NotificationCenter.default.post(name: .reloadTbl, object: nil)
                // Get the extra images: (20 already received)
                for index in imageByCharacterNameDict.count..<people.count {
                    let characterName = people[index].name
                    DuckDuckGoSearchController.image(for: characterName) {_ in }
                }
                
            }
        }
    }
    
    // Images load by DuckDuck..
    var imageByCharacterNameDict: [String: UIImage] = [:] {
        didSet {
            if imageByCharacterNameDict.count == people.count {
                // MARK: NotificationCenter - sending a signal that he get all character images
                NotificationCenter.default.post(name: .reloadTbl, object: nil)
                
            }
        }
    }
    
    // set by clicking on row in tbl - will used in CharacterDetailsViewController
    var charcterRowTapped: Character?
    
    // MARK: PopUp by BD btn - NotificationCenter - property get initialize by method of addObserver
    var popUpViewIndexCellTapped: Int?
    
    // MARK: PopUp by BD btn - NotificationCenter - method invoked when addObserver receive a broadcast
    func passingDataOfCellNumber(notification: Notification) -> Void {
        let rowNumber = notification.userInfo!["rowNumber"] as? Int
        if let index = rowNumber {
            popUpViewIndexCellTapped = index
        }
    }

    // because it's private (set) The only way to modify those properties is via the requestData() method
    private (set) var characterMovies: [String]?
    private (set) var characterName: String?
    
    //Once we receive data in requestData, we save it in a local variable (TapAllMoviesBtn in TVC)
    func requestDataForCharacterMovies(rowNumberFromTbl: Int) {
        
        let character = people[rowNumberFromTbl]
        let moviesUrlArr = character.moviesUrlArr
        var moviesStrArr:[String] = []
        for movieUrl in moviesUrlArr {
            if let movieStr = moviesNamesByUrlsDict[movieUrl] {
                moviesStrArr.append(movieStr)
            }
        }
        
        self.characterMovies = moviesStrArr
        self.characterName = character.name
    }
    
    func getSwapiTypeFromUrlPage(swapiType: UrlSwapiType, fromPage: Int, getAllNextPages: Bool) {
        
        // This inside func used after we ger result from swapi by alamofire
        func getResultSwapiTypeUrlPage(tempNamesByUrlsDict: [String:String], swapiType: UrlSwapiType) {
            
            switch swapiType {
            case .VEHICLES:
                // forEach: will iterate every key value from tempDict.
                // inside that closure we had all keys values to the other dict (vehiclesNameByUrl)
                tempNamesByUrlsDict.forEach { self.vehiclesNamesByUrlsDict[$0] = $1 } // add dict to dict
            case .MOVIES:
                tempNamesByUrlsDict.forEach { self.moviesNamesByUrlsDict[$0] = $1 }
            case .STAR_SHIPS:
                tempNamesByUrlsDict.forEach { self.starshipsNamesByUrlsDict[$0] = $1 }
            case .HOME_WORLD:
                tempNamesByUrlsDict.forEach { self.homeworldNamesByUrlsDict[$0] = $1 }
            }
        }
        
        let swapiTypeStr = swapiType.rawValue
        let urlPage = "\(baseUrl)\(swapiTypeStr)?page=\(fromPage)"
        Alamofire.request(urlPage).responseJSON(completionHandler: { (response) in
            guard response.error == nil else {
                print("Error in getting data api from url: \(urlPage), message: \(response.error?.localizedDescription)")
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
    
    //MARK: Swapi Types: Dictionary properties (Vehicles, Movies, Starships, Homeworld) stay in class singleton and can be used across the app
    private (set) var vehiclesNamesByUrlsDict:[String:String] = [:]
    private (set) var moviesNamesByUrlsDict:[String: String] = [:]
    private (set) var starshipsNamesByUrlsDict:[String:String] = [:]
    private (set) var homeworldNamesByUrlsDict:[String:String] = [:]
    
    enum UrlSwapiType: String {
        case VEHICLES = "vehicles/"
        //case PEOPLE = "people/"
        case MOVIES = "films/"
        case STAR_SHIPS = "starships/"
        case HOME_WORLD = "planets/"
    }
    
    func getAllPeopleInPageSwapiApi(pageNumber: Int, completion:  @escaping () -> ()) {
        
        let pageNum = "?page=\(pageNumber)" // each page give 10 characters
        
        let url = "\(baseUrl)people/\(pageNum)"
        
        var newCharacters:[Character] = []
        
        Alamofire.request(url).responseJSON { (response) in
            
            guard response.error == nil  else {
                print("*\nError retreiving data from swapi api: \(response.error.debugDescription)")
                return
            }
            
            if let json = response.result.value as? [String:Any] {
                //print(json)
                
                // initialize totalNumOfPeople only at first time calling
                if self.totalNumOfPeopleInSwapiApi == nil {
                    if let totalNumOfPeople = json["count"] as? Int {
                        self.totalNumOfPeopleInSwapiApi = totalNumOfPeople
                    }
                }
                
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
                        newCharacters.append(character)
                    }
                    
                    // add 10 characters to self.people instead 1 every time, it will make if statement inside didSet in people to check only after 10 characters is added to people property
                    self.people.append(contentsOf: newCharacters)
                }
            }
            
            // In here (Alamofire.request - response) - after getting and load all characters  into people: [Character] we add completion that will 'escape' from here and load it in tbl in TableViewController
            completion()
        }
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




