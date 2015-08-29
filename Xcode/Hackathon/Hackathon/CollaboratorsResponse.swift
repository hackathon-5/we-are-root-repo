//
//  CollaboratorsResponse.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class CollaboratorsResponse: Mappable {
    
    var collaborators: Array<User>?
    
    class func newInstance(map: Map) -> Mappable? {
        return CollaboratorsResponse()
    }
    
    func mapping(map: Map) {
        collaborators    <- map["collaborators"]
    }
}
