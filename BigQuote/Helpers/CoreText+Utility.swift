//
//  CoreText+Utility.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import CoreText

extension CTFontRef {
    
    class func fromURL(URL: NSURL, forSize size: CGFloat) -> CTFontRef? {
        let provider = CGDataProviderCreateWithURL(URL)
        guard let cgFont = CGFontCreateWithDataProvider(provider) else {
            return nil
        }
        return CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
    }
    
}

