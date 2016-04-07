//
//  SettingButton.swift
//  Mocator
//
//  Created by Jenna Miller on 4/4/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class SettingButton: UIButton {
    
    var isChecked : Bool = true {
        didSet{
            if isChecked == true {
                self.backgroundColor = UIColor.grayColor()
            } else {
                self.backgroundColor = UIColor.orangeColor()
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = true
    }
    
    func buttonTapped(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
}
