//
//  IssueResponse.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueResponse: Mappable {
   
    var issue: Issue?
    
    var comments: Array<Comment>?
    
    class func newInstance(map: Map) -> Mappable? {
        return IssueResponse()
    }
    
    func mapping(map: Map) {
        issue    <- map["issue"]
        comments <- map["comments"]
    }
}
