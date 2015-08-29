//
//  User.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class User: Mappable {
   
    /// The avatar URL for the user
    var avatarURL: NSURL?
    
    /// The identifier for the user
    var identifier: Int?
    
    /// The username to display for the user
    var login: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return User()
    }
    
    func mapping(map: Map) {
        avatarURL   <- (map["avatar_url"], URLTransform())
        identifier  <- map["id"]
        login       <- map["login"]
    }
    
}
