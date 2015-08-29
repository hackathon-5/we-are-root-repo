//
//  RepoPickerHeaderView.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class RepoPickerHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clearColor()
        self.colorView.backgroundColor = UIColor(red: 56.0/255.0, green: 56.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    }
}
