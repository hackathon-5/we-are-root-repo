//
//  BasicOrganization.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class BasicOrganization: Mappable {
   
    /// The URL of the avatar of the organization
    var avatarURL: NSURL?
    
    /// The identifier of the organization
    var identifier: Int?
    
    /// The username of the organization
    var login: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return BasicOrganization()
    }
    
    func mapping(map: Map) {
        avatarURL           <- (map["avatar_url"], URLTransform())
        identifier          <- map["id"]
        login               <- map["login"]
    }
    
}
