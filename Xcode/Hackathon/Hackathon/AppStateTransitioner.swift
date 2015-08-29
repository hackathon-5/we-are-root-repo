//
//  AppStateTransitioner.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import Foundation
import UIKit

class AppStateTransitioner {
    
    private static func transition(toViewController:UIViewController, animated: Bool)
    {
        var window = UIApplication.sharedApplication().delegate!.window!
        
        if animated
        {
            
            var coverView = UIView(frame: window!.bounds)
            coverView.backgroundColor = UIColor.whiteColor()
            coverView.alpha = 0.0
            
            window?.addSubview(coverView)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                coverView.alpha = 1.0
                }) { (finished) -> Void in
                    window?.rootViewController = toViewController
                    window?.bringSubviewToFront(coverView)
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        coverView.alpha = 0.0
                        }, completion: { (finished) -> Void in
                            coverView.removeFromSuperview()
                    })
            }
            
        }
        else
        {
            window?.rootViewController = toViewController
        }
    }
    
    static func switchToLoginContext(animated: Bool)
    {
        let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? UIViewController
        
        self.transition(loginVC, animated: animated)
    }
}

