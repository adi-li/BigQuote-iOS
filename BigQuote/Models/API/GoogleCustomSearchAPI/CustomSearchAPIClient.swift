//
//  CustomSearchAPIClient.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class CustomSearchAPIClient: APIClient {
    static let client = CustomSearchAPIClient()
    
    override class var BaseURL: NSURL { return NSURL(string: "https://www.googleapis.com/customsearch/v1")! }
    override class var ErrorDomain: String { return "CustomSearchAPIClientErrorDomain" }
    
    func searchImageWithQuery(query: String, completion: CompletionHandler?) {
        let parameters: Parameters = [
            "key": Config.GoogleAPIKey,
            "cx": Config.CustomSearchEngineID,
            "searchType": "image",
            "imgSize": "large",
            "q": query
        ]
        taskForGET("", parameters: parameters, completion: completion)
    }
}
