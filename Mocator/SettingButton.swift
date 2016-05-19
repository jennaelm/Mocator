//
//  SettingButton.swift
//  Mocator
//
//  Created by Jenna Miller on 4/4/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class SettingButton: UIButton {
    
    var isChecked : Bool? {
        didSet{
            if isChecked == true {
                self.backgroundColor = UIColor.orangeColor()
                self.titleLabel!.textColor = UIColor.whiteColor()
                self.titleLabel!.font = UIFont.boldSystemFontOfSize(16.0)
            } else {
                self.backgroundColor = UIColor.grayColor()
                self.titleLabel!.font = UIFont.systemFontOfSize(13.0)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(SettingButton.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
