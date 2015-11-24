//
//  AuthorsTableViewController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import CoreData

class AuthorsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, QuoteGeneratorViewControllerDelegate {
    
    lazy var fetchResultsController: NSFetchedResultsController = {
        let request = Author.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
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
            print("AuthorsTableViewController error \(error), \(error.userInfo)")
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
        let author = fetchResultsController.objectAtIndexPath(indexPath) as! Author

        cell.textLabel?.text = author.name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let author = fetchResultsController.objectAtIndexPath(indexPath) as! Author
        performSegueWithIdentifier(SegueIdentifier.AuthorsToQuotesList, sender: author)
    }
    
    // MARK: - Navigations
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.AuthorsToGenerator {
            let vc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! QuoteGeneratorViewController
            vc.delegate = self
            
        } else if segue.identifier == SegueIdentifier.AuthorsToQuote {
            let vc = segue.destinationViewController as! QuoteDetailViewController
            vc.quote = sender as! Quote
            
        } else if segue.identifier == SegueIdentifier.AuthorsToQuotesList {
            let vc = segue.destinationViewController as! QuotesListController
            let author = sender as! Author
            vc.title = author.name
            vc.quotePredicate = NSPredicate(format: "author = %@", author)
            
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    // MARK: - QuoteGeneratorViewControllerDelegate
    
    func quoteGenerator(generator: QuoteGeneratorViewController, didFinishWithQuote quote: Quote) {
        generator.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier(SegueIdentifier.AuthorsToQuote, sender: quote)
        }
    }
    
    func quoteGeneratorDidCancel(generator: QuoteGeneratorViewController) {
        generator.dismissViewControllerAnimated(true, completion: nil)
    }
}
