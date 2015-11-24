//
//  QuotesListController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import CoreData

class QuotesListController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var quotePredicate = NSPredicate() {
        didSet {
            fetchResultsController.fetchRequest.predicate = quotePredicate
        }
    }
    
    lazy var fetchResultsController: NSFetchedResultsController = {
        let request = Quote.fetchRequest()
        request.predicate = self.quotePredicate
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: CoreDataStackManager.defaultManager.managedObjectContext,
            sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchResultsController.performFetch()
        } catch let error as NSError {
            print("HashtagsTableViewController error \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Navigations
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.QuotesListToQuote {
            let vc = segue.destinationViewController as! QuoteDetailViewController
            vc.quote = sender as! Quote
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("QuoteViewCell", forIndexPath: indexPath) as! QuoteViewCell
        
        // Configure the cell
        let quote = fetchResultsController.objectAtIndexPath(indexPath) as! Quote
        
        cell.quoteView.backgroundColor = quote.backgroundColor
        cell.quoteView.textColor = quote.textColor
        cell.quoteView.backgroundImage = quote.backgroundImage
        cell.quoteView.quote = quote.text!
        cell.quoteView.author = quote.author!.name!
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let quote = fetchResultsController.objectAtIndexPath(indexPath) as! Quote
        performSegueWithIdentifier(SegueIdentifier.QuotesListToQuote, sender: quote)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.reloadData()
    }
}
