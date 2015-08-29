//
//  Issue.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper
import TSMarkdownParser

class Issue: Mappable {
   
    /// The identifier of the owner of the repository
    var identifier: Int?
    
    /// The User who generated this object
    var user: User?
    
    /// When this issue was created
    var createdAt: NSDate?
    
    /// The issue number
    var number: Int?
    
    /// The repo name
    var repo: String?
    
    /// The state of the issue (open, closed, etc.)
    var state: String?
    
    /// The title of the issue
    var title: String?
    
    /// The body content of the issue
    var body: String?
    
    var attributedBody: NSAttributedString?
    
    /// The date this comment was last updated.
    var updatedAt: NSDate?
    
    var assignee: User?
    
    var images: Array<NSURL>?
    
    class func newInstance(map: Map) -> Mappable? {
        return Issue()
    }
    
    func mapping(map: Map) {
        identifier  <- map["id"]
        user        <- map["user"]
        createdAt   <- (map["created_at"], DateTransform())
        number      <- map["number"]
        repo        <- map["repo"]
        state       <- map["state"]
        title       <- map["title"]
        body        <- map["body"]
        updatedAt   <- (map["updated_at"], DateTransform())
        assignee    <- map["assignee"]
        
        if self.body != nil
        {
            var links = Array<NSURL>()
            
            var error: NSError?
            let detector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
            detector?.enumerateMatchesInString(self.body!, options: nil, range: NSMakeRange(0, (self.body! as NSString).length)) { (result, flags, _) in
                
                var url = (self.body! as NSString).substringWithRange(result.range)
                
                if url.hasSuffix(".png") || url.hasSuffix(".jpg") || url.hasSuffix(".jpeg")
                {
                    links.append(NSURL(string: url)!)
                    
                    NSLog("Found image in comment: %@", url)
                }
            }
            
            self.images = links
            
            var attributedBodyContent = NSMutableAttributedString(string: self.body!, attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.7), NSFontAttributeName : UIFont(name: "SFUIText-Regular", size: 16.0)!])
            
            //Color @mentions
            var regex = NSRegularExpression(pattern: "@(\\w+)", options: .allZeros, error: nil)
            
            if let matches = regex?.matchesInString(self.body!, options: .allZeros, range: NSMakeRange(0, count(self.body!)))
            {
                for match in matches
                {
                    attributedBodyContent.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 170.0/255.0, green: 226.0/255.0, blue: 0.0, alpha: 1.0), range: match.range)
                }
            }
            
            //Color links
            if self.body != nil
            {
                var links = Array<NSURL>()
                
                var error: NSError?
                let detector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
                detector?.enumerateMatchesInString(self.body!, options: nil, range: NSMakeRange(0, (self.body! as NSString).length)) { (result, flags, _) in
                    
                    attributedBodyContent.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 255.0/255.0, green: 38.0/255.0, blue: 112.0/255.0, alpha: 1.0), range: result.range)
                }
            }
            
            var markdownString : NSMutableAttributedString = TSMarkdownParser.standardParser().attributedStringFromAttributedMarkdownString(attributedBodyContent).mutableCopy() as! NSMutableAttributedString
            
            self.attributedBody = markdownString
        }
    }
}
