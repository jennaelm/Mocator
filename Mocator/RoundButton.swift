//
//  RoundButton.swift
//  Mocator
//
//  Created by Jenna Miller on 7/6/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 25/160, green: 33/160, blue: 61/160, alpha: 1).CGColor
        self.backgroundColor = UIColor(red: 25/160, green: 33/160, blue: 61/160, alpha: 1)
        self.clipsToBounds = true
    }

}
