//
//  DuckDuckGoSearchImage.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 17/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit
import Alamofire

class DuckDuckGoSearchController {
    
    static let IMAGE_KEY = "Image"
    
    static func image(for name: String, completionHandler: @escaping (Data) -> Void) {
        let searchString = name//"Luke Skywalker"
        // Get the search URL
        guard let searchURLString = endpoint(for: searchString) else {
            return
        }
        // Call the search URL
        Alamofire.request(searchURLString).responseJSON { response in
                if response.result.error != nil {
                    print("error: \(response.result.error?.localizedDescription)")
                    return
                }
                // Get the image
                DuckDuckGoSearchController.imageSearchResult(from: response) { imageDataResult in
                    // return the image
                    Model.shared.imageByCharacterNameDict[name] = UIImage(data: imageDataResult)
                    completionHandler(imageDataResult)
                }
        }
    }
    
    private static func endpoint(for searchString: String) -> String? {
        // URL encode it, e.g., "Yoda's Species" -> "Yoda%27s%20Species"
        // Add star wars to search string for being more specific
        guard let encodedUrlString = "\(searchString) star wars".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        // create the search string
        return "https://api.duckduckgo.com/?q=\(encodedUrlString)&format=json"
        // e.g: https://api.duckduckgo.com/?q=Yoda%20star%20wars&format=json&t=grokswift
    }
    
    private static func imageSearchResult(from response: DataResponse<Any>, completionHandler: @escaping (Data) -> Void) {
        guard response.result.error == nil else {
            // got an error in getting the data, need to handle it
            print(response.result.error!)
            return
        }
        
        // make sure we got JSON and it's a dictionary
        guard let json = response.result.value as? [String: Any] else {
            print("didn't get image search result as JSON from API")
            return
        }
        
        guard let imageURL = json[IMAGE_KEY] as? String else {
            print("didn't get URL for image from search results")
            return
        }
        
        // get the image:
        // To get the actual data in the response instead of JSON, we hook up .response as a response handler instead of .responseJSON.
        Alamofire.request(imageURL).response { response in
                guard let imageData = response.data else {
                    print("Could not get image from image URL returned in search results")
                    
                    return
                }
            
            completionHandler(imageData)
        }
    }
    
}
