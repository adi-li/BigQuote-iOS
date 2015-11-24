//
//  QuoteGeneratorViewController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

protocol QuoteGeneratorViewControllerDelegate: class {
    func quoteGenerator(generator: QuoteGeneratorViewController, didFinishWithQuote quote: Quote)
    func quoteGeneratorDidCancel(generator: QuoteGeneratorViewController)
}

class QuoteGeneratorViewController: UIViewController, ParameterPickerViewControllerDelegate, ImageSearcherViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var backgroundColorButton: ImageButton!
    @IBOutlet weak var fontButton: ImageButton!
    @IBOutlet weak var textColorButton: ImageButton!
    @IBOutlet weak var quoteView: QuoteView!
    
    var selectingButton: ImageButton?
    
    weak var delegate: QuoteGeneratorViewControllerDelegate?
    
    lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()
    
    struct UserDefaultsKey {
        static let lastBackgroundColorCodeKey = "lastBackgroundColorCode"
        static let lastTextColorCodeKey = "lastTextColorCode"
        static let lastFontNameKey = "lastFontName"
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quoteView.quoteView.delegate = self
        quoteView.authorField.delegate = self
        
        // Resotre last settings
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        quoteView.quoteView.text = "Quote"
        if let colorCode = userDefaults.stringForKey(UserDefaultsKey.lastBackgroundColorCodeKey) {
            quoteView.backgroundColor = UIColor.fromRGBARepresentation(colorCode)
        }
        if let colorCode = userDefaults.stringForKey(UserDefaultsKey.lastTextColorCodeKey) {
            quoteView.textColor = UIColor.fromRGBARepresentation(colorCode)
        }
        quoteView.fontName = userDefaults.stringForKey(UserDefaultsKey.lastFontNameKey)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if quoteView.quote == "Quote" {
            quoteView.quoteView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    // MARK: - User actions

    @IBAction func cancelCreation(sender: UIBarButtonItem) {
        delegate?.quoteGeneratorDidCancel(self)
    }
    
    @IBAction func saveQuote(sender: UIBarButtonItem) {
        let quote = Quote()
        quote.text = quoteView.quote
        quote.author = Author.getOrCreateWithName(quoteView.author)
        quote.fontName = quoteView.fontName
        quote.backgroundColor = quoteView.backgroundColor
        quote.textColor = quoteView.textColor
        quote.backgroundImage = quoteView.backgroundImage
        quote.createdAt = NSDate()
        
        let tagStrings = tagsField.text!.componentsSeparatedByString(",")
        var tags = Set<Hashtag>()
        for tagString in tagStrings {
            let trimmedString = tagString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !trimmedString.isEmpty {
                let tag = Hashtag.getOrCreateWithName(trimmedString)
                tags.insert(tag)
            }
        }
        
        quote.tags = tags
        
        CoreDataStackManager.defaultManager.saveContext()
        
        delegate?.quoteGenerator(self, didFinishWithQuote: quote)
    }
    
    @IBAction func selectParameter(sender: ImageButton) {
        performSegueWithIdentifier(SegueIdentifier.GeneratorToParameterPicker, sender: sender)
    }
    
    @IBAction func getRandomQuote(sender: UIButton) {
        loadingView.showInView(view)
        MarketplaceAPIClient.client.getRandomQuoteWithCompletion { (data, error) -> Void in
            self.loadingView.hide()
            
            guard error == nil else {
                UIAlertController.alertControllerWithTitle("Getting random quote error", message: error?.localizedDescription).showFromViewController(self)
                return
            }
            
            guard let dict = data else {
                UIAlertController.alertControllerWithTitle("Getting random quote error", message: "Cannot parse data").showFromViewController(self)
                return
            }
            
            runOnMainThread({ () -> Void in
                self.quoteView.quote = (dict["quote"] as? String) ?? ""
                self.quoteView.author = (dict["author"] as? String) ?? ""
            })
        }
    }
    
    lazy var imageSelectionSheet: UIAlertController = {
        let actionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Album", style: .Default, handler: { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Search in Web", style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier(SegueIdentifier.GeneratorToImageSearcher, sender: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            
        }))
        return actionSheet
    }()
    
    @IBAction func selectBackgroundImage(sender: UIButton) {
        presentViewController(imageSelectionSheet, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.GeneratorToParameterPicker {
            // To ParameterPicker
            selectingButton = (sender as! ImageButton)
            
            let picker = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ParameterPickerViewController
            
            picker.delegate = self
            let plistPath: String
            
            switch selectingButton! {
            case fontButton:
                picker.title = "Font"
                plistPath = NSBundle.mainBundle().pathForResource("Fonts", ofType: "plist")!
            case textColorButton:
                picker.title = "Text Color"
                plistPath = NSBundle.mainBundle().pathForResource("Colors", ofType: "plist")!
            default:
                picker.title = "Background Color"
                plistPath = NSBundle.mainBundle().pathForResource("Colors", ofType: "plist")!
            }
            
            picker.choices = NSArray(contentsOfFile: plistPath) as! [AnyObject]
            
        } else if segue.identifier == SegueIdentifier.GeneratorToImageSearcher {
            // To ImageSearcher
            let searcher = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ImageSearcherViewController
            searcher.delegate = self
        }
    }
    
    // MARK: - Keyboard notifications handling
    
    var currentEditingTextField: UITextField?
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if currentEditingTextField != nil {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var image: UIImage?
        
        // Get image from edited image or original image
        let keyChains = [UIImagePickerControllerEditedImage, UIImagePickerControllerOriginalImage]
        
        for key in keyChains {
            image = info[key] as? UIImage
            if image != nil {
                break
            }
        }
        
        // Reset with image
        quoteView.backgroundImage = image
        
        // Dismiss the picker
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ParameterPickerViewControllerDelegate
    
    func pickerDidCancel(picker: ParameterPickerViewController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func picker(picker: ParameterPickerViewController, didSelectChoice choice: AnyObject) {
        switch selectingButton! {
        case fontButton:
            let fontName = choice as! String
            quoteView.fontName = fontName
            NSUserDefaults.standardUserDefaults().setObject(fontName, forKey: UserDefaultsKey.lastFontNameKey)
            
        case textColorButton:
            let colorData = choice as! [String: String]
            guard let colorCode = colorData["hexCode"] else {
                return
            }
            NSUserDefaults.standardUserDefaults().setObject(colorCode, forKey: UserDefaultsKey.lastTextColorCodeKey)
            quoteView.textColor = UIColor.fromRGBARepresentation(colorCode)
            
        default:
            let colorData = choice as! [String: String]
            guard let colorCode = colorData["hexCode"] else {
                return
            }
            NSUserDefaults.standardUserDefaults().setObject(colorCode, forKey: UserDefaultsKey.lastBackgroundColorCodeKey)
            quoteView.backgroundColor = UIColor.fromRGBARepresentation(colorCode)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func picker(picker: ParameterPickerViewController, configTableCell cell: UITableViewCell, forChoice choice: AnyObject) {
        
        switch selectingButton! {
        case fontButton:
            let fontName = choice as! String
            
            var text = quoteView.quote
            if text.isEmpty {
                text = fontName
            }
            
            cell.textLabel?.font = UIFont(name: fontName, size: UIFont.systemFontSize())
            cell.textLabel?.text = text
            cell.textLabel?.textColor = UIColor.blackColor()
            
            cell.backgroundColor = UIColor.whiteColor()
            
        default:
            let colorData = choice as! [String: String]
            
            cell.textLabel?.font = nil
            cell.textLabel?.text = nil
            
            cell.backgroundColor = UIColor.grayColor()
            
            guard let colorCode = colorData["hexCode"] else {
                return
            }
            
            guard let name = colorData["name"] else {
                return
            }
            
            cell.textLabel?.textColor = UIColor.fromRGBARepresentation(colorCode)
            cell.textLabel?.text = name
        }
        
    }
    
    // MARK: - ImageSearcherViewControllerDelegate
    
    func imageSearcher(searcher: ImageSearcherViewController, didSelectImage image: UIImage) {
        quoteView.backgroundImage = image
        searcher.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageSearcherDidCancel(searcher: ImageSearcherViewController) {
        searcher.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        currentEditingTextField = textField
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        currentEditingTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
