//
//  IssueCollaboratorsEditorTableViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class IssueCollaboratorsEditorTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var spinny: UIActivityIndicatorView!
    
    var delegate: NewIssueMetadataEditorDelegate?
    
    var selectedAssignee: User?
    
    var allCollaborators: Array<User>? {
        didSet {
            if self.view != nil
            {
                self.tableView.reloadData()
            }
        }
    }
    
    var repoName: String?
    
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
        
        self.reloadCollaborators()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "None", style: .Plain, target: self, action: Selector("clearAssignment"))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delegate?.metadataEditorDidChangeAssignment(selectedAssignee)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearAssignment()
    {
        self.selectedAssignee = nil
        
        self.tableView.reloadData()
    }

    func reloadCollaborators()
    {
        if let repo = self.repoName
        {
            self.spinny.startAnimating()
            self.tableView.hidden = true
            
            SessionManager.sharedManager.loadCollaboratorsForRepo(repo, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let collab = response as? CollaboratorsResponse
                    {
                        self.allCollaborators = collab.collaborators
                    }
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
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if let collaborators = self.allCollaborators
        {
            return count(collaborators)
        }
        
        return 0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoPickerTableViewCell", forIndexPath: indexPath) as! RepoPickerTableViewCell
        
        cell.contentLabel.text = self.allCollaborators![indexPath.row].login
        
        if let currentCollaborator = self.selectedAssignee
        {
            if currentCollaborator.identifier! == self.allCollaborators![indexPath.row].identifier!
            {
                cell.accessoryType = .Checkmark
            }
            else
            {
                cell.accessoryType = .None
            }
        }
        else
        {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedAssignee = self.allCollaborators![indexPath.row]
        
        self.tableView.reloadData()
    }

}
