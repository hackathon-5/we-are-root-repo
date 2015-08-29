//
//  BasicRepositoryOwner.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class BasicRepositoryOwner: Mappable {
   
    /// The identifier of the owner of the repository
    var identifier: Int?
    
    /// The username of the owner for display
    var login: String?
    
    /// The type of entity who owns the repository
    var type: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return BasicRepositoryOwner()
    }
    
    func mapping(map: Map) {
        login               <- map["login"]
        identifier          <- map["id"]
        type                <- map["type"]
    }
    
}
