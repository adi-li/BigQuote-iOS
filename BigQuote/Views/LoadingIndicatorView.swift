//
//  LoadingIndicatorView.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        view.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
        view.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        view.hidesWhenStopped = true
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }

    func showInView(view: UIView) {
        runOnMainThread { () -> Void in
            self.frame = view.bounds
            self.activityIndicatorView.startAnimating()
            view.addSubview(self)
        }
    }
    
    func hide() {
        runOnMainThread { [weak self] () -> Void in
            self?.activityIndicatorView.stopAnimating()
            self?.removeFromSuperview()
        }
    }

}
