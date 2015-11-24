//
//  Author.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData


class Author: BaseManagedObject {

    class func getOrCreateWithName(name: String) -> Author {
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        var objects = [Author]()
        do {
            objects = try CoreDataStackManager.defaultManager.managedObjectContext.executeFetchRequest(request) as! [Author]
        } catch let error as NSError {
            print("Hashtag.getOrCreateWithName error \(error), \(error.userInfo)")
        }
        
        var author = objects.first
        
        if author == nil {
            author = Author()
            author!.name = name
        }
        
        return author!
    }

}
