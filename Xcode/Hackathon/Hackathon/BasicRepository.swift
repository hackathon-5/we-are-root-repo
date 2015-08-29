//
//  BasicRepository.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class BasicRepository: Mappable {
    
    /// The identifier of the repository
    var identifier: Int?
    
    /// The name of the repository for display
    var name: String?
    
    /// The owner of the repository
    var owner: BasicRepositoryOwner?
   
    class func newInstance(map: Map) -> Mappable? {
        return BasicRepository()
    }
    
    func mapping(map: Map) {
        name                <- map["name"]
        identifier          <- map["id"]
        owner               <- map["owner"]
    }
    
}
