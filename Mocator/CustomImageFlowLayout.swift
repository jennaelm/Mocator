//
//  CustomImageFlowLayout.swift
//  Mocator
//
//  Created by Jenna Miller on 4/6/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    
    override var itemSize : CGSize {
        set {

        } get {
            let numberOfColumns : CGFloat = 3
            let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }

    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .Vertical
    }
}
