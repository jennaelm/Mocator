//
//  DetailMormonViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class DetailMormonViewController: UIViewController, MormonManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chatButton: RoundButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mutualFriendButton: MutualFriendsButton!
    
    let mormonManager = MormonManager()
    
    var allImages : [UIImage]!
    var mutualFriends = [String]()
    var detailMormon : Mormon?
    var facebookProfileURL : NSURL!
    var meUserId : String?
    var swipePosition = 0
    var meowMeow : Bool?
    var fbID : String?
    var buddyUserID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        customizeNavBar()
        
        self.swipePosition = 0
        self.mormonManager.delegate = self
        
        self.tableView.hidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.allImages = []
        self.mutualFriendButton.hasMutualFriends = false
        
        if self.detailMormon?.facebookLinkString == nil {
            self.mormonManager.fetchSpecificPerson(buddyUserID!)
        } else {
            let facebookProfileString = self.detailMormon?.facebookLinkString
            self.facebookProfileURL = NSURL(string: facebookProfileString!)
            self.facebookButton.addTarget(self, action: #selector(DetailMormonViewController.facebookButtonTapped(_:)), forControlEvents: .TouchUpInside)
            self.fbID = self.detailMormon?.fbID
        }
        
        imageViewsAsButtons()
        loadMormon()
        setUpSwipes()
        
        self.meUserId = NSUserDefaults.standardUserDefaults().stringForKey("id")
    }

    func loadMormon() {
        let imgViewArray = [self.imageView2, self.imageView3, self.imageView4, self.imageView5, self.imageView6]
        self.nameLabel.text = self.detailMormon?.name
        
        if self.detailMormon?.friends != nil {
            let matchMaker = FacebookMatchManager()
            self.mutualFriends = matchMaker.returnMutualFriends(self.detailMormon!.friends!)
            if self.mutualFriends.count > 0 {
                self.mutualFriendButton.hasMutualFriends = true
            }
        }
        
        self.detailMormon?.loadPhotos { images in
            dispatch_async(dispatch_get_main_queue()) {
                self.allImages = images
                self.imageView.image = images[0]
                
                if self.allImages.count != 1 {
                    var i = 0
                    for img in self.allImages {
                        imgViewArray[i].image = img
                        i += 1
                    }
                }
                
                if self.detailMormon!.about != nil {
                    self.aboutLabel!.text = self.detailMormon!.about
                }
            }
        }
    }
    
// Model Delegate
    
    func modelUpdated() {
        self.detailMormon = self.mormonManager.specificMormon!
        let facebookProfileString = self.detailMormon?.facebookLinkString
        self.facebookProfileURL = NSURL(string: facebookProfileString!)
        self.facebookButton.addTarget(self, action: #selector(DetailMormonViewController.facebookButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.fbID = self.detailMormon?.fbID
        loadMormon()
    }
    
    func errorUpdating(error: NSError) {
        print("error updating: \(error.localizedDescription)")
        // TO DO : alert : sorry... Network error.
    }


// Swiping Through Pics
    
    func setUpSwipes() {
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
                    animateFromLeft()
                    self.swipePosition = self.swipePosition - 1
                    print(self.swipePosition)
                    self.imageView.image = self.allImages[self.swipePosition]
                }
            case UISwipeGestureRecognizerDirection.Left :
                if self.swipePosition >= 4 {
                    // do nothing
                } else if self.swipePosition < self.allImages.count - 1 {
                    animateFromRight()
                    self.swipePosition = self.swipePosition + 1
                    self.imageView.image = self.allImages[self.swipePosition]
                }
            default :
                break
            }
        }
    }
    
    func animateFromLeft() {
        let rightAnimation = CATransition()
            rightAnimation.duration = 0.08
            rightAnimation.type = kCATransitionMoveIn
            rightAnimation.subtype = kCATransitionFromLeft
        self.imageView.layer.addAnimation(rightAnimation, forKey: "animateFromLeft")
    }
    
    func animateFromRight() {
        let leftAnimation = CATransition()
            leftAnimation.duration = 0.08
            leftAnimation.type = kCATransitionMoveIn
            leftAnimation.subtype = kCATransitionFromRight
        self.imageView.layer.addAnimation(leftAnimation, forKey: "animateFromRight")
    }
    
// Tapping Through Pics
    
    func imageViewsAsButtons() {
        let img2Rec = UITapGestureRecognizer(target: self,
            action:#selector(DetailMormonViewController.tappedImageTwo(_:)))
        let img3Rec = UITapGestureRecognizer(target: self,
            action: #selector(DetailMormonViewController.tappedImageThree(_:)))
        let img4Rec = UITapGestureRecognizer(target: self, action:#selector(DetailMormonViewController.tappedImageFour(_:)))
        let img5Rec = UITapGestureRecognizer(target: self, action:#selector(DetailMormonViewController.tappedImageFive(_:)))
        let img6Rec = UITapGestureRecognizer(target: self,
            action: #selector(DetailMormonViewController.tappedImageSix(_:)))
        
        self.imageView2.addGestureRecognizer(img2Rec)
        self.imageView3.addGestureRecognizer(img3Rec)
        self.imageView4.addGestureRecognizer(img4Rec)
        self.imageView5.addGestureRecognizer(img5Rec)
        self.imageView6.addGestureRecognizer(img6Rec)
    }
    
    func tappedImageTwo(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView2, swipePosition: 0)
    }
    func tappedImageThree(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView3, swipePosition: 1)
    }
    func tappedImageFour(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView4, swipePosition: 2)
    }
    func tappedImageFive(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView5, swipePosition: 3)
    }
    func tappedImageSix(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView6, swipePosition: 4)
    }
    
    func changeImage(pickedImageView: UIImageView, swipePosition: Int) {
        self.imageView.image = pickedImageView.image
        self.swipePosition = swipePosition
    }
    
// Button Taps

    @IBAction func facebookButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(self.facebookProfileURL)
    }
    
    @IBAction func chatTapped(sender: AnyObject) {
        addMormonToCoreData()
        self.performSegueWithIdentifier("toChatSegue", sender: self)
    }
    
    @IBAction func kittenTapped(sender: AnyObject) {
        self.meowMeow = true
        addMormonToCoreData()
        self.performSegueWithIdentifier("toChatSegue", sender: self)
    }
    
    @IBAction func seeConnectionsTapped(sender: AnyObject) {
        tableView.hidden = !tableView.hidden
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mutualFriends.count > 0 {
            return self.mutualFriends.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if self.mutualFriends.count > 0 {
            cell.textLabel!.text = self.mutualFriends[indexPath.row]
        } else {
            cell.textLabel!.text = "No friends in common"
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatSegue" {
            super.prepareForSegue(segue, sender: self)
            let navController = segue.destinationViewController as! UINavigationController
            let chatViewController = navController.viewControllers.first as! ChatUpMormonViewController
                chatViewController.mormonChatBuddy = self.detailMormon
                chatViewController.senderId = self.meUserId
                chatViewController.senderDisplayName = self.detailMormon?.name
            
            if self.meowMeow == true {
                chatViewController.catText = true
            }
        }
    }

// Core Data
    
    func addMormonToCoreData() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ChatBuddy")
            fetchRequest.predicate = NSPredicate(format: "userID == %@", self.detailMormon!.mormonUserID)
        var error: NSError? = nil
        let count = context.countForFetchRequest(fetchRequest, error: &error)
        
        if count == NSNotFound {
            print("Core Data Error: \(error?.localizedDescription)")
        } else if count == 0 {
            let newChatBuddy = NSEntityDescription.insertNewObjectForEntityForName("ChatBuddy", inManagedObjectContext: context) as! ChatBuddy
                newChatBuddy.userID = self.detailMormon!.mormonUserID
                newChatBuddy.name = self.detailMormon!.name
                newChatBuddy.lastMessageDate = NSDate()
            let profilePhoto = self.allImages[0]
            let profileData = UIImageJPEGRepresentation(profilePhoto, 1.0)
            newChatBuddy.profilePhotos = profileData
        }
        
        do {
            try context.save()
        } catch {
            // labor of love error handling
        }
    }
    
// User Interface
    
    func customizeNavBar() {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
        imgView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imgView
    }
    
}
