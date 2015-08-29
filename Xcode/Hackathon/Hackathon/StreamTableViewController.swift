//
//  StreamTableViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import TSMarkdownParser

class StreamTableViewController: UITableViewController, DropdownTitleViewDelegate, RepoPickerTableViewDelegate {
    
    let dropdownTitle: DropdownTitleView = UINib(nibName: "DropdownTitleView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! DropdownTitleView
    
    var streamNewsListItems: Array<AnyObject>? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.dropdownTitle.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.dropdownTitle.dropdownDelegate = self
        
        self.navigationItem.titleView = self.dropdownTitle
        
        self.tableView.backgroundColor = UIColor(red: 39.0/255.0, green: 39.0/255.0, blue: 41.0/255.0, alpha: 1.0)
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        
        var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDidTapInTableView:"))
        
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 48.0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 48.0, 0.0)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadNewsStream"), forControlEvents: .ValueChanged)
        self.refreshControl?.tintColor = UIColor(white: 0.7, alpha: 1.0)
        
        self.reloadNewsStream()
        
        self.refreshControl?.beginRefreshing()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadNewsStream()
    {
        SessionManager.sharedManager.loadStreamForCurrentPreferences { (success, error, response) -> Void in
            
            self.refreshControl?.endRefreshing()
            
            if success
            {
                if let streamResponse = response as? StreamResponse
                {
                    var itemsInStream = Array<AnyObject>()
                    
                    if let comments = streamResponse.comments
                    {
                        for comment in comments
                        {
                            itemsInStream.append(comment)
                        }
                    }
                    
                    if let issues = streamResponse.issues
                    {
                        for issue in issues
                        {
                            itemsInStream.append(issue)
                        }
                    }
                    
                    //Sort them chronologically!
                    
                    itemsInStream.sort({ (firstItem, secondItem) -> Bool in
                        
                        var firstDate: NSDate!
                        var secondDate: NSDate!
                        
                        if let item = firstItem as? Comment
                        {
                            firstDate = item.updatedAt
                            
                        } else if let item = firstItem as? Issue
                        {
                            firstDate = item.updatedAt
                        } else
                        {
                            return true
                        }
                        
                        if let item = secondItem as? Comment
                        {
                            secondDate = item.updatedAt
                            
                        } else if let item = secondItem as? Issue
                        {
                            secondDate = item.updatedAt
                        } else
                        {
                            return true
                        }
                        
                        
                        if firstDate.timeIntervalSince1970 > secondDate.timeIntervalSince1970
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    })
                    
                    self.streamNewsListItems = itemsInStream
                }
                else
                {
                    let alert = UIAlertController(title: "Network Error", message: "The server returned an unexpected response.", preferredStyle: .Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
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
    
    func dropDownTitleViewWasSelected(dropdown: DropdownTitleView) {
        //Segue stream selection
        self.performSegueWithIdentifier("StreamChooseRepos", sender: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if let items = self.streamNewsListItems
        {
            return count(items)
        }
        
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var currentItem: AnyObject = self.streamNewsListItems![indexPath.row]
        
        if let item = currentItem as? Comment
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

            
            var repoName = item.repo == nil ? "" : item.repo!
            repoName = repoName.componentsSeparatedByString("/").last!
            
            cell.bylineLabel.text = "Posted in \(repoName)"
            
            cell.dateLabel.text = item.updatedAt?.relativeTime
            
            cell.bylineIconImageView.image = UIImage(named: "iconComment")
            
            cell.profileImageView.tag = indexPath.row
            
            cell.profileImageView.image = nil
            
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
            
        } else if let item = currentItem as? Issue
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
            
            cell.bylineLabel.text = "Posted in \(repoName)"
            
            cell.dateLabel.text = item.updatedAt?.relativeTime
            
            cell.bylineIconImageView.image = UIImage(named: "iconIssue")
            
            cell.profileImageView.tag = indexPath.row
            
            cell.profileImageView.image = nil
            
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
        
        // Configure the cell...
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var currentItem: AnyObject = self.streamNewsListItems![indexPath.row]
        
        if let item = currentItem as? Comment
        {
            
            if item.images?.count > 0
            {
                return 419.0
            }
            else
            {
                return 124.0
            }
            
        } else if let item = currentItem as? Issue
        {
            return 124.0
        }
        
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
                        
                        if cell.contentImageView.image != nil
                        {
                            var photo = IDMPhoto(image: cell.contentImageView.image)
                            photos.append(photo)
                        }
                        else
                        {
                            //Let's get a URL
                            if let currentItem = self.streamNewsListItems?[indexPath.row] as? Comment
                            {
                                if currentItem.images?.count > 0
                                {
                                    var photo = IDMPhoto(URL: currentItem.images!.first)
                                    photos.append(photo)
                                }
                            } else if let currentItem = self.streamNewsListItems?[indexPath.row] as? Issue
                            {
                                if currentItem.images?.count > 0
                                {
                                    var photo = IDMPhoto(URL: currentItem.images!.first)
                                    photos.append(photo)
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
                        else
                        {
                            self.cellSelectedAtIndexPath(indexPath)
                        }
                    }
                    else
                    {
                        self.cellSelectedAtIndexPath(indexPath)
                    }
                }
                else
                {
                    self.cellSelectedAtIndexPath(indexPath)
                }
                
            }
        }
    }
    
    func cellSelectedAtIndexPath(indexPath: NSIndexPath)
    {
        
    }
    
    func repoPickerIsExisting(picker: RepoPickerTableViewController) {
        
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl!.bounds.size.height), animated: false)
        
        self.reloadNewsStream()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController
        {
            if let destination = navigationController.viewControllers.first as? RepoPickerTableViewController
            {
                destination.pickerDelegate = self
            }
        }
    }
}
