//
//  ParameterPickerViewController.swift
//  BigQuote
//
//  Created by Adi Li on 22/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

protocol ParameterPickerViewControllerDelegate: class {
    func pickerDidCancel(picker: ParameterPickerViewController)
    func picker(picker: ParameterPickerViewController, didSelectChoice choice: AnyObject)
    func picker(picker: ParameterPickerViewController, configTableCell cell: UITableViewCell, forChoice choice: AnyObject)
}

class ParameterPickerViewController: UITableViewController {
    
    var choices = [AnyObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: ParameterPickerViewControllerDelegate?
    
    // MARK: - User Actions

    @IBAction func cancelSelection(sender: UIBarButtonItem) {
        delegate?.pickerDidCancel(self)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        delegate?.picker(self, configTableCell: cell, forChoice: choices[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.picker(self, didSelectChoice: choices[indexPath.row])
    }
}
