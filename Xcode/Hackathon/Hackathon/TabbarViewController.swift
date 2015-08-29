//
//  TabbarViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class TabbarViewController: UIViewController {

    @IBOutlet var childVCContainer: UIView!
    
    let streamNavigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StreamViewController") as! StreamTableViewController)
    
    let settingsNavigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsTableViewController)
    
    private var activeViewControllerObject: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.streamNavigationController.navigationBar.translucent = false
        self.settingsNavigationController.navigationBar.translucent = false
        
        self.addChildViewController(self.streamNavigationController)
        self.addChildViewController(self.settingsNavigationController)
        
        self.childVCContainer.addSubview(self.streamNavigationController.view)
        self.childVCContainer.addSubview(self.settingsNavigationController.view)
        
        self.setActiveViewController(self.streamNavigationController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.streamNavigationController.view.frame = self.childVCContainer.bounds
        self.settingsNavigationController.view.frame = self.childVCContainer.bounds
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setActiveViewController(controller: UIViewController) {
        
        if self.streamNavigationController == controller
        {
            self.streamNavigationController.view.hidden = false
            self.settingsNavigationController.view.hidden = true
        }
        
        if self.settingsNavigationController == controller
        {
            self.settingsNavigationController.view.hidden = false
            self.streamNavigationController.view.hidden = true
        }
        
        self.activeViewControllerObject = controller
    }
    
    @IBAction func switchToStream(sender: AnyObject) {
    
        if self.activeViewControllerObject == self.streamNavigationController
        {
            self.streamNavigationController.popToRootViewControllerAnimated(true)
        }
        else
        {
            self.setActiveViewController(self.streamNavigationController)
        }
    }
    
    @IBAction func switchToSettings(sender: AnyObject) {
        
        if self.activeViewControllerObject == self.settingsNavigationController
        {
            self.settingsNavigationController.popToRootViewControllerAnimated(true)
        }
        else
        {
            self.setActiveViewController(self.settingsNavigationController)
        }
    }
    
    @IBAction func createIssuePressed(sender: AnyObject) {
        
    }
    
}
