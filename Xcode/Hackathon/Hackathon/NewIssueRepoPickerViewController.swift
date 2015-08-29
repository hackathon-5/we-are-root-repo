//
//  NewIssueRepoPickerViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class NewIssueRepoPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var organizationList: Array<RepoPickerOrgModel>? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var spinny: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.reloadRepositoryList()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        
        self.tableView.registerNib(UINib(nibName: "RepoPickerHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "RepoPickerHeaderView")
        
        self.tableView.tintColor = UIColor(red: 59.0/255.0, green: 132.0/255.0, blue: 227.0/255.0, alpha: 1.0)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: Selector("closeScreen"))

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeScreen()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func reloadRepositoryList()
    {
        self.spinny.startAnimating()
        self.tableView.hidden = true
        
        SessionManager.sharedManager.loadListOfRepositories { (success, error, response) -> Void in
            
            self.spinny.stopAnimating()
            self.tableView.hidden = false
            
            if success
            {
                //Ok! We need to sort these into organization models
                if let listResponse = response as? RepositoryListResponse
                {
                    var userReposDisplayModel = RepoPickerOrgModel()
                    userReposDisplayModel.displayName = "Contribute To"
                    
                    var organizationDisplayModels = Array<RepoPickerOrgModel>()
                    
                    if let organizations = listResponse.organizations
                    {
                        for org in organizations
                        {
                            var orgModel = RepoPickerOrgModel()
                            orgModel.displayName = org.login
                            
                            organizationDisplayModels.append(orgModel)
                        }
                    }
                    
                    if let repositories = listResponse.repositories
                    {
                        for repo in repositories
                        {
                            if repo.owner?.type == "Organization"
                            {
                                //We need to match the repos to the organizations
                                
                                for org in organizationDisplayModels
                                {
                                    if org.displayName == repo.owner?.login
                                    {
                                        org.repositories.append(repo)
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                userReposDisplayModel.repositories.append(repo)
                            }
                        }
                    }
                    
                    //Remove empty organizations
                    var activeRepos = Array<RepoPickerOrgModel>()
                    for org in organizationDisplayModels
                    {
                        if count(org.repositories) > 0
                        {
                            activeRepos.append(org)
                        }
                    }
                    
                    if count(userReposDisplayModel.repositories) > 0
                    {
                        activeRepos.insert(userReposDisplayModel, atIndex: 0)
                    }
                    
                    
                    self.organizationList = activeRepos
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Return the number of sections.
        
        if let organizations = self.organizationList
        {
            return count(organizations)
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        
        if let organizations = self.organizationList
        {
            return count(organizations[section].repositories)
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoPickerTableViewCell", forIndexPath: indexPath) as! RepoPickerTableViewCell
        
        cell.contentLabel.text = nil
        
        // Configure the cell...
        if let organizations = self.organizationList
        {
            let currentRepo = organizations[indexPath.section].repositories[indexPath.row]
            
            cell.contentLabel.text = currentRepo.name?.componentsSeparatedByString("/").last
  
            cell.accessoryType = .None
        }
        else
        {
            cell.contentLabel.text = nil
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("RepoPickerHeaderView") as! RepoPickerHeaderView
        
        if let organizations = self.organizationList
        {
            headerView.contentLabel.text = organizations[section].displayName
        }
        else
        {
            headerView.contentLabel.text = ""
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let organizations = self.organizationList
        {
            let currentRepo = organizations[indexPath.section].repositories[indexPath.row]
            
            self.performSegueWithIdentifier("CreateIssueStepTwo", sender: currentRepo)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destination = segue.destinationViewController as? NewIssueCreatorViewController, repo = sender as? BasicRepository
        {
            destination.repoData = repo
        }
        
    }
}
