//
//  RoundedImageView.swift
//  Mocator
//
//  Created by Jenna Miller on 4/6/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2.0
        self.clipsToBounds = true
    }
    
}
