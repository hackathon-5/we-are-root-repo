//
//  RespondToCommentViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

protocol RespondToCommentDelegate {
    func responseWasSentSuccessfully(commentVC: RespondToCommentViewController)
}

class RespondToCommentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    
    var repo: String?
    var issueNumber: Int?
    
    var delegate : RespondToCommentDelegate?
    
    var keyboardNotificationObserver: AnyObject?
    
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.keyboardNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            var frame : CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardFrameInViewCoordiantes = self.view.convertRect(frame, fromView: nil)
            
            var constantModification = CGRectGetHeight(self.view.bounds) - keyboardFrameInViewCoordiantes.origin.y
            
            let duration:NSTimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animateWithDuration(duration, delay: 0.0, options: animationCurve, animations: { () -> Void in
                self.textViewBottomConstraint.constant = constantModification
                
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        self.commentTextView.delegate = self
        
        self.title = "Reply"
        
        self.navigationItem.rightBarButtonItem = self.getSaveBarButton()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("closeScreen"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.keyboardNotificationObserver!)
    }
    
    func getSaveBarButton() -> UIBarButtonItem
    {
        var saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("saveCommentToGithub"))
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "SFUIText-Bold", size: 17.0)!], forState: .Normal)
        
        return saveButton
    }
    
    func closeScreen()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        if count(textView.text) == 0
        {
            self.placeholderLabel.hidden = false
        }
        else
        {
            self.placeholderLabel.hidden = true
        }
    }
    
    func saveCommentToGithub()
    {
        if count(self.commentTextView.text) == 0
        {
            let alert = UIAlertController(title: "You need to type a comment if you want to reply.", message: nil, preferredStyle: .Alert)
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
        
        SessionManager.sharedManager.submitNewGithubComment(self.repo!, number: self.issueNumber!, comment: self.commentTextView.text, images: nil) { (success, error, response) -> Void in
            if success
            {
                //Woo!!!!
                self.delegate?.responseWasSentSuccessfully(self)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
