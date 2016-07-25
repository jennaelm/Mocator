//
//  ChatListTableViewCell.swift
//  Mocator
//
//  Created by Jenna Miller on 5/24/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chatImage.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
