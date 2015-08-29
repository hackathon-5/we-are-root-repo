//
//  IssueLabelEditorTableViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class IssueLabelEditorTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var spinny: UIActivityIndicatorView!
    
    var delegate: NewIssueMetadataEditorDelegate?
    
    var selectedLabels: Array<String> = Array<String>()
    
    var allLabels:Array<String>? {
        didSet {
            if self.view != nil
            {
                self.tableView.reloadData()
            }
        }
    }
    
    var repoName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
                
        self.tableView.tintColor = UIColor(red: 59.0/255.0, green: 132.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        
        self.reloadLabels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delegate?.metadataEditorDidChangeLabels(self.selectedLabels)
    }
    
    func reloadLabels()
    {
        if let repo = self.repoName
        {
            self.spinny.startAnimating()
            self.tableView.hidden = true
            
            SessionManager.sharedManager.loadLabelsForRepo(repo, completion: { (success, error, response) -> Void in
                
                if success
                {
                    var labels = Array<String>()
                    for labelInfo in response as! Array<Dictionary<String,String>>
                    {
                        labels.append(labelInfo["name"]!)
                    }
                    
                    self.allLabels = labels
                }
                else
                {
                    let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                self.spinny.stopAnimating()
                self.tableView.hidden = false
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isStringInSelectedLabels(string:String) -> Bool
    {
        for label in self.selectedLabels
        {
            if label.lowercaseString == string.lowercaseString
            {
                return true
            }
        }
        
        return false
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if let labels = self.allLabels
        {
            return count(labels)
        }
        
        return 0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoPickerTableViewCell", forIndexPath: indexPath) as! RepoPickerTableViewCell
        
        cell.contentLabel.text = self.allLabels![indexPath.row]
        
        // Configure the cell...
        if self.isStringInSelectedLabels(self.allLabels![indexPath.row])
        {
            cell.accessoryType = .Checkmark
        }
        else
        {
            cell.accessoryType = .None
        }

        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.isStringInSelectedLabels(self.allLabels![indexPath.row])
        {
            //Remove it!
            self.selectedLabels = self.selectedLabels.filter() { $0 != self.allLabels![indexPath.row]}
            
            var cell: RepoPickerTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RepoPickerTableViewCell
            
            cell.accessoryType = .None
            
        }
        else
        {
            self.selectedLabels.append(self.allLabels![indexPath.row])
            
            var cell: RepoPickerTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! RepoPickerTableViewCell
            
            cell.accessoryType = .Checkmark
        }

    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
