//
//  MutualFriendsButton.swift
//  Mocator
//
//  Created by Jenna Miller on 7/13/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class MutualFriendsButton: UIButton {

    var hasMutualFriends : Bool? {
        didSet{
            if hasMutualFriends == true {
                self.enabled = true
                self.titleLabel!.text = "Show Mutual Friends"
                self.titleLabel!.textColor = UIColor.blueColor()
            } else {
                self.enabled = false
                self.titleLabel!.text = "No Mutual Friends"
                self.titleLabel!.textColor = UIColor.lightGrayColor()
            }
        }
    }
    
}
