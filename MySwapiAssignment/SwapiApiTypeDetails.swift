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

class SwapiApiTypeDetails {

    static func getSwapiTypeFromUrlPage(swapiType: UrlSwapiType, fromPage: Int, getAllNextPages: Bool) {
        
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
                
                // invoke private func
                getResultSwapiTypeUrlPage(tempNamesByUrlsDict: tempNamesByUrlsDict, swapiType: swapiType)
                
                if getAllNextPages {
                    if (jsonResult["next"] as? String) != nil {
                        let nextPage = fromPage + 1
                        //print("*\nurlPage: \(next)")
                        getSwapiTypeFromUrlPage(swapiType: swapiType, fromPage: nextPage, getAllNextPages: true) // recursion
                    }
                }
            }
        })
        
    }
    
    // This func used after we get result from swapi by alamofire
    private static func getResultSwapiTypeUrlPage(tempNamesByUrlsDict: [String:String], swapiType: UrlSwapiType) {
        
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
    
    enum UrlSwapiType: String {
        case VEHICLES = "vehicles/"
        //case PEOPLE = "people/"
        case MOVIES = "films/"
        case STAR_SHIPS = "starships/"
        case HOME_WORLD = "planets/"
    }
    
}
