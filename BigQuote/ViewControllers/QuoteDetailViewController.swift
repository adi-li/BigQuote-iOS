//
//  QuoteDetailViewController.swift
//  BigQuote
//
//  Created by Adi Li on 24/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class QuoteDetailViewController: UIViewController {

    @IBOutlet weak var quoteView: QuoteView!
    
    var quote: Quote!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        quoteView.backgroundColor = quote.backgroundColor
        quoteView.textColor = quote.textColor
        quoteView.backgroundImage = quote.backgroundImage
        quoteView.quote = quote.text!
        quoteView.author = quote.author!.name!
    }
    
    @IBAction func shareQuote(sender: AnyObject) {
        let image = UIImage.fromView(quoteView, afterScreenUpdates: true)
        let text = "\"\(quote.text!)\", by \(quote.author!)"
        
        let activityVC = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
}
