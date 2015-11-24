//
//  Quote+CoreDataProperties.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Quote {

    @NSManaged var createdAt: NSDate?
    @NSManaged var text: String?
    @NSManaged var backgroundColorCode: String?
    @NSManaged var fontName: String?
    @NSManaged var textColorCode: String?
    @NSManaged var backgroundImageFilename: String?
    @NSManaged var author: Author?
    @NSManaged var tags: NSSet?

}
