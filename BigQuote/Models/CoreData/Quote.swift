//
//  Quote.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Quote: BaseManagedObject {

    var backgroundColor: UIColor? {
        get {
            guard backgroundColorCode != nil else {
                return nil
            }
            return UIColor.fromRGBARepresentation(backgroundColorCode!)
        }
        set {
            backgroundColorCode = newValue?.RGBARepresentation
        }
    }
    
    var textColor: UIColor? {
        get {
            guard textColorCode != nil else {
                return nil
            }
            return UIColor.fromRGBARepresentation(textColorCode!)
        }
        set {
            textColorCode = newValue?.RGBARepresentation
        }
    }
    
    var backgroundImage: UIImage? {
        get {
            guard backgroundImageFilename != nil else {
                return nil
            }
            guard let data = NSData(contentsOfURL: backgroundImageFileURL!) else {
                return nil
            }
            return UIImage(data: data)
        }
        set {
            if newValue == nil {
                deleteImage()
            } else {
                saveImage(newValue!)
            }
        }
    }
    
    var backgroundImageFileURL: NSURL? {
        guard backgroundImageFilename != nil else {
            return nil
        }
        return NSFileManager.defaultManager().applicationDocumentsDirectory.URLByAppendingPathComponent(backgroundImageFilename!)
    }
    
    private func deleteImage() {
        guard backgroundImageFilename != nil else {
            return
        }
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(backgroundImageFileURL!)
        } catch let error as NSError {
            print("Delete file error \(error), \(error.userInfo)")
        }
        
        backgroundImageFilename = nil
    }
    
    private func saveImage(image: UIImage) {
        if backgroundImageFilename == nil {
            backgroundImageFilename = generateUniqueFilename()
        }
        let data = UIImagePNGRepresentation(image)
        data?.writeToURL(backgroundImageFileURL!, atomically: true)
    }
    
    private func generateFilename() -> String {
        return "quote-\(NSUUID().UUIDString).png"
    }
    
    func generateUniqueFilename() -> String {
        var filename = generateFilename()
        var path = NSFileManager.defaultManager().applicationDocumentsDirectory.URLByAppendingPathComponent(filename).path!
        
        while NSFileManager.defaultManager().fileExistsAtPath(path) {
            filename = generateFilename()
            path = NSFileManager.defaultManager().applicationDocumentsDirectory.URLByAppendingPathComponent(filename).path!
        }
        
        return filename
    }

    
    // MARK: - NSManagedObject overrides
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        // Delete the underlying file also
        deleteImage()
    }
}
