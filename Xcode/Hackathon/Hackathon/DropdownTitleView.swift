//
//  DropdownTitleView.swift
//  Hackathon
//
//  Created by Brendan Lee on 8/29/15.
//  Copyright (c) 2015 WeAreRoot. All rights reserved.
//

import UIKit

protocol DropdownTitleViewDelegate {
    func dropDownTitleViewWasSelected(dropdown:DropdownTitleView)
}

class DropdownTitleView: UIView {

    var dropdownDelegate: DropdownTitleViewDelegate?
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBAction func dropDownPressed(sender: AnyObject) {
        
        self.dropdownDelegate?.dropDownTitleViewWasSelected(self)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake(80, 33)
    }
}
