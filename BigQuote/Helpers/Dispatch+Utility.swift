//
//  Dispatch+Utility.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation


func runOnMainThread(block: dispatch_block_t) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}