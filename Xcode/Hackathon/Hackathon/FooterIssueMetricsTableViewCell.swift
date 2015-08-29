//
//  FooterIssueMetricsTableViewCell.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class FooterIssueMetricsTableViewCell: UITableViewCell {

    @IBOutlet var assignedToLabel: UILabel!
    
    @IBOutlet var milestoneLabel: UILabel!
    
    @IBOutlet var labelsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
