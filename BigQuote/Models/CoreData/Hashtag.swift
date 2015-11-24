//
//  Hashtag.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData


class Hashtag: BaseManagedObject {

    class func getOrCreateWithName(name: String) -> Hashtag {
        let lowerName = name.lowercaseString
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "text = %@", lowerName)
        var objects = [Hashtag]()
        do {
            objects = try CoreDataStackManager.defaultManager.managedObjectContext.executeFetchRequest(request) as! [Hashtag]
        } catch let error as NSError {
            print("Hashtag.getOrCreateWithName error \(error), \(error.userInfo)")
        }
        
        var tag = objects.first
        
        if tag == nil {
            tag = Hashtag()
            tag?.text = lowerName
        }
        
        return tag!
    }

}
