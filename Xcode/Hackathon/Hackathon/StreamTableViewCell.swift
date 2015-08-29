//
//  StreamTableViewCell.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var bylineLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var contentImageView: UIImageView!
    
    @IBOutlet var bylineIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.02)
        self.backgroundColor = UIColor.clearColor()
        
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.bounds) / 2.0
        
        self.profileImageView.backgroundColor = UIColor.clearColor()
        
        if self.contentImageView != nil
        {
            self.contentImageView.layer.cornerRadius = 4.0
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
