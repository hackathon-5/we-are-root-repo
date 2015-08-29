//
//  RepoPickerOrgModel.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class RepoPickerOrgModel: NSObject {
   
    /// The name to show
    var displayName: String?
    
    /// The list of repositories for the current model
    var repositories: Array<BasicRepository> = Array<BasicRepository>()
    
}
