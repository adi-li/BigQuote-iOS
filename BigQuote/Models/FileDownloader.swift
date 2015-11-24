//
//  FileDownloader.swift
//  Big Quote
//
//  Created by Adi Li on 15/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import UIKit

class FileDownloader {
    
    typealias CompletionHandler = (String, NSError?) -> Void
    
    static let downloader = FileDownloader()
    
    var session = NSURLSession.sharedSession()
    var downloadingTasks = [NSURL: [CompletionHandler?]]()
    // For atomic downloading tasks change
    let semaphore = dispatch_semaphore_create(1)
    
    func downloadFileWithURLString(URLString: String, toFileURL path: NSURL, completion: CompletionHandler?) {
        guard let URL = NSURL(string: URLString) else {
            return
        }
        downloadFileWithURL(URL, toFileURL: path, completion: completion)
    }
    
    func downloadFileWithURL(URL: NSURL, toFileURL path: NSURL, completion: CompletionHandler?) {
        downloadFileWithRequest(NSURLRequest(URL: URL), toFileURL: path, completion: completion)
    }
    
    func downloadFileWithRequest(request: NSURLRequest, toFileURL path: NSURL, completion: CompletionHandler?) {
        
        // Ensure request has URL
        guard let requestURL = request.URL else {
            completion?("", NSError(domain: "FileDownloaderErrorDomain", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Request has no URL"
            ]))
            return
        }
        
        // Make this function atomic
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        defer {
            dispatch_semaphore_signal(semaphore)
        }
        
        // If key path exist, means downloading, return immedaiately
        guard downloadingTasks[requestURL] == nil else {
            downloadingTasks[requestURL]!.append(completion)
            return
        }
        
        // Append new completion
        downloadingTasks[requestURL] = []
        downloadingTasks[requestURL]!.append(completion)
        
        // Create task
        let task = session.downloadTaskWithRequest(request) { (URL, response, error) -> Void in
            
            // Remove task when it is done
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            let completions = self.downloadingTasks[requestURL]!
            self.downloadingTasks.removeValueForKey(requestURL)
            dispatch_semaphore_signal(self.semaphore)
            
            // Error handling
            guard error == nil else {
                self.runCompletionsOnMainThreadWithRequestURL(requestURL, error: error, completions: completions)
                return
            }
            
            // Ensure URL is not nil
            guard URL != nil else {
                let error = NSError(domain: "FileDownloaderErrorDomain", code: -2, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot find downloaded file"
                ])
                self.runCompletionsOnMainThreadWithRequestURL(requestURL, error: error, completions: completions)
                return
            }
            
            // Copy file
            do {
                try NSFileManager.defaultManager().copyItemAtURL(URL!, toURL: path)
            } catch let error as NSError {
                self.runCompletionsOnMainThreadWithRequestURL(requestURL, error: error, completions: completions)
                return
            }
            
            // Run all completions queue
            self.runCompletionsOnMainThreadWithRequestURL(requestURL, error: nil, completions: completions)
        }
        
        // Start task
        task.resume()
    }
    
    private func runCompletionsOnMainThreadWithRequestURL(requestURL: NSURL, error: NSError?, completions: [CompletionHandler?]) {
        for completion in completions {
            runOnMainThread { () -> Void in
                completion?(requestURL.absoluteString, error)
            }
        }
    }
}