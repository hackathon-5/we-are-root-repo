//
//  RepoPickerTableViewCell.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class RepoPickerTableViewCell: UITableViewCell {

    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        
        self.selectedBackgroundView = UIView()
        
        self.selectedBackgroundView?.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
