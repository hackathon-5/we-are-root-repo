//
//  User.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class AppUser: Mappable {
   
    /// The name of the currently logged in user
    var name: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return AppUser()
    }
    
    func mapping(map: Map) {
        name           <- map["name"]
    }
    
}
