//
//  DetailMormonViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class DetailMormonViewController: UIViewController {

    var detailMormon : Mormon?
    var facebookProfileURL : NSURL!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

    // Go be free
        
        self.nameLabel.text = self.detailMormon?.name
        self.aboutLabel.text = self.detailMormon?.about
        
        let facebookProfileString = self.detailMormon?.facebookLinkString
        self.facebookProfileURL = NSURL(string: facebookProfileString!)
    
        self.facebookButton.addTarget(self, action: "facebookButtonTapped:", forControlEvents: .TouchUpInside)
    }

    @IBAction func facebookButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(self.facebookProfileURL)
    }
    
    @IBAction func chatTapped(sender: AnyObject) {
        
    }
    
}
