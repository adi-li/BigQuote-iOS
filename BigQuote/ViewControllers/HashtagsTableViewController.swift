//
//  HashtagsTableViewController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import CoreData

class HashtagsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, QuoteGeneratorViewControllerDelegate {
    
    lazy var fetchResultsController: NSFetchedResultsController = {
        let request = Hashtag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
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
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let hashtag = fetchResultsController.objectAtIndexPath(indexPath) as! Hashtag
        
        cell.textLabel?.text = hashtag.text
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hashtag = fetchResultsController.objectAtIndexPath(indexPath) as! Hashtag
        performSegueWithIdentifier(SegueIdentifier.HashtagsToQuotesList, sender: hashtag)
    }
    
    // MARK: - Navigations

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.HashtagsToGenerator {
            let vc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! QuoteGeneratorViewController
            vc.delegate = self
            
        } else if segue.identifier == SegueIdentifier.HashtagsToQuote {
            let vc = segue.destinationViewController as! QuoteDetailViewController
            vc.quote = sender as! Quote
            
        } else if segue.identifier == SegueIdentifier.HashtagsToQuotesList {
            let vc = segue.destinationViewController as! QuotesListController
            let tag = sender as! Hashtag
            vc.title = tag.text
            vc.quotePredicate = NSPredicate(format: "ANY tags = %@", tag)
            
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    // MARK: - QuoteGeneratorViewControllerDelegate
    
    func quoteGenerator(generator: QuoteGeneratorViewController, didFinishWithQuote quote: Quote) {
        generator.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier(SegueIdentifier.HashtagsToQuote, sender: quote)
        }
    }
    
    func quoteGeneratorDidCancel(generator: QuoteGeneratorViewController) {
        generator.dismissViewControllerAnimated(true, completion: nil)
    }
}
