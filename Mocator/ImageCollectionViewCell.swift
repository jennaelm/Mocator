//
//  ImageCollectionViewCell.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate {
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var delegate : ImageCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.image = nil
    }
    
}
