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
    
    @IBOutlet weak var imgView: RoundedImageView!
    
    var delegate : ImageCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.imgView)
        
        self.addConstraint(NSLayoutConstraint(item: self.imgView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.imgView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.imgView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.imgView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeItCircle()
    }
    
    func makeItCircle() {
        self.imgView.layer.masksToBounds = true
        self.imgView.layer.cornerRadius  = CGFloat(roundf(Float(self.imgView.frame.size.width/2.0)))
        self.imgView.layer.borderWidth = 5.0
        let backgroundGreyColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.imgView.layer.borderColor = backgroundGreyColor.CGColor
    }

}
