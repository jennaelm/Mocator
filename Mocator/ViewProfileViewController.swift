//
//  ViewProfileViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    var profPicString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Go be free
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        fetchFromCoreData()
        
    }
    
    func fetchFromCoreData() {
        print("startedFetching")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "FacebookInfo")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
            print("coredata results are nil")
        }
        
        if results != nil {
            print("results aren't nil")
            let infoFetched = results as? [FacebookInfo]!
            
            for person in infoFetched! {
                
                self.profPicString = person.imageString
                
           
            }
            
        }else {
            print("results are nil")
           
        }
        loadProfileImage()
    }
    
    func loadProfileImage() {
        dispatch_async(dispatch_get_main_queue(), {
            
            print("string: \(self.profPicString)")
            
            if self.profPicString != nil {
                let imgURL = NSURL(string: self.profPicString!)! as NSURL
                print("print: \(imgURL)")
                
                let imageData = NSData(contentsOfURL: imgURL)
                let profileImage = UIImage(data: imageData!)
                
                self.imageView.image = profileImage
            }
        })
    }

}
