//
//  URLImageView.swift
//  BigQuote
//
//  Created by Adi Li on 23/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class URLImageView: UIImageView {

    var URL: NSURL?
    
    var URLString: String? {
        get {
            return URL?.absoluteString
        }
        set {
            guard let link = newValue else {
                URL = nil
                return
            }
            URL = NSURL(string: link)
        }
    }
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.center = CGPoint(
            x: self.bounds.width / 2,
            y: self.bounds.height / 2)
        view.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        view.hidesWhenStopped = true
        self.addSubview(view)
        return view
    }()
    
    func loadImage() {
        image = nil
        
        guard let URL = URL else {
            return
        }
        
        loadingView.startAnimating()
        
        ImageCacher.defaultCacher.imageForURL(URL) { [weak self] (image) -> Void in
            self?.loadingView.stopAnimating()
            
            guard URL == self?.URL else {
                return
            }
            
            guard image != nil else {
                return
            }
            
            self?.image = image
        }
        
        
    }
}
