//
//  DetailMormonViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class DetailMormonViewController: UIViewController {
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    var allImages = [UIImage]()
    var detailMormon : Mormon?
    var facebookProfileURL : NSURL!
    var meUserId : String?
    var swipePosition = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        let imgViewArray = [self.imageView, self.imageView2, self.imageView3, self.imageView4]
        for imgView in imgViewArray {
            imgView.backgroundColor = UIColor.clearColor()
        }
        
        self.detailMormon?.loadPhotos { images in
            dispatch_async(dispatch_get_main_queue()) {
                self.allImages = images
                
                var index = 0
                for imgView in imgViewArray {
                    if images.count > index {
                        imgView.image = images[index]
                        self.allImages.append(imgView.image!)
                        index = index + 1
                    }
                }
                
                if self.detailMormon!.about != nil {
                    self.aboutLabel!.text = self.detailMormon!.about
                }
            }
        }
        
        fetchFromCoreData()
        
        self.nameLabel.text = self.detailMormon?.name
        let facebookProfileString = self.detailMormon?.facebookLinkString
        self.facebookProfileURL = NSURL(string: facebookProfileString!)
        self.facebookButton.addTarget(self, action: #selector(DetailMormonViewController.facebookButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.imageView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.imageView.addGestureRecognizer(swipeLeft)
    }
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        if let swipeGesture = gesture as UISwipeGestureRecognizer? {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right :
                if self.swipePosition <= 0 {
                    // do nothing
                } else {
                    self.swipePosition = self.swipePosition - 1
                    print(self.swipePosition)
                    self.imageView.image = self.allImages[self.swipePosition]
                }
            case UISwipeGestureRecognizerDirection.Left :
                print("profile image count: \(self.allImages.count)")
                if self.swipePosition < self.allImages.count - 1 {
                    self.swipePosition = self.swipePosition + 1
                    print(self.swipePosition)
                    self.imageView.image = self.allImages[self.swipePosition]
                } else {
                    // do nothing
                }
            default :
                break
            }
        }
    }
    
    func fetchFromCoreData() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "FacebookInfo")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
            // labor of love error handling
        }
        
        if results != nil {
            let infoFetched = results as? [FacebookInfo]!
            for person in infoFetched! {
                self.meUserId = person.userID
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatSegue" {
            super.prepareForSegue(segue, sender: self)
            let navController = segue.destinationViewController as! UINavigationController
            let chatViewController = navController.viewControllers.first as! ChatUpMormonViewController
            chatViewController.mormonChatBuddy = self.detailMormon
            chatViewController.senderId = self.meUserId
            chatViewController.senderDisplayName = self.detailMormon?.name
        }
    }

    @IBAction func facebookButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(self.facebookProfileURL)
    }
    
    @IBAction func chatTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("toChatSegue", sender: self)
        addMormonToCoreData()
    }
    
    @IBAction func kittenTapped(sender: AnyObject) {
        print("Meow meow.")
        // send chat with a bunch of 😻 (?)
    }
    
    func addMormonToCoreData() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let newChatBuddy = NSEntityDescription.insertNewObjectForEntityForName("ChatBuddy", inManagedObjectContext: context) as! ChatBuddy
        newChatBuddy.userID = self.detailMormon!.mormonUserID
        newChatBuddy.name = self.detailMormon!.name
        newChatBuddy.lastMessageDate = NSDate()
        do {
            try context.save()
        } catch {
            // labor of love error handling
        }
    }
    
}
