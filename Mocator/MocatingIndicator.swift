//
//  MocatingIndicator.swift
//  Mocator
//
//  Created by Jenna Miller on 5/23/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class MocatingIndicator {
    var view: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var title: String!
    
    init(title: String, center: CGPoint, width: CGFloat = 200.0, height: CGFloat = 50.0) {
        self.title = title
        
        let x = center.x - width/2.0
        let y = center.y - height/2.0
        
        self.view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.view.backgroundColor = UIColor(red: 23/160, green: 35/160, blue: 61/160, alpha: 0.8)
        self.view.layer.cornerRadius = 10
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.color = UIColor.whiteColor()
        self.activityIndicator.hidesWhenStopped = false
        
        let titleLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        titleLabel.text = title
        titleLabel.textColor = UIColor.whiteColor()
        
        self.view.addSubview(self.activityIndicator)
        self.view.addSubview(titleLabel)
    }
    
    func getViewActivityIndicator() -> UIView {
        return self.view
    }
    
    func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
        self.view.removeFromSuperview()
    }

}