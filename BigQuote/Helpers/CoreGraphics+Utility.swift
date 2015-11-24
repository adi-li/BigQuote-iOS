//
//  CoreGraphics+Utility.swift
//  BigQuote
//
//  Created by Adi Li on 21/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    init(_ value: String) {
        self.init((value as NSString).doubleValue)
    }
}