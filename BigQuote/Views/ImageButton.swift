//
//  ImageButton.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class ImageButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.2
    }

    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.imageRectForContentRect(contentRect)
        rect.origin.x = (bounds.width - rect.width) / 2
        rect.origin.y = 0
        return rect
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.titleRectForContentRect(contentRect)
        rect.origin.x = (bounds.width - rect.width) / 2
        rect.origin.y = bounds.height - rect.height
        return rect
    }
}
