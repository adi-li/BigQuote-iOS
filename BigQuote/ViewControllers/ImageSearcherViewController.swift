//
//  ImageSearcherViewController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

protocol ImageSearcherViewControllerDelegate: class {
    func imageSearcher(searcher: ImageSearcherViewController, didSelectImage image: UIImage)
    func imageSearcherDidCancel(searcher: ImageSearcherViewController)
}

class ImageSearcherViewController: UICollectionViewController, UISearchBarDelegate {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    var imageLinks = [String]()
    
    weak var delegate: ImageSearcherViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - User actions
    
    @IBAction func cancelSearching(sender: AnyObject) {
        delegate?.imageSearcherDidCancel(self)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text where !text.isEmpty else {
            return
        }
        CustomSearchAPIClient.client.searchImageWithQuery(text) { (data, error) -> Void in
            self.imageLinks.removeAll()
            
            guard error == nil else {
                var message = error?.localizedDescription
                if error!.domain == CustomSearchAPIClient.ErrorDomain {
                    if let err = error?.userInfo["Data"]?["error"] as? String {
                        message = err
                    }
                }
                UIAlertController.alertControllerWithTitle("Search error", message: message).showFromViewController(self)
                return
            }
            
            guard let dict = data else {
                UIAlertController.alertControllerWithTitle("Search error", message: "Cannot parse data").showFromViewController(self)
                return
            }
            
            guard let items = dict["items"] as? [[String: AnyObject]] else {
                UIAlertController.alertControllerWithTitle("Search error", message: "Cannot parse data[items]").showFromViewController(self)
                return
            }
            
            for item in items {
                guard let link = item["link"] as? String else {
                    continue
                }
                self.imageLinks.append(link)
            }
            
            runOnMainThread { () -> Void in
                if items.count == 0 {
                    UIAlertController.alertControllerWithTitle("Search error", message: "No results").showFromViewController(self)
                }
                self.collectionView?.reloadData()
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLinks.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageSearcherCell", forIndexPath: indexPath) as! ImageSearcherCell
    
        // Configure the cell
        cell.imageView.URLString = imageLinks[indexPath.row]
        cell.imageView.loadImage()
    
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.allowsSelection = false
        ImageCacher.defaultCacher.imageForKey(imageLinks[indexPath.row]) { (image) -> Void in
            self.delegate?.imageSearcher(self, didSelectImage: image!)
        }
    }

}
