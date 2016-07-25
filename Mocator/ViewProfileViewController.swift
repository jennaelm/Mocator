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
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var imageData : NSData?
    var mormonDescription : String?
    var mormonName = ""
    var imgViewArray = [UIImageView]()
    var profileImages = [UIImage]()
    var swipePosition = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        customizeNavBar()
        setUpRevealController()
        fetchFromCoreData()
        
        self.imgViewArray = [imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix]
        imageViewsAsButtons()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.imageView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.imageView.addGestureRecognizer(swipeLeft)
    }
    
    func customizeNavBar() {
        let imgView = UIImageView()
            imgView.image = UIImage(named: "logo")
            imgView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imgView
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchFromCoreData()
    }
    
// Swiping Through Pics
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        if let swipeGesture = gesture as UISwipeGestureRecognizer? {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right :
                if self.swipePosition <= 0 {
                    // do nothing
                } else {
                    animateImageFromLeft()
                    self.swipePosition = self.swipePosition - 1
                    self.imageView.image = self.profileImages[self.swipePosition]
                }
            case UISwipeGestureRecognizerDirection.Left :
                if self.swipePosition >= (self.profileImages.count - 1) {
                    // do nothing
                } else {
                    animateImageFromRight()
                    self.swipePosition = self.swipePosition + 1
                    self.imageView.image = self.profileImages[self.swipePosition]
                }
            default :
                break
            }
        }
    }
    
    func animateImageFromLeft() {
        let rightAnimation = CATransition()
        rightAnimation.duration = 0.08
        rightAnimation.type = kCATransitionMoveIn
        rightAnimation.subtype = kCATransitionFromLeft
        self.imageView.layer.addAnimation(rightAnimation, forKey: "animateFromLeft")
    }
    
    func animateImageFromRight() {
        let leftAnimation = CATransition()
        leftAnimation.duration = 0.08
        leftAnimation.type = kCATransitionMoveIn
        leftAnimation.subtype = kCATransitionFromRight
        self.imageView.layer.addAnimation(leftAnimation, forKey: "animateFromRight")
    }

// Tapping Through Pics
    
    func imageViewsAsButtons() {
        let img2Rec = UITapGestureRecognizer(target: self,
            action:#selector(ViewProfileViewController.tappedImageTwo(_:)))
        let img3Rec = UITapGestureRecognizer(target: self,
            action: #selector(ViewProfileViewController.tappedImageThree(_:)))
        let img4Rec = UITapGestureRecognizer(target: self,
            action:#selector(ViewProfileViewController.tappedImageFour(_:)))
        let img5Rec = UITapGestureRecognizer(target: self,
            action:#selector(ViewProfileViewController.tappedImageFive(_:)))
        let img6Rec = UITapGestureRecognizer(target: self,
            action: #selector(ViewProfileViewController.tappedImageSix(_:)))
        
        self.imageViewTwo.addGestureRecognizer(img2Rec)
        self.imageViewThree.addGestureRecognizer(img3Rec)
        self.imageViewFour.addGestureRecognizer(img4Rec)
        self.imageViewFive.addGestureRecognizer(img5Rec)
        self.imageViewSix.addGestureRecognizer(img6Rec)
    }
    
    func tappedImageTwo(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewTwo, swipePosition: 0)
    }
    func tappedImageThree(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewThree, swipePosition: 1)
    }
    func tappedImageFour(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewFour, swipePosition: 2)
    }
    func tappedImageFive(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewFive, swipePosition: 3)
    }
    func tappedImageSix(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewSix, swipePosition: 4)
    }
    
    func changeImage(pickedImageView: UIImageView, swipePosition: Int) {
        self.imageView.image = pickedImageView.image
        self.swipePosition = swipePosition
    }
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
// Fetching and Populating
    
    func fetchFromCoreData() {
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
            let infoFetched = results as? [FacebookInfo]!
            
            for person in infoFetched! {
                self.mormonName = person.firstName!
                self.imageData = person.profilePhotos
                
                if person.userDescription != nil {
                    self.mormonDescription = person.userDescription
                }
                
                dataToImages()
            }
        } else {
            print("results are nil")
        }
        updateView()
    }
    
    func dataToImages() {
        let mySavedData = NSKeyedUnarchiver.unarchiveObjectWithData(self.imageData!) as! NSMutableArray?
        self.profileImages = []
        for each in mySavedData! {
            let profileData = each as! NSData
            let profileImage = UIImage(data: profileData)
            self.profileImages.append(profileImage!)
        }
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.nameLabel.text = self.mormonName
            self.imageView.image = self.profileImages[0]
            var index = 0
            for imgView in self.imgViewArray {
                if self.profileImages.count > index {
                    imgView.image = self.profileImages[index]
                    index = index + 1
                }
            }
            
            if self.mormonDescription != nil {
                self.descriptionLabel!.text = self.mormonDescription
            }
        })
    }

// Button Tap
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toEditSegue" {
            let editViewController = segue.destinationViewController as! EditProfileViewController
            
            if self.mormonDescription != nil {
                editViewController.userDescription = self.mormonDescription
            }
            
            if profileImages.count > 0 {
                editViewController.profileImages = self.profileImages
            }
        }
    }

}
