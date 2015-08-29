//
//  StreamResponse.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class StreamResponse: Mappable {
    
    /// Comments
    var comments: Array<Comment>?
   
    /// Issues
    var issues: Array<Issue>?
    
    class func newInstance(map: Map) -> Mappable? {
        return StreamResponse()
    }
    
    func mapping(map: Map) {
        comments    <- map["comments"]
        issues      <- map["issues"]
    }
    
}
