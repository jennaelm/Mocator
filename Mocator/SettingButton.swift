//
//  SettingButton.swift
//  Mocator
//
//  Created by Jenna Miller on 4/4/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class SettingButton: UIButton {
    
   let darkBlueColor = UIColor(red: 25/160, green: 33/160, blue: 61/160, alpha: 1)
    
    var isChecked : Bool? {
        didSet{
            if isChecked == true {
                self.selected = true
                self.backgroundColor = UIColor(red: 64/255, green: 128/255, blue: 0/255, alpha: 1)
                self.titleLabel!.font = UIFont.systemFontOfSize(15.0)
            } else {
                self.selected = false
                self.backgroundColor = UIColor(red: 131/255, green: 22/255, blue: 42/255, alpha: 1)
                self.titleLabel!.font = UIFont.systemFontOfSize(15.0)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(SettingButton.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.size.width/50
        self.clipsToBounds = true
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
