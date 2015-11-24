//
//  MarketplaceAPIClient.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

class MarketplaceAPIClient: APIClient {
    
    static let client = MarketplaceAPIClient()
    
    override class var BaseURL: NSURL { return NSURL(string: "https://andruxnet-random-famous-quotes.p.mashape.com/")! }
    override class var ErrorDomain: String { return "MarketplaceAPIClientErrorDomain" }
    
    enum Category: String {
        case Famous = "famous"
        case Movies = "movies"
    }
    
    // Override addAdditionalHeaderToRequest
    override func addAdditionalHeaderToRequest(request: NSMutableURLRequest) {
        super.addAdditionalHeaderToRequest(request)
        
        request.setValue(Config.MarketplaceAPIKey, forHTTPHeaderField: "X-Mashape-Key")
    }
    
    func getRandomQuoteWithCompletion(completion: CompletionHandler?) {
        let random = arc4random_uniform(2)
        // Random fetch category
        var category = Category.Famous
        if random > 0 {
            category = .Movies
        }
        getRandomQuoteFromCategory(category, completion: completion)
    }
    
    func getRandomQuoteFromCategory(category: Category, completion: CompletionHandler?) {
        taskForPOST("cat=\(category.rawValue)", parameters: nil, completion: completion)
    }
}
