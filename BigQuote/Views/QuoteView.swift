//
//  QuoteView.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class QuoteView: UIView {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var quoteView: UITextView!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var authorField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let view = NSBundle.mainBundle().loadNibNamed("QuoteView", owner: self, options: nil).first as! UIView
        view.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let placeholder = authorField.placeholder {
            authorField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                NSFontAttributeName: authorField.font ?? UIFont.systemFontOfSize(UIFont.systemFontSize()),
                NSForegroundColorAttributeName: UIColor.lightGrayColor()
            ])
        }
    }
    
    var fontName: String? {
        get {
            return quoteView.font?.familyName
        }
        set {
            let fontName = newValue ?? "Roboto-Regular"
            quoteView.font = UIFont(name: fontName, size: 30)
            byLabel.font = UIFont(name: fontName, size: 17)
            authorField.font = UIFont(name: fontName, size: 20)
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return backgroundView.backgroundColor
        }
        set {
            backgroundView?.backgroundColor = newValue
        }
    }
    
    var backgroundImage: UIImage? {
        get {
            return backgroundView.image
        }
        set {
            backgroundView.image = newValue
        }
    }
    
    var textColor: UIColor? {
        get {
            return quoteView.textColor
        }
        set {
            quoteView.textColor = newValue
            byLabel.textColor = newValue
            authorField.textColor = newValue
        }
    }
    
    var quote: String {
        get {
            return quoteView.text!
        }
        set {
            quoteView.text = newValue
        }
    }
    
    var author: String {
        get {
            return authorField.text!
        }
        set {
            authorField.text = newValue
        }
    }
}
