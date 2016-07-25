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
import CloudKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate {
    
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    let mormonManager = MormonManager()
    
    var profilePicLink : String?
    var firstName : String?
    var lastName : String?
    var userLink : String!
    var userGender : String?
    var userID : String!
    var userLocation : CLLocation?
    var fbUserID : String?
    var locationManager : CLLocationManager!
    var userName = ""
    var friendNames = [String]()
    
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
        
        if facebookResults == nil {
            self.getFacebookInformation{ (success) in
                self.storeInCoreDataAndCloudKit()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            dispatch_async(dispatch_get_main_queue()){
                self.performSegueWithIdentifier("segueToFirstScreen", sender: self)
            }
        } else {
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "user_friends"]
            loginView.delegate = self
        }
    }

// Location Manager
    
    func getLocationPermission() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
// Facebook Login Delegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) { dispatch_async(dispatch_get_main_queue()){
        if ((error) != nil) {
            print("Error type: \(error.localizedDescription)")
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            self.getFacebookInformation{ (success) in
                self.storeInCoreDataAndCloudKit()
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
// Fetch and Store Facebook Information
    
    func getFacebookInformation(completionClosure: (success:Bool) ->()) {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "id, first_name, last_name, link, gender, likes"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            self.requestFacebookFriends()
                
            if ((error) != nil) {
                print("Error fetching facebook information: \(error.localizedDescription)")
            } else {
                self.fbUserID = result.valueForKey("id") as? String
                self.profilePicLink = "http://graph.facebook.com/\(self.fbUserID!)/picture?type=large"
                self.firstName = result.valueForKey("first_name") as? String
                self.lastName = result.valueForKey("last_name") as? String
                self.userLink = result.valueForKey("link") as! String
                self.userGender = result.valueForKey("gender") as? String
                self.userID = "M\(self.fbUserID!)\(self.lastName!)"
                
                NSUserDefaults.standardUserDefaults().setObject("\(self.userGender!)", forKey: "gender")
                NSUserDefaults.standardUserDefaults().setObject("\(self.userID!)", forKey: "id")
                
                let flag = true
                completionClosure(success: flag)
            }
        })
    }
    
    func requestFacebookFriends() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters:["fields": "id"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            let resultdict = result! as! NSDictionary
            print("Result Dict: \(resultdict)")
            let friendsArray : NSArray = resultdict.objectForKey("data") as! NSArray
            
            for dict in friendsArray {
                if let name = dict["name"] as! String? {
                    self.friendNames.append(name)
                }
            }
        })
    }

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
            
            if self.userLocation == nil {
                self.userLocation = CLLocation(latitude: 37, longitude: 122)
            }
            
            if self.friendNames.count > 0 {
                for friendName in self.friendNames {
                    let newFriend = NSEntityDescription.insertNewObjectForEntityForName("FacebookFriend", inManagedObjectContext: context) as! FacebookFriend
                    newFriend.name = friendName
                }
            }

            self.mormonManager.pushPersonToCloudKit(self.userID!, firstName: self.firstName!, lastName: self.lastName!, picString: self.profilePicLink!, fbID: self.fbUserID!, profileLink: self.userLink!, gender: self.userGender!, lookingFor: genericLookingFor, location: self.userLocation!, friendList: self.friendNames)
            
            do {
                try context.save()
            } catch {
               // error handling
            }
        }
    }
    
}

