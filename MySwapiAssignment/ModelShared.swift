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
    
    var totalNumOfPeopleInSwapiApi: Int? // initialize only once - from SwapiSearch getAllPeople.. func
    var isReloadTblFirstTimeForTotalPeopleArrived = false
    var reloadTblAfterEveryImagesNumAdded = 20
    var lastRowsUpdateWithImages = 0
    var lastPeopleUpdate = 0
    
    var people:[Character] = [] { //Update from SwapiSearch getAllPeople... after every page (10 characters)
        didSet {
            
            print("people.count = \(people.count)")
            
            // Check if reload tbl is for first time - total characters already in people property (87 characters) then stop indicator replace alpha image with tbl (and change isReloadTblFirstTimeForPeopleTotalArrived boolean to false
            if people.count == totalNumOfPeopleInSwapiApi {
                NotificationCenter.default.post(name: .stopIndicatorReloadTbl, object: nil)
                isReloadTblFirstTimeForTotalPeopleArrived = true
            }
            
            for index in lastPeopleUpdate..<people.count { // 0-10, 10-20 and etc'.. each page
                let characterName = modelShared.people[index].name
                DuckDuckGoSearchImage.trySearchAgainOnNameIfError.append(characterName)
                DuckDuckGoSearchImage.image(for: characterName) { _ in }
            }
            lastPeopleUpdate = people.count
        }
    }
    
    // Images by characters names - people didSet get images from DuckDuck
    var imageByCharacterNameDict: [String: Data?] = [:] {
        didSet {
            // Check also if the first time reload tbl already done
            if isReloadTblFirstTimeForTotalPeopleArrived {
                print("imageByCharacterNameDict.count \(imageByCharacterNameDict.count)")
                NotificationCenter.default.post(name: .reloadImagesIntoTheirCells, object: nil)
            }
        }
    }
    
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








