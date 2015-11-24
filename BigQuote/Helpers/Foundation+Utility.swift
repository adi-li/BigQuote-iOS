//
//  Foundation+Utility.swift
//  BigQuote
//
//  Created by Adi Li on 21/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

extension String {
    
    init?(dictionary: [String: AnyObject]) {
        let data: NSData
        do {
            try data = NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        } catch {
            return nil
        }
        self.init(data: data, encoding: NSUTF8StringEncoding)
    }
}
