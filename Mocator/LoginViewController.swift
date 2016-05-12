//
//  LoginViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate {
    
    var userName = ""
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    let model : Model = Model.sharedInstance()
    
    var profilePicLink : String?
    var firstName : String?
    var lastName : String?
    var userLink : String!
    var userGender : String?
    var userID : String!
    var userLocation : CLLocation?
    
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Go be free
        
        self.locationManager = CLLocationManager()
        getLocationPermission()
        locationManager.startUpdatingLocation()
        
        UserInfo.sharedInstance.iCloudUserIDAsync() {
            recordID, error in
            if let _ = recordID?.recordName {
                print("successfully logged in with CloudKit")
            } else {
                self.generateCloudKitAlert()
            }
        }
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let facebookSearchRequest = NSFetchRequest(entityName: "FacebookInfo")
        var facebookResults : [AnyObject]?
        
        do {
            facebookResults = try context.executeFetchRequest(facebookSearchRequest)
        } catch _ {
            facebookResults = nil
        }
        
        if facebookResults != nil {
            let infoFetched = facebookResults as? [FacebookInfo]!
            for person in infoFetched! {
                model.meIDGlobal = person.userID
                model.userGenderGlobal = person.gender
            }
        }
    }
    
    func getLocationPermission() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("Location services disabled DUN DUN DUNNNNNN")
            print("Fix: Request again?")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated")
        
        if locations.count > 0 {
            self.userLocation = locations[0]
            locationManager.stopUpdatingLocation()
        }
        
        
    }
    
    func generateCloudKitAlert() {
        let alertController = UIAlertController(title: "Login to iCloud", message: "You must be logged in to your iCloud account to use Mocator.", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        alertController.addAction(settingsAction)
        
        dispatch_after(1, dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in
            dispatch_async(dispatch_get_main_queue()){
                self.performSegueWithIdentifier("segueToFirstScreen", sender: self)
            }
        } else {
            // Proceed to login                     
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "user_likes"]
            loginView.delegate = self
            
        }
    }
    
    
// Facebook
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) { dispatch_async(dispatch_get_main_queue()){
        
        if ((error) != nil) {
            print("Error type: \(error.localizedDescription)")
        } else if result.isCancelled {
            print("login cancelled")
            // Handle cancellations
        } else {
            self.getFacebookInformation()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func getFacebookInformation() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "id, email, likes, first_name, last_name, link, gender"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print("Error fetching facebook information: \(error.localizedDescription)")
                // labor of love error handling
            } else {
                let fbUserID = result.valueForKey("id") as! String
                self.profilePicLink = "http://graph.facebook.com/\(fbUserID)/picture?type=large"
                self.firstName = result.valueForKey("first_name") as? String
                self.lastName = result.valueForKey("last_name") as? String
                self.userLink = result.valueForKey("link") as! String
                self.userGender = result.valueForKey("gender") as? String
                self.userID = "M\(fbUserID)\(self.lastName!)"
                
                self.storeInCoreDataAndCloudKit()
            }
        })
    }
    
// CoreData

    func storeInCoreDataAndCloudKit() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let facebookSearchRequest = NSFetchRequest(entityName: "FacebookInfo")
        var facebookResults : [AnyObject]?
        
        do {
            facebookResults = try context.executeFetchRequest(facebookSearchRequest)
        } catch _ {
            facebookResults = nil
        }
        
        if facebookResults?.count > 0 {
            print("already have fb results stored in Core Data")
        } else {
            let newFbInfo = NSEntityDescription.insertNewObjectForEntityForName("FacebookInfo", inManagedObjectContext: context) as! FacebookInfo
            
            let imageURL = NSURL(string: self.profilePicLink!)
            let imageData = NSData(contentsOfURL: imageURL!)
            let CDataArray = NSMutableArray()
            CDataArray.addObject(imageData!)
            let coreDataObject = NSKeyedArchiver.archivedDataWithRootObject(CDataArray)
            
            newFbInfo.firstName = self.firstName
            newFbInfo.lastName = self.lastName
            newFbInfo.profilePhotos = coreDataObject
            newFbInfo.profileURL = self.userLink
            newFbInfo.gender = self.userGender
            newFbInfo.userID = self.userID
            
            let genericLookingFor = ["friends", "dates"]
            
            print("location: \(self.userLocation)")
            
            self.userLocation = CLLocation(latitude: 50, longitude: 50)
            
            model.pushPersonToCloudKit(self.userID!, firstName: self.firstName!, lastName: self.lastName!, picString: self.profilePicLink!, profileLink: self.userLink!, gender: self.userGender!, lookingFor: genericLookingFor, location: self.userLocation!)
                
            do {
                try context.save()
            } catch {
                // labor of love error handling
            }
        }
    }
    
}

