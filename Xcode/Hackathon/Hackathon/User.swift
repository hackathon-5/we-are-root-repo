//
//  User.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/28/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class User: Mappable {
   
    class func newInstance(map: Map) -> Mappable? {
        return User()
    }
    
    func mapping(map: Map) {
//        emailVerified           <- map["email_verified"]
    }
    
}
