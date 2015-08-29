//
//  IssueImageEditorViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import SmoothLineView

protocol IssueImageEditorDelegate {
    func imageEditorDidFinishWithImage(image:UIImage)
}

class IssueImageEditorViewController: UIViewController {

    var delegate: IssueImageEditorDelegate?
    
    @IBOutlet var drawingContainerView: UIView!
    
    @IBOutlet var contentImageView: UIImageView!
    
    @IBOutlet var drawingView: LVSmoothLineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.drawingView.brush.color = UIColor.redColor()
        self.drawingView.brush.lineWidth = 3.0
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelPressed"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("doneButtonPressed"))
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "SFUIText-Bold", size: 17.0)!], forState: .Normal)
        
        self.drawingContainerView.layer.borderWidth = 4.0
        self.drawingContainerView.layer.borderColor = UIColor(red: 29.0/255.0, green: 127.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneButtonPressed()
    {
        UIGraphicsBeginImageContextWithOptions(self.drawingContainerView.bounds.size, true, 0.0)
        UIColor.blackColor().set()
        
        CGContextFillRect(UIGraphicsGetCurrentContext(), self.drawingContainerView.bounds)
        
        self.drawingContainerView.drawViewHierarchyInRect(self.drawingContainerView.bounds, afterScreenUpdates: false)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.delegate?.imageEditorDidFinishWithImage(image)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelPressed()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
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
