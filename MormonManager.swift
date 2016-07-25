//
//  MormonManager.swift
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

@objc protocol MormonManagerDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class MormonManager {
    
    var delegate : MormonManagerDelegate?
    var items = [Mormon]()
    
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    
    var predicate : NSPredicate?
    var cursor : CKQueryCursor?

    var specificMormon : Mormon?
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func fetchPersons(location:CLLocation, genders:[String], lookingFor:[String]) {
        self.items = []
        
        var predicateArray = [NSPredicate]()
        
        if genders.count < 2 {
            let genderPredicate = NSPredicate(format: "Gender == %@", genders[0])
            predicateArray.append(genderPredicate)
        }
            
        if lookingFor.count < 2 {
            let typePredicate = NSPredicate(format: "LookingFor CONTAINS %@", lookingFor[0])
            predicateArray.append(typePredicate)
        }
        
        if let id = NSUserDefaults.standardUserDefaults().stringForKey("id") {
                let selfPredicate = NSPredicate(format: "NOT (UserID == %@)", id)
                predicateArray.append(selfPredicate)
        }
    
        self.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicateArray)
        let query = CKQuery(recordType: PersonType,
            predicate: self.predicate!)
            query.sortDescriptors = [CKLocationSortDescriptor(key: "Location", relativeLocation: location)]
        
        let operation = CKQueryOperation(query: query)
            operation.resultsLimit = 15
        self.publicDB.addOperation(operation)
        
        operation.recordFetchedBlock = { (record) in
            let mormon = Mormon(record: record, database: self.publicDB, serverID: record.recordID.recordName)
            self.items.append(mormon)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            self.cursor = cursor
                
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    self.updateLocationInCloudKit(location)
                    return
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            }
        }
    }
    
    func fetchSpecificPerson(userID: String) {
        let userIDPredicate = NSPredicate(format: "UserID == %@", userID)
        let specificQuery = CKQuery(recordType: PersonType,
                            predicate: userIDPredicate)
        self.publicDB.performQuery(specificQuery, inZoneWithID: nil, completionHandler: {
            results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    return
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    for specificRecord in results! {
                        print("fetched record: \(specificRecord)")
                        let fetchedMormon = Mormon(record: specificRecord, database: self.publicDB, serverID: specificRecord.recordID.recordName)
                        self.specificMormon = fetchedMormon
                            self.delegate?.modelUpdated()
                            return
                    }
                }
            }
        })
    }
    
    func continueScrolling() {
        print("continue scrolling called")
        if self.cursor == nil {
            print("no more results in area?")
        } else {
            let queryOperation = CKQueryOperation(cursor: self.cursor!)
                queryOperation.resultsLimit = 9
            
            self.publicDB.addOperation(queryOperation)
            
            queryOperation.recordFetchedBlock = { (record) in
                let mormon = Mormon(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                self.items.append(mormon)
            }
            
            queryOperation.queryCompletionBlock = { (cursor, error) in
                
                self.cursor = cursor
                
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.modelUpdated()
                        return
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.errorUpdating(error!)
                        return
                    }
                }
            }
        }
    }
    
    func pushPersonToCloudKit(userID: String, firstName: String, lastName: String, picString: String, fbID: String, profileLink: String, gender: String, lookingFor: [String], location: CLLocation, friendList: [String]) {

        let mormonRecordID = CKRecordID(recordName: firstName + lastName + userID)
        let url = NSURL(string: picString)! as NSURL
        let imageData = NSData(contentsOfURL: url)
        let nsUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString+".dat")
        
        do {
            try imageData!.writeToURL(nsUrl, options: [])
        } catch let error as NSError {
            print("Error! \(error.localizedDescription)")
            return
        }
        
        let asset = CKAsset(fileURL: nsUrl)
        var assetArray = [CKAsset]()
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
            mormonRecord["FriendList"] = friendList
        
        self.publicDB.saveRecord(mormonRecord, completionHandler: { (record, error) in
            if error != nil {
                print("error: \(error?.localizedDescription)")
                // labor of love error handling
            } else {
               print("person successfully pushed to CloudKit!")
            }
        })
    }
    
    func updateLocationInCloudKit(location: CLLocation) {
        if let id = NSUserDefaults.standardUserDefaults().stringForKey("id") {
        let mePredicate = NSPredicate(format: "UserID == %@", id)
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
                        }
                    })
                }
            }
        }
        }
    }
    
    func updatePersonInCloudKit(description: String?, photos: [CKAsset]) {
        let messageHandler = MessageHandler()
        messageHandler.subscribeToMessages()
        let id = NSUserDefaults.standardUserDefaults().stringForKey("id")
        let mePredicate = NSPredicate(format: "UserID == %@", id!)
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
        } catch let error as NSError {
            print("Error! \(error)")
        }
        
        let asset = CKAsset(fileURL: nsUrl)
        return asset
    }

}