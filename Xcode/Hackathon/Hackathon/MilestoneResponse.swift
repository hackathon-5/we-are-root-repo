//
//  MilestoneResponse.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class MilestoneResponse: Mappable {
   
    var milestones: Array<Milestone>?
    
    class func newInstance(map: Map) -> Mappable? {
        return MilestoneResponse()
    }
    
    func mapping(map: Map) {
        milestones    <- map["milestones"]
    }
    
}
