//
//  Model.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreLocation
import CoreData

let PersonType = "Person"

@objc protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
    optional func newMessages()
}

class Model {
    
    class func sharedInstance() -> Model {
        return modelSingletonGlobal
    }
    
    var delegate : ModelDelegate?
    var items = [Mormon]()
    
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    
    var predicate : NSPredicate?
    
    var userGenderGlobal : String?
    var meIDGlobal : String?
    
    var downloadedMessages = [MessagePlainObject]()
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func refresh() {
        let query = CKQuery(recordType: "Person", predicate: self.predicate!)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    print("error loading: \(error)")
                }
            } else {
                self.items.removeAll(keepCapacity: true)
                for record in results! {
                    let mormon = Mormon(record: record, database:self.publicDB, serverID:record.recordID.recordName)
                    self.items.append(mormon)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                }
            }
        }
    }
    
    func fetchPersons(location:CLLocation,
        radiusInMeters:CLLocationDistance, genders:[String], lookingFor:[String]) {
            var predicateArray = [NSPredicate]()
           //   let radiusInKilometers = radiusInMeters / 1000.0
           //  let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
           //      "Location",
           //      location,
           //      radiusInKilometers)
           // predicateArray.append(locationPredicate)
            
            if genders.count > 1 {
                print("Looking for both genders")
            } else {
                let genderPredicate = NSPredicate(format: "Gender == %@", genders[0])
                predicateArray.append(genderPredicate)
            }
            
            if lookingFor.count > 1 {
                print("Looking for both friends and dates")
            } else {
                let typePredicate = NSPredicate(format: "LookingFor CONTAINS %@", lookingFor[0])
                predicateArray.append(typePredicate)
            }
        
            let selfPredicate = NSPredicate(format: "NOT (UserID == %@)", self.meIDGlobal!)
            predicateArray.append(selfPredicate)
        
            self.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicateArray)
            let query = CKQuery(recordType: PersonType,
                predicate: self.predicate!)
        
           // let operation = CKQueryOperation(query: query)
           //     operation.resultsLimit = 30
            // To do: figure out how to paginate by using operation
    
            self.publicDB.performQuery(query, inZoneWithID: nil) {
                results, error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.errorUpdating(error!)
                        return
                    }
                } else {
                    print("items: \(self.items)")
                    self.items.removeAll(keepCapacity: true)
                    for record in results! {
                        let mormon = Mormon(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                        self.items.append(mormon)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.modelUpdated()
                        return
                    }
                }
            }
        }
    
    func pushPersonToCloudKit(userID: String, firstName: String, lastName: String, picString: String, fbID: String, profileLink: String, gender: String, lookingFor: [String], location: CLLocation) {

        let mormonRecordID = CKRecordID(recordName: firstName + lastName + userID)
        let url = NSURL(string: picString)! as NSURL

        let imageData = NSData(contentsOfURL: url)
        let nsUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString+".dat")
        
        do {
            try imageData!.writeToURL(nsUrl, options: [])
        } catch let e as NSError {
            print("Error! \(e)");
            return
        }
    
        var assetArray = [CKAsset]()
        let asset = CKAsset(fileURL: nsUrl)
        assetArray.append(asset)
        
        let mormonRecord = CKRecord(recordType: "Person", recordID: mormonRecordID)
            mormonRecord["Name"] = firstName
            mormonRecord["LastName"] = lastName
            mormonRecord["Gender"] = gender
            mormonRecord["FacebookLink"] = profileLink
            mormonRecord["Photos"] = assetArray
            mormonRecord["Location"] = location
            mormonRecord["LookingFor"] = lookingFor
            mormonRecord["UserID"] = userID
            mormonRecord["FbID"] = fbID
 
            self.userGenderGlobal = gender
            self.meIDGlobal = userID
        
        subscribeToMessages()
        
        self.publicDB.saveRecord(mormonRecord, completionHandler: { (record, error) in
            if error != nil {
                print("error: \(error?.localizedDescription)")
                // labor of love error handling
            } else {
               
            }
        })
    }
    
    func updateLocationInCloudKit(location: CLLocation) {
        let mePredicate = NSPredicate(format: "UserID == %@", self.meIDGlobal!)
        let query = CKQuery(recordType: PersonType,
                            predicate: mePredicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            } else {
                for myRecord in results! {
                    myRecord["Location"] = location
                
                    self.publicDB.saveRecord(myRecord, completionHandler: { (record, error) in
                        if error != nil {
                            print("error updating record: \(error?.localizedDescription)")
                            // labor of love error handling
                        } else {
                            print("My record updated successfully")
                        }
                    })
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    return
                }
            }
        }
    }
    
    func updatePersonInCloudKit(description: String?, photos: [CKAsset]) {
        let mePredicate = NSPredicate(format: "UserID == %@", self.meIDGlobal!)
        let query = CKQuery(recordType: PersonType,
                            predicate: mePredicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            } else {
                for myRecord in results! {
                    if description != nil {
                        myRecord["About"] = description
                    }
                   
                    if photos.count > 0 {
                        myRecord["Photos"] = photos
                    } else {
                        print("not updating fotos")
                    }
                    
                self.publicDB.saveRecord(myRecord, completionHandler: { (record, error) in
                        if error != nil {
                            print("error updating record: \(error?.localizedDescription)")
                            // labor of love error handling
                        } else {
                            print("My record updated successfully")
                        }
                })
            }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    return
                }
            }
        }
    }
    
    func imageToAsset(image: UIImage) -> CKAsset {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let nsUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString+".dat")
        
        do {
            try imageData!.writeToURL(nsUrl, options: [])
        } catch let e as NSError {
            print("Error! \(e)");
        }
        
        let asset = CKAsset(fileURL: nsUrl)
        return asset
    }
    
    func subscribeToMessages() {
        let predicate = NSPredicate(format:"RecipientID = %@", self.meIDGlobal!)
        let subscription = CKSubscription(recordType: "Message", predicate: predicate, options: .FiresOnRecordCreation)
        
        let notification = CKNotificationInfo()
        notification.alertBody = "New Message"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        subscription.notificationInfo = notification
        
        self.publicDB.saveSubscription(subscription) { (result, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print ("successfully saved subscription")
            }
        }
    }
    
    func sendMessage(recipientID: String, senderID: String, text: String, date: NSDate) {
        let messageRecordID = CKRecordID(recordName: senderID + recipientID + "\(date)")
        let messageRecord = CKRecord(recordType: "Message", recordID: messageRecordID)
        messageRecord["Date"] = date
        messageRecord["Text"] = text
        messageRecord["RecipientID"] = recipientID
        messageRecord["SenderID"] = senderID
    
        self.publicDB.saveRecord(messageRecord, completionHandler: { (record, error) in
            if error != nil {
                print("error sending message: \(error?.localizedDescription)")
                // labor of love error handling
                // maybe retry?
            } else {
                print("message sent successfully")
            }
        })
    }
    
    func receiveNewMessages() {
        self.delegate?.newMessages!()
    }
    
    func downloadMessagesFromCloudKit(recipientID: String, senderID: String) {
        let toPredicate = NSPredicate(format: "SenderID == %@ AND RecipientID == %@", senderID, recipientID)
        let query = CKQuery(recordType: "Message", predicate: toPredicate)
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            } else {
                for record in results! {
                    let eachMessage = MessagePlainObject(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                    self.downloadedMessages.append(eachMessage)
                    print(eachMessage)
                }
                
                self.secondQuery(recipientID, senderID: senderID)
            }
        }
    }

    func secondQuery(recipientID: String, senderID: String) {
        let fromPredicate = NSPredicate(format: "SenderID == %@ AND RecipientID == %@", recipientID, senderID)
        let query = CKQuery(recordType: "Message", predicate: fromPredicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            } else {
                for record in results! {
                    let eachMessage = MessagePlainObject(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                    self.downloadedMessages.append(eachMessage)
                    print(eachMessage)
                }
                
                self.downloadedMessages.sortInPlace({ $0.date.compare($1.date) == .OrderedAscending })
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    return
                }
            }
        }
    }
    
    func updateChatBuddy(buddyID: String) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "ChatBuddy")
        request.predicate = NSPredicate(format: "userID == %@", buddyID)
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
            // labor of love error handling
        }
        
        if results != nil {
            let chatBuddies = results as! [ChatBuddy]!
            for chatBud in chatBuddies {
                chatBud.lastMessageDate = NSDate()
            }
        }
    }
    
    func fetchSelfFromCoreData() {
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
                    self.meIDGlobal = person.userID
                }
            }
        }
    
}


let modelSingletonGlobal = Model()