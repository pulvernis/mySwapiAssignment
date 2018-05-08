//
//  DuckDuckGoSearchImage.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 17/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit
import Alamofire

// image() func use character name and encode it, then.. i'm use alamofire to get responseJson from api.duckduckgo.com
// i'm transfering the responseJson to [string:Any] dictionary and taking out the Image Url as String
// i'm  sending it to imageSearchResult() func that use alamofire to request the real image data by this Image Url String by using response (and NOT responseJson)
// every image data goes to Model into dict property (imageByCharacterNameDic) contain character name and UIImage respectively

struct DuckDuckGoSearchImage {
    
    static let IMAGE_KEY = "Image"
    static var trySearchAgainOnNameIfError:[String] = []
    
    static func image(for name: String, completionHandler: @escaping (Data?) -> Void) {
        //trySearchAgainOnName.append(name)
        let searchString = name//"Luke Skywalker"
        // Get the search URL
        guard let searchURLString = endpoint(for: searchString) else {
            return
        }
        // Call the search URL
        Alamofire.request(searchURLString).responseJSON { response in
            
            if response.result.error != nil {
                // TODO: try again but only once:
                for (index, nameInSearch) in trySearchAgainOnNameIfError.enumerated() {
                    if name == nameInSearch {
                        image(for: name) {_ in}
                        trySearchAgainOnNameIfError.remove(at: index)
                        print("try again to search image: \(name)")
                    }
                }
                
                print("*\n\"DuckDuck..\nerror in - \(searchURLString)\n error is: \(response.result.error!.localizedDescription)")
                return
            }
            
            // make sure we got JSON and it's a dictionary
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get image search result as JSON from API")
                return
            }
            //make sure we got Image Url and it's a string
            guard let imageURL = json[IMAGE_KEY] as? String else {
                print("didn't get URL for image from search results")
                return
            }
            
            // Get the image by Image Url
            DuckDuckGoSearchImage.imageSearchResult(from: imageURL) { imageDataResult in
                // return the image
                modelShared.imageByCharacterNameDict[name] = imageDataResult
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
    
    private static func imageSearchResult(from imageUrl: String, completionHandler: @escaping (Data?) -> Void) {
        // get the image:
        // To get the actual data in the response instead of JSON, we hook up .response as a response handler instead of .responseJSON.
        Alamofire.request(imageUrl).response { response in
                /*guard let imageData = response.data else {
                    print("Could not get character image by imageUrl: \(imageUrl)")
                    return
                }*/
            let imageData = response.data
            
            completionHandler(imageData)
        }
    }
    
}
