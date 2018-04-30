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
import UIKit

class ModelShared {
    
    static let shared = ModelShared()
    
    private init() {
        // MARK: PopUp by BD btn - NotificationCenter - addObserver in Model init()
        NotificationCenter.default.addObserver(forName: .characterBirthDay, object: nil, queue: nil,
                                               using: passingDataOfCellNumber)
    }
    
    var firstLoadingPeopleAmount: Int? {
        didSet{
            // TODO: After loading 2 first pages of people, check that also the images for them arrived and then stop indicator and reload tbl
        }
    }
    
    var totalNumOfPeopleInEachPageInSwapiApi: Int?
    
    var totalNumOfPeopleInSwapiApi: Int? { // initialize only once - when i get the first page of people
        didSet {
            if let totalNumOfPeople = totalNumOfPeopleInSwapiApi { // ambivalent to - if it's not nil
                if let totalNumOfPeopleInEachPage = totalNumOfPeopleInEachPageInSwapiApi {
                    totalPagesOfPeopleInSwapiApi = totalNumOfPeople/totalNumOfPeopleInEachPage + 1
                }
            }
        }
    }
    
    // initialize from didSet{} when totalNumOfPeopleInSwapiApi is changing
    // Use for TVC
    private (set) var totalPagesOfPeopleInSwapiApi: Int?
    
    var people:[Character] = [] {
        didSet {
            if people.count == totalNumOfPeopleInSwapiApi {
                if imageByCharacterNameDict.count == firstLoadingPeopleAmount {
                    NotificationCenter.default.post(name: .stopIndicatorReloadMyTbl, object: nil)
                }
                
                // Get the rest images into imageByCharacterNameDict in ModelShared
                guard let firstLoadingAmount = modelShared.firstLoadingPeopleAmount,
                    let totalAmount = modelShared.totalNumOfPeopleInSwapiApi else {
                        return
                }
                for index in firstLoadingAmount..<totalAmount {
                    let characterName = modelShared.people[index].name
                    DuckDuckGoSearchImage.image(for: characterName) { _ in
                        if modelShared.imageByCharacterNameDict.count == totalAmount {
                            NotificationCenter.default.post(name: .reloadMyTbl, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    // Images by characters names
    var imageByCharacterNameDict: [String: Data?] = [:]
    
    // Set by clicking on row in tbl - will used in CharacterDetailsViewController
    var charcterRowTapped: Character?
    
    // MARK: PopUp by BD btn - NotificationCenter - property get initialize by method below
    var popUpViewIndexCellTapped: Int?
    
    // MARK: PopUp by BD btn - NotificationCenter - method invoked when addObserver receive a broadcast
    func passingDataOfCellNumber(notification: Notification) -> Void {
        let rowNumber = notification.userInfo!["rowNumber"] as? Int
        if let index = rowNumber {
            popUpViewIndexCellTapped = index
        }
    }

    // private (set) - The only way to modify those properties is via the requestData() method
    private (set) var characterMovies: [String]?
    private (set) var characterName: String?
    
    // Set the two properties above by TapAllMoviesBtn in HVC
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
    
    //MARK: Swapi Types: Dictionary properties (Vehicles, Movies, Starships, Homeworld) stay in class singleton and can be used across the app
    var vehiclesNamesByUrlsDict:[String:String] = [:]
    var moviesNamesByUrlsDict:[String: String] = [:]
    var starshipsNamesByUrlsDict:[String:String] = [:]
    var homeworldNamesByUrlsDict:[String:String] = [:]

}

struct Character {
    let name, gender, height, mass, eyeColor, hairColor, skinColor, birthYear, homeworldUrl: String
    let urlForCharacter: String
    let vehiclesUrlArr: [String] // need to call api again to get vehicles name chatacter owned
    let starshipsUrlArr: [String] // need to call api again to get starships names character owned
    let moviesUrlArr: [String]
    
}






