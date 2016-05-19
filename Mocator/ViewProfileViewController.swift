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
        
        setUpRevealController()
        fetchFromCoreData()
        
        self.imgViewArray = [imageView, imageViewTwo, imageViewThree, imageViewFour]
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.imageView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.imageView.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchFromCoreData()
    }
    
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        if let swipeGesture = gesture as UISwipeGestureRecognizer? {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right :
                if self.swipePosition > 0 {
                    self.swipePosition = self.swipePosition - 1
                    print(self.swipePosition)
                    self.imageView.image = self.profileImages[self.swipePosition]
                }
            case UISwipeGestureRecognizerDirection.Left :
                print("profile image count: \(self.profileImages.count)")
                if self.swipePosition < self.profileImages.count - 1 {
                    self.swipePosition = self.swipePosition + 1
                    print(self.swipePosition)
                    self.imageView.image = self.profileImages[self.swipePosition]
                } else {
                    // do nothing
                }
            default :
                break
            }
        }
    }
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
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
            print("coredata results are nil")
        }
        
        if results != nil {
            print("results aren't nil")
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
