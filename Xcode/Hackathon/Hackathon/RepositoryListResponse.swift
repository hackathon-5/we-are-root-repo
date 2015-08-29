//
//  RepositoryListResponse.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit
import ObjectMapper

class RepositoryListResponse: Mappable {
   
    var organizations: Array<BasicOrganization>?
    
    var repositories: Array<BasicRepository>?
    
    class func newInstance(map: Map) -> Mappable? {
        return RepositoryListResponse()
    }
    
    func mapping(map: Map) {
        organizations                <- map["organizations"]
        repositories                 <- map["repos"]
    }
}
