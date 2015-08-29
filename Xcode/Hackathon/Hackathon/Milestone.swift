//
//  Milestone.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class Milestone: Mappable {
   
    var createdAt: NSDate?
    
    var creator: User?
    
    var desc: String?
    
    var dueOn: NSDate?
    
    var identifier: Int?
    
    var updatedAt: NSDate?
    
    var title: String?
    
    var number: Int?
    
    class func newInstance(map: Map) -> Mappable? {
        return Milestone()
    }
    
    func mapping(map: Map) {
        createdAt       <- (map["created_at"], DateTransform())
        creator         <- map["creator"]
        desc            <- map["description"]
        dueOn           <- (map["due_on"], DateTransform())
        identifier      <- map["id"]
        updatedAt       <- (map["updated_at"], DateTransform())
        title           <- map["title"]
        number          <- map["number"]
    }
}
