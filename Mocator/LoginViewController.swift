//
//  LoginViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var userName = ""
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    
    var profilePicLink : String?
    var firstName : String?
    var lastName : String?
    var userLink : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Go be free
        
        UserInfo.sharedInstance.iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
            } else {
                print("Fetched iCloudID was nil")
            }
        }
        
        getFacebookInformation()
        // actually call this in "viewDidAppear" only if they haven't logged in before
        
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
    
    
// Facebook Login Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) { dispatch_async(dispatch_get_main_queue()){
        
        if ((error) != nil) {
            print("Error type: \(error.localizedDescription)")
        } else if result.isCancelled {
            print("login cancelled")
            // Handle cancellations
        }
        }
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
// Handling Facebook Info
    
    func getFacebookInformation() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "id, email, likes, first_name, last_name, link"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print("Error: \(error.localizedDescription)")
            } else {
                let userID = result.valueForKey("id") as! NSString
                self.profilePicLink = "http://graph.facebook.com/\(userID)/picture?type=large"
                self.firstName = result.valueForKey("first_name") as? String
                self.lastName = result.valueForKey("last_name") as? String
                self.userLink = result.valueForKey("link") as? String
                
                self.storeInCoreData()
            }
        })
    }

    func storeInCoreData() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let facebookSearchRequest = NSFetchRequest(entityName: "FacebookInfo")
        var facebookResults : [AnyObject]?
        
        do {
            facebookResults = try context.executeFetchRequest(facebookSearchRequest)
        } catch _ {
            facebookResults = nil
        }
        
        if (facebookResults?.count > 0) {
            print("There is something already in Core Data for Facebook Results")
        } else {
            let newFbInfo = NSEntityDescription.insertNewObjectForEntityForName("FacebookInfo", inManagedObjectContext: context) as! FacebookInfo
            newFbInfo.firstName = self.firstName
            newFbInfo.lastName = self.lastName
            newFbInfo.imageString = self.profilePicLink
            newFbInfo.profileURL = self.userLink
            
            print("facebook info: \(newFbInfo)")
            
            do {
                try context.save()
            } catch {
                // HANDLE ERROR CONDITION
            }
        }
    }
    
}

