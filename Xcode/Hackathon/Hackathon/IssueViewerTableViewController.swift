//
//  IssueViewerTableViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

class IssueViewerTableViewController: UITableViewController, RespondToCommentDelegate {
    
    var issue: Issue?
    
    var issueNumber: Int?
    var repo: String?
    
    var comments: Array<Comment>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.backgroundColor = UIColor(red: 39.0/255.0, green: 39.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        
        self.tableView.tintColor = UIColor(red: 59.0/255.0, green: 132.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 48.0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 48.0, 0.0)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadIssue"), forControlEvents: .ValueChanged)
        
        self.refreshControl?.tintColor = UIColor(white: 0.3, alpha: 1.0)
        
        self.title = "Issue"
        
        self.refreshControl?.beginRefreshing()
        self.reloadIssue()
        
        var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDidTapInTableView:"))
        
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconReply"), style: .Plain, target: self, action: Selector("replyToIssue"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadIssue()
    {
        if self.repo != nil && self.issueNumber != nil
        {
            SessionManager.sharedManager.loadIssue(self.issueNumber!, repo: self.repo!, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let issueResponse = response as? IssueResponse
                    {
                        self.issue = issueResponse.issue
                        self.comments = issueResponse.comments
                        
                        self.comments?.sort({ (firstComment, secondComment) -> Bool in
                            
                            if firstComment.updatedAt?.timeIntervalSince1970 < secondComment.updatedAt?.timeIntervalSince1970
                            {
                                return true
                            }
                            
                            return false
                        })
                        
                        self.tableView.reloadData()
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    func replyToIssue()
    {
        self.performSegueWithIdentifier("RespondToIssue", sender: nil)
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if self.issue == nil
        {
            return 0
        }
        
        switch section {
        case 0:
            return 1
        case 1:
            if let comments = self.comments
            {
                return count(comments)
            }
            
            return 0
            
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            if let item = self.issue
            {
                //It's an issue!
                var cell : StreamTableViewCell!
                
                if item.images?.count > 0
                {
                    cell = tableView.dequeueReusableCellWithIdentifier("StreamTableViewCellImage", forIndexPath: indexPath) as! StreamTableViewCell
                }
                else
                {
                    cell = tableView.dequeueReusableCellWithIdentifier("StreamTableViewCell", forIndexPath: indexPath) as! StreamTableViewCell
                }
                
                cell.usernameLabel.text = item.user?.login
                
                var markdownString = item.attributedBody?.mutableCopy() as! NSMutableAttributedString
                
                markdownString.addAttribute(NSFontAttributeName, value: UIFont(name: "SFUIText-Regular", size: 16.0)!, range: NSMakeRange(0, count(markdownString.string)))
                
                
                cell.contentLabel.attributedText = markdownString
                
                var repoName = item.repo == nil ? "" : item.repo!
                repoName = repoName.componentsSeparatedByString("/").last!
                
                if cell.bylineLabel != nil
                {
                    cell.bylineLabel.text = "Posted in \(repoName)"
                }
                
                cell.dateLabel.text = item.updatedAt?.relativeTime
                
                
                if cell.profileImageView.image != nil{
                    
                    cell.profileImageView.tag = indexPath.row
                    
                    cell.profileImageView.image = nil
                }
                
                
                if cell.profileImageView != nil
                {
                    if let url = item.user?.avatarURL
                    {
                        cell.profileImageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                            
                            if cell.profileImageView.tag == indexPath.row
                            {
                                if cacheType != .Disk
                                {
                                    cell.profileImageView.alpha = 0.0
                                    
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        cell.profileImageView.alpha = 1.0
                                    })
                                }
                                else
                                {
                                    cell.profileImageView.alpha = 1.0
                                }
                            }
                            
                        })
                    }
                }
                
                if item.images?.count > 0 && cell.contentImageView != nil
                {
                    cell.contentImageView.image = nil
                    cell.contentImageView.tag = indexPath.row
                    
                    if let url = item.images!.first
                    {
                        cell.contentImageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                            
                            if cell.contentImageView.tag == indexPath.row
                            {
                                if cacheType != .Disk
                                {
                                    cell.contentImageView.alpha = 0.0
                                    
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        cell.contentImageView.alpha = 1.0
                                    })
                                }
                                else
                                {
                                    cell.contentImageView.alpha = 1.0
                                }
                            }
                            
                        })
                    }
                }
                
                return cell
            }
            
        } else if indexPath.section == 1
        {
            if let item = self.comments?[indexPath.row]
            {
                //It's a comment!
                var cell : StreamTableViewCell!
                
                if item.images?.count > 0
                {
                    cell = tableView.dequeueReusableCellWithIdentifier("StreamTableViewCellImage", forIndexPath: indexPath) as! StreamTableViewCell
                }
                else
                {
                    cell = tableView.dequeueReusableCellWithIdentifier("StreamTableViewCell", forIndexPath: indexPath) as! StreamTableViewCell
                }
                
                cell.usernameLabel.text = item.user?.login
                
                var markdownString = item.attributedBody?.mutableCopy() as! NSMutableAttributedString
                
                markdownString.addAttribute(NSFontAttributeName, value: UIFont(name: "SFUIText-Regular", size: 16.0)!, range: NSMakeRange(0, count(markdownString.string)))
                
                cell.contentLabel.attributedText = markdownString
                
                cell.dateLabel.text = item.updatedAt?.relativeTime
                
                if cell.profileImageView != nil
                {
                    cell.profileImageView.tag = indexPath.row
                    
                    cell.profileImageView.image = nil
                }
                
                if let images = item.images
                {
                    if cell.bylineLabel != nil && count(images) > 0
                    {
                        if count(images) == 1
                        {
                            cell.bylineLabel.text = "1 image attached"
                        }
                        else
                        {
                            var imageCount = count(images)
                            cell.bylineLabel.text = "\(imageCount) images attached"
                        }
                    }
                }
                
                if let url = item.user?.avatarURL
                {
                    if cell.profileImageView != nil
                    {
                        cell.profileImageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                            
                            if cell.profileImageView.tag == indexPath.row
                            {
                                if cacheType != .Disk
                                {
                                    cell.profileImageView.alpha = 0.0
                                    
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        cell.profileImageView.alpha = 1.0
                                    })
                                }
                                else
                                {
                                    cell.profileImageView.alpha = 1.0
                                }
                            }
                            
                        })
                    }
                }
                
                if item.images?.count > 0 && cell.contentImageView != nil
                {
                    cell.contentImageView.image = nil
                    cell.contentImageView.tag = indexPath.row
                    
                    if let url = item.images!.first
                    {
                        cell.contentImageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                            
                            if cell.contentImageView.tag == indexPath.row
                            {
                                if cacheType != .Disk
                                {
                                    cell.contentImageView.alpha = 0.0
                                    
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        cell.contentImageView.alpha = 1.0
                                    })
                                }
                                else
                                {
                                    cell.contentImageView.alpha = 1.0
                                }
                            }
                            
                        })
                    }
                }
                
                return cell
            }
        } else if indexPath.section == 2
        {
            //Overview panel
            let cell = tableView.dequeueReusableCellWithIdentifier("FooterIssueMetricsTableViewCell", forIndexPath: indexPath) as! FooterIssueMetricsTableViewCell
            
            //Calculate labels
            var labelsText = "–"
            
            if let labels = self.issue?.labels
            {
                for text in labels
                {
                    if count(labelsText) == 0
                    {
                        labelsText = text
                    }
                    else
                    {
                        labelsText = labelsText + ", " + text
                    }
                }
            }
            
            var milestoneText = "–"
            
            if let milestoneTitle = self.issue?.milestone?.title
            {
                if count(milestoneTitle) > 0
                {
                    milestoneText = milestoneTitle
                }
            }
            
            var assignedTo = "–"
            
            if let assigneeTitle = self.issue?.assignee?.login
            {
                if count(assigneeTitle) > 0
                {
                    assignedTo = assigneeTitle
                }
            }
            
            cell.labelsLabel.text = labelsText
            cell.assignedToLabel.text = assignedTo
            cell.milestoneLabel.text = milestoneText
            
            
            return cell
        }
        
        
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
            return 80.0
        } else if indexPath.section == 1
        {
            if let item = self.comments?[indexPath.row]
            {
                if let images = item.images
                {
                    if count(images) > 0
                    {
                        return 400.0
                    }
                }
            }
            
            return 96.0
        } else if indexPath.section == 2
        {
            return 132.0
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0
        {
            return UITableViewAutomaticDimension
        } else if indexPath.section == 1
        {
            return UITableViewAutomaticDimension
        } else if indexPath.section == 2
        {
            return 132.0
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func userDidTapInTableView(gestureRecognizer: UITapGestureRecognizer)
    {
        if gestureRecognizer.state == .Ended
        {
            //Let's get what cell it was in!
            
            if let indexPath = self.tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(self.tableView)), cell = self.tableView.cellForRowAtIndexPath(indexPath) as? StreamTableViewCell
            {
                if cell.contentImageView != nil
                {
                    if CGRectContainsPoint(cell.contentImageView!.bounds, gestureRecognizer.locationInView(cell.contentImageView!))
                    {
                        //Show photo viewer!
                        
                        var photos = Array<IDMPhoto>()
                        
                        if indexPath.section == 0
                        {
                            //Issue
                            if cell.contentImageView.image != nil
                            {
                                var photo = IDMPhoto(image: cell.contentImageView.image)
                                photos.append(photo)
                            }
                            else
                            {
                                //Let's get a URL
                                if let currentItem = self.issue
                                {
                                    var isFirstImage = true
                                    if let images = currentItem.images
                                    {
                                        for image in images
                                        {
                                            if !isFirstImage
                                            {
                                                var photo = IDMPhoto(URL: image)
                                                photos.append(photo)
                                            }
                                            isFirstImage = false
                                        }
                                    }
                                }
                            }
                        }
                        
                        if indexPath.section == 1
                        {
                            //Comment
                            if cell.contentImageView.image != nil
                            {
                                var photo = IDMPhoto(image: cell.contentImageView.image)
                                photos.append(photo)
                            }
                            else
                            {
                                //Let's get a URL
                                if let currentItem = self.comments?[indexPath.row]
                                {
                                    var isFirstImage = true
                                    if let images = currentItem.images
                                    {
                                        for image in images
                                        {
                                            if !isFirstImage
                                            {
                                                var photo = IDMPhoto(URL: image)
                                                photos.append(photo)
                                            }
                                            isFirstImage = false
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        if count(photos) > 0
                        {
                            var browser = IDMPhotoBrowser(photos: photos, animatedFromView: cell.contentImageView)
                            
                            browser.setInitialPageIndex(0)
                            browser.useWhiteBackgroundColor = false
                            browser.displayArrowButton = false
                            browser.displayCounterLabel = false
                            browser.forceHideStatusBar = false
                            
                            self.presentViewController(browser, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }


    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        
        if let navigationController = segue.destinationViewController as? UINavigationController, destination = navigationController.viewControllers.first as? RespondToCommentViewController
        {
            destination.repo = self.repo
            destination.issueNumber = self.issueNumber
            destination.delegate = self
        }
        
    }
    
    func responseWasSentSuccessfully(commentVC: RespondToCommentViewController) {
        self.reloadIssue()
        
        self.tableView.scrollRectToVisible(CGRectMake(0, self.tableView.contentSize.height, 5, 5), animated: false)
    }
    
}
