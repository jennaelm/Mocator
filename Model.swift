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

let PersonType = "Person"

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
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
        
            self.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicateArray)
            let query = CKQuery(recordType: PersonType,
                predicate: self.predicate!)
            
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
    
    func pushPersonToCloudKit(userID: String, firstName: String, lastName: String, picString: String, profileLink: String, gender: String, lookingFor: [String], location: CLLocation) {
        let mormonRecordID = CKRecordID(recordName: firstName + lastName + userID)
        let url = NSURL(string: picString)! as NSURL
        let imageData = NSData(contentsOfURL: url)
        let image = UIImage(data: imageData!)
        
        var assetArray = [CKAsset]()
        let asset = imageToAsset(image!)
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
 
            self.userGenderGlobal = gender
            self.meIDGlobal = userID
        
        self.publicDB.saveRecord(mormonRecord, completionHandler: { (record, error) in
            if error != nil {
                print("error: \(error?.localizedDescription)")
                // labor of love error handling
            } else {
                print("Person saved successfully")
            }
        })
    }
    
    func updatePersonInCloudKit(description: String?, photos: [CKAsset]) {
        print("me id: \(self.meIDGlobal!)")
        
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
                print("found record")
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
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0] as String
        let myFilePath = documentDirectory.stringByAppendingString(".jpg")
        imageData!.writeToFile(myFilePath, atomically: true)
        let url = NSURL(fileURLWithPath: myFilePath)
        let asset = CKAsset(fileURL: url)
        
        return asset
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
    
    func downloadMessagesFromCloudKit(recipientID: String, senderID: String) {
                    
                    let senderPredicate2 = NSPredicate(format: "RecipientID == %@", senderID)
                    let recipientPredicate2 = NSPredicate(format: "SenderID == %@", recipientID)
                    let predicateTwo = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [senderPredicate2, recipientPredicate2])
                    let queryTwo = CKQuery(recordType: "Message", predicate: predicateTwo)
                    self.publicDB.performQuery(queryTwo, inZoneWithID: nil) { rezults, error in
                        if error != nil {
                            print("error fetching messages in Model")
                        } else {
                            for record in rezults! {
                                let eachMessage = MessagePlainObject(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                                self.downloadedMessages.append(eachMessage)
                                print(eachMessage)
                            }
                        }
        }
        
        let senderPredicate = NSPredicate(format: "SenderID == %@", senderID)
        let recipientPredicate = NSPredicate(format: "RecipientID == %@", recipientID)
        let predicateOne = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [senderPredicate, recipientPredicate])
        let query = CKQuery(recordType: "Message", predicate: predicateOne)
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    return
                }
            }
        }
    }

    func storeMessage(recipientID: String, senderID: String, text: String, date: NSDate) {
        // store message in CoreData (Do I want to do this?)
    }

}


let modelSingletonGlobal = Model()