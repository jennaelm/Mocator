//
//  FacebookMatchManager.swift
//  Mocator
//
//  Created by Jenna Miller on 7/13/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class FacebookMatchManager: NSObject {

    func returnMutualFriends(theirFriends: [String]) -> [String] {
        var myFriends = [String]()
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "FacebookFriend")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch {
            results = nil
            print("Error fetching chat buddies")
        }
        
        if results != nil {
            let friendsArray = results as! [FacebookFriend]
            for friend in friendsArray {
                myFriends.append(friend.name!)
            }
        }
        
        var mutualFriends = [String]()
        
        for friend in myFriends {
            if theirFriends.contains(friend) {
                mutualFriends.append(friend)
            }
        }
        
        return mutualFriends
    }
}
