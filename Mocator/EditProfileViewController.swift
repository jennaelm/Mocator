//
//  EditProfileViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/18/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewBig: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var descriptionField: UITextField!
    
    let model: Model = Model.sharedInstance()
    
    var imageViewArray = [UIImageView]()
    var originalProfileImage : UIImage!
    let imagePicker = UIImagePickerController()
    var pickedImageView : UIImageView?
    var photoAssets = [CKAsset]()
    var pickedPhotos = [UIImage]()
    var userDescription : String?
    var profileImages : [UIImage]?
    var swipePosition : NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        self.imagePicker.delegate = self
        self.imageViewArray = [imageViewBig, imageView2, imageView3, imageView4]
        self.imageViewBig.image = originalProfileImage
        
        
        var index = 0
        for imgView in self.imageViewArray {
            if self.profileImages?.count > index {
                imgView.image = profileImages![index]
                index = index + 1
                }
            }
        
        if self.userDescription != nil {
            self.descriptionField.text = self.userDescription
        }
        
        imageViewsAsButtons()
    }
    
    func imageViewsAsButtons() {
        let img1Rec = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tappedBigImage(_:)))
        let img2Rec = UITapGestureRecognizer(target: self, action:#selector(EditProfileViewController.tappedImageTwo(_:)))
        let img3Rec = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tappedImageThree(_:)))
        let img4Rec = UITapGestureRecognizer(target: self, action:#selector(EditProfileViewController.tappedImageFour(_:)))
        
        self.imageViewBig.addGestureRecognizer(img1Rec)
        self.imageView2.addGestureRecognizer(img2Rec)
        self.imageView3.addGestureRecognizer(img3Rec)
        self.imageView4.addGestureRecognizer(img4Rec)
    }
    
    func tappedBigImage(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageViewBig)
    }
    func tappedImageTwo(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView2)
    }
    func tappedImageThree(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView3)
    }
    func tappedImageFour(recognizer: UITapGestureRecognizer) {
        changeImage(self.imageView4)
    }
    
    func changeImage(imageView: UIImageView) {
        self.pickedImageView = imageView
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func saveTapped(sender: AnyObject) {
        var descrip : String?
        if self.descriptionField.text == nil {
            descrip = nil
        } else {
            descrip = self.descriptionField.text
        }
        
        var allImages = [UIImage]()
        for imgView in self.imageViewArray {
            if imgView.image == nil {
                // do nothing
            } else if imgView.image == UIImage(named: "plus") {
                // do nothing
            } else {
                allImages.append(imgView.image!)
                let asset = model.imageToAsset(imgView.image!)
                self.photoAssets.append(asset)
            }
        }
        
        model.updatePersonInCloudKit(descrip, photos: self.photoAssets)
        
        let CDataArray = NSMutableArray()
        for img in allImages {
            let data : NSData = NSData(data: UIImageJPEGRepresentation(img, 1.0)!)
            CDataArray.addObject(data)
        }
        let coreDataData = NSKeyedArchiver.archivedDataWithRootObject(CDataArray)
        updateCoreData(descrip, imageData: coreDataData)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateCoreData(descrip: String?, imageData: NSData) {
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
                if descrip != nil {
                    person.userDescription = descrip
                }
                person.profilePhotos = imageData
            }
        } else {
            print("results are nil")
        }
        
        do {
            try context.save()
        } catch {
            print("Could not save to Core Data while editing profile")
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if self.pickedImageView != nil {
            if let pickedImage = image as UIImage? {
                self.pickedImageView!.image = pickedImage
                self.pickedPhotos.append(pickedImage)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
