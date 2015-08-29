//
//  NewIssueCreatorViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

protocol NewIssueMetadataEditorDelegate {
    func metadataEditorDidChangeLabels(labels:Array<String>)
    
    func metadataEditorDidChangeMilestone(milestone: Milestone?)
    
    func metadataEditorDidChangeAssignment(assignment: User?)
}

class NewIssueCreatorViewController: UIViewController, UITextViewDelegate, NewIssueMetadataEditorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IssueImageEditorDelegate {

    var repoData : BasicRepository?
    
    var labels: Array<String> = Array<String>()
    
    var milestone: Milestone?
    
    var assignment: User?
    
    var imagesForUpload: Array<UIImage> = Array<UIImage>()
    
    @IBOutlet var seperatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var placeholderLabel: UILabel!
    
    @IBOutlet var issueContentTextView: UITextView!
    
    @IBOutlet var issueTitleField: UITextField!
    
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var labelTextLabel: UILabel!
    
    @IBOutlet var milestoneTextLabel: UILabel!
    
    @IBOutlet var assignedToTextLabel: UILabel!
    
    @IBOutlet var imagesAttachedCountLabel: UILabel!
    
    @IBOutlet var inputAccessoryToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.seperatorHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        self.issueTitleField.attributedPlaceholder = NSAttributedString(string: "Issue Title", attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.2), NSFontAttributeName : UIFont(name: "SFUIText-Regular", size: 16.0)!])
        
        self.issueContentTextView.tintColor = UIColor.whiteColor()
        
        self.issueContentTextView.inputAccessoryView = self.inputAccessoryToolbar
        self.issueTitleField.inputAccessoryView = self.inputAccessoryToolbar
        
        self.inputAccessoryToolbar.tintColor = UIColor.whiteColor()
        
        self.title = "Create Issue"
        
        self.navigationItem.rightBarButtonItem = self.getSaveBarButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.recalculateLowerUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        if count(textView.text) > 0
        {
            self.placeholderLabel.hidden = true
        }
        else
        {
            self.placeholderLabel.hidden = false
        }
    }

    func saveIssueToGithub()
    {
        if count(self.issueTitleField.text) == 0
        {
            let alert = UIAlertController(title: "You need to provide a title for your issue.", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return;
        }
        
        //Let's submit it!!
        
        let spinny = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinny)
        spinny.startAnimating()
        
        self.view.endEditing(true)
        self.navigationController?.view.userInteractionEnabled = false
        
        SessionManager.sharedManager.submitNewGithubIssue(self.issueTitleField.text, body: self.issueContentTextView.text, images: self.imagesForUpload, labels: self.labels, milestone: self.milestone?.number, assignedTo:assignment?.login, repo: self.repoData!.name!) { (success, error, response) -> Void in
            
            if success
            {
                //Woo!!!!
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            self.navigationItem.rightBarButtonItem = self.getSaveBarButton()
            self.navigationController?.view.userInteractionEnabled = true
        }
    }
    
    func getSaveBarButton() -> UIBarButtonItem
    {
       var saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("saveIssueToGithub"))
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "SFUIText-Bold", size: 17.0)!], forState: .Normal)
        
        return saveButton
    }
    
    @IBAction func endEditingForTextViews(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func modifyLabelsPressed(sender: AnyObject) {
        
    }
    
    @IBAction func modifyMilestonePressed(sender: AnyObject) {
        
    }
    
    @IBAction func modifyAssignedToPressed(sender: AnyObject) {
        
    }
    
    func metadataEditorDidChangeLabels(labels:Array<String>)
    {
        self.labels = labels
        
        self.recalculateLowerUI()
    }
    
    func metadataEditorDidChangeMilestone(milestone: Milestone?)
    {
        self.milestone = milestone
        
        self.recalculateLowerUI()
    }
    
    func metadataEditorDidChangeAssignment(assignment: User?)
    {
        self.assignment = assignment
        
        self.recalculateLowerUI()
    }
    
    func recalculateLowerUI()
    {
        //Calculate labels
        var labelsText = ""
        
        for text in self.labels
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
        
        var milestoneText = self.milestone?.title
        
        var assignedTo = self.assignment?.login
        
        if let userName = self.assignment?.login
        {
            assignedTo = userName
        }
        
        var imagesAttachedText = "NO IMAGES ATTACHED"
        
        if count(self.imagesForUpload) > 0
        {
            var countOfImages = count(self.imagesForUpload)
            if countOfImages == 1
            {
                imagesAttachedText = "1 IMAGE ATTACHED"
            }
            else
            {
                imagesAttachedText = "\(countOfImages) IMAGES ATTACHED"
            }
        }
        
        self.labelTextLabel.text = labelsText
        self.assignedToTextLabel.text = assignedTo
        self.milestoneTextLabel.text = milestoneText
        self.imagesAttachedCountLabel.text = imagesAttachedText
    }
    
    @IBAction func showCameraPicker()
    {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Your device is not configured for photos.", message: nil, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        //Ok, let's do some image swapping magic here... 
        
        let snapshot = UIApplication.sharedApplication().delegate?.window??.snapshotViewAfterScreenUpdates(false)
        
        UIApplication.sharedApplication().delegate?.window??.addSubview(snapshot!)
        
        picker.dismissViewControllerAnimated(false, completion: nil)
        
        UIApplication.sharedApplication().delegate?.window??.bringSubviewToFront(snapshot!)
        
        self.performSegueWithIdentifier("ShowIssuePhotoEditorFromCreateIssue", sender: image.fixOrientation())
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            snapshot?.alpha = 0.0
        }) { (finished) -> Void in
            snapshot?.removeFromSuperview()
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let navigation = segue.destinationViewController as? UINavigationController, destination = navigation.viewControllers.first as? IssueImageEditorViewController, image = sender as? UIImage, goingView = destination.view
        {
            destination.delegate = self
            destination.contentImageView.image = image
        }
        
        if let destination = segue.destinationViewController as? IssueLabelEditorTableViewController
        {
            destination.repoName = self.repoData?.name
            destination.selectedLabels = self.labels
            destination.delegate = self
        }
        
        if let destination = segue.destinationViewController as? IssueMilestoneEditorTableViewController
        {
            destination.repoName = self.repoData?.name
            destination.selectedMilestone = self.milestone
            destination.delegate = self
        }
        
        if let destination = segue.destinationViewController as? IssueCollaboratorsEditorTableViewController
        {
            destination.repoName = self.repoData?.name
            destination.selectedAssignee = self.assignment
            destination.delegate = self
        }
    }
    
    func imageEditorDidFinishWithImage(image:UIImage)
    {
        self.imagesForUpload.append(image)
        
        self.recalculateLowerUI()
    }
    

}
