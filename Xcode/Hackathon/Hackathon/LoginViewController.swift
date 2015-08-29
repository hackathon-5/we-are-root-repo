//
//  ViewController.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loginButton.layer.cornerRadius = 4.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("OAuthLoginDidSucceed"), name: kHackathonSessionManagerOAuthSuccess, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("OAuthLoginDidFail:"), name: kHackathonSessionManagerOAuthFailure, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

   @IBAction private func authorizeGithub()
    {
        SessionManager.sharedManager.beginOAuthGithubLogin()
    }
    
    func OAuthLoginDidSucceed()
    {
        AppStateTransitioner.switchToMainAppContext(true)
    }
    
    func OAuthLoginDidFail(notification: NSNotification)
    {
        var displayError = "An unknown error occurred while logging you into Github. Please try again."
        
        if let errorMessage = notification.object as? String
        {
            displayError = errorMessage
        }
        
        let alert = UIAlertController(title: "Login Error", message: displayError, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

