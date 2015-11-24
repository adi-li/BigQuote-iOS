//
//  ImageCacher.swift
//  BigQuote
//
//  Created by Adi Li on 23/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class ImageCacher {
    
    static let defaultCacher = ImageCacher()
    
    typealias CompletionHandler = (UIImage?) -> Void
    
    var imageCache = NSCache()
    
    var completions = [String: [CompletionHandler?]]()
    let semaphore = dispatch_semaphore_create(1)
    
    // MARK: - Life cycle
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMemoryWarning", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    func didReceiveMemoryWarning() {
        imageCache.removeAllObjects()
    }
    
    // MARK: - Get / Set
    
    func setImage(image: UIImage, forURL URL: NSURL) {
        setImage(image, forKey: URL.absoluteString)
    }
    
    func setImage(image: UIImage, forKey key: String) {
        imageCache.setObject(imageCache, forKey: key)
    }
    
    func imageForURL(URL: NSURL, completion: CompletionHandler?) {
        imageForKey(URL.absoluteString, completion: completion)
    }
    
    func imageForKey(key: String, completion: CompletionHandler?) {
        if let image = imageCache.objectForKey(key) as? UIImage {
            runOnMainThread { () -> Void in
                completion?(image)
            }
            return
        }
        
        guard let URL = NSURL(string: key) else {
            runOnMainThread { () -> Void in
                completion?(nil)
            }
            return
        }
        
        downloadImageWithURL(URL, completion: completion)
    }
    
    // MARK: - Download Image
    
    func downloadImageWithURL(URL: NSURL, completion: CompletionHandler?) {
        
        // Make this function atomic
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        defer {
            dispatch_semaphore_signal(semaphore)
        }
        
        let URLString = URL.absoluteString
        
        // If key path exist, means downloading, return immedaiately
        guard completions[URLString] == nil else {
            completions[URLString]!.append(completion)
            return
        }
        
        // Append new completion
        completions[URLString] = []
        completions[URLString]!.append(completion)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            guard let data = NSData(contentsOfURL: URL) else {
                self.runCompletionsOnMainThreadWithImage(nil, forKey: URLString)
                return
            }
            
            runOnMainThread({ () -> Void in
                guard let image = UIImage(data: data) else {
                    self.runCompletionsOnMainThreadWithImage(nil, forKey: URLString)
                    return
                }
                
                self.setImage(image, forKey: URLString)
                self.runCompletionsOnMainThreadWithImage(image, forKey: URLString)
            })
            
        }
    }
    
    private func runCompletionsOnMainThreadWithImage(image: UIImage?, forKey key: String) {
        // Remove task when it is fail
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let completions = self.completions[key]!
        self.completions.removeValueForKey(key)
        dispatch_semaphore_signal(semaphore)
        
        for completion in completions {
            runOnMainThread { () -> Void in
                completion?(image)
            }
        }
    }
}
