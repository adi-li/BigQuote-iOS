//
//  UIKit+Utility.swift
//  BigQuote
//
//  Created by Adi Li on 21/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

// UIColor+RGBARepresentation

extension UIColor {
    var RGBARepresentation: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return "\(red) \(green) \(blue) \(alpha)"
    }
    
    class func fromRGBARepresentation(rgbaString: String) -> UIColor? {
        let rgba = rgbaString.componentsSeparatedByString(" ")
        guard rgba.count == 4 else {
            return nil
        }
        return UIColor(
            red: CGFloat(rgba[0]),
            green: CGFloat(rgba[1]),
            blue: CGFloat(rgba[2]),
            alpha: CGFloat(rgba[3])
        )
    }
}


// UIAlertController+Utility

extension UIAlertController {
    
    class func alertControllerWithTitle(title: String?, message: String?) -> Self {
        let alert = self.init(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alert
    }
    
    func showFromViewController(vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        runOnMainThread { () -> Void in
            vc.presentViewController(self, animated: animated, completion: completion)
        }
    }
}

// UIImage+FromView

extension UIImage {
    class func fromView(view: UIView, afterScreenUpdates: Bool) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: afterScreenUpdates)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}