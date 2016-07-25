//
//  MessageHandler.swift
//  Mocator
//
//  Created by Jenna Miller on 6/28/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//


import Foundation
import CloudKit
import CoreData

protocol MessageHandlerDelegate {
    func newMessageReceived()
    func messagesDownloaded()
}

class MessageHandler {
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    var downloadedMessages = [MessagePlainObject]()
    var newMessageBuddies = [ChatBuddy]()
    var delegate : MessageHandlerDelegate?
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func subscribeToMessages() {
        let id = NSUserDefaults.standardUserDefaults().stringForKey("id")
        let predicate = NSPredicate(format:"RecipientID = %@", id!)
        let subscription = CKSubscription(recordType: "Message", predicate: predicate, options: .FiresOnRecordCreation)
        
        let notification = CKNotificationInfo()
        notification.alertBody = "New Message"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        subscription.notificationInfo = notification
        
        self.publicDB.saveSubscription(subscription) { (result, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print ("successfully saved subscription")
            }
        }
    }
    
    func downloadSentMessagesFromCloudKit(recipientID: String, senderID: String, completionClosure: (success:Bool) ->()) {
        let senderPredicate = NSPredicate(format: "RecipientID == %@", senderID)
        let recipientPredicate = NSPredicate(format: "SenderID == %@", recipientID)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [senderPredicate, recipientPredicate])
        let query = CKQuery(recordType: "Message", predicate: predicate)
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            } else {
                for record in results! {
                    let eachMessage = MessagePlainObject(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                    self.downloadedMessages.append(eachMessage)
                }
                let flag = true
                completionClosure(success: flag)
            }
        }
    }
    
    func downloadReceivedMessagesFromCloudKit(recipientID: String, senderID: String, completionClosure: (success:Bool) ->()) {
        let senderPredicate = NSPredicate(format: "SenderID == %@", senderID)
        let recipientPredicate = NSPredicate(format: "RecipientID == %@", recipientID)
        let predicateOne = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [senderPredicate, recipientPredicate])
        let query = CKQuery(recordType: "Message", predicate: predicateOne)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            } else {
                for record in results! {
                    let eachMessage = MessagePlainObject(record: record, database: self.publicDB, serverID: record.recordID.recordName)
                    self.downloadedMessages.append(eachMessage)
                }
                let flag = true
                completionClosure(success: flag)
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
            } else {
                print("message sent successfully")
            }
        })
    }
    
    func handleChatBuddies(userID: String) {
        let fetchRequest = NSFetchRequest(entityName: "ChatBuddy")
            fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        var error: NSError? = nil
        let count = context.countForFetchRequest(fetchRequest, error: &error)
        
        if count > 0 {
            var results : [AnyObject]?
            
            do {
                results = try context.executeFetchRequest(fetchRequest)
            } catch let error as NSError {
                print("Error saving context: \(error.localizedDescription)")
            }
            
            if results != nil {
                let newBuddies = results as? [ChatBuddy]
                for eachBuddy in newBuddies! {
                    self.newMessageBuddies.append(eachBuddy)
                    eachBuddy.lastMessageDate = NSDate()
                }
            }
        } else {
            let userIDPredicate = NSPredicate(format: "UserID == %@", userID)
            let specificQuery = CKQuery(recordType: PersonType,
                                        predicate: userIDPredicate)
            self.publicDB.performQuery(specificQuery, inZoneWithID: nil, completionHandler: {
            results, error in
                if error != nil {
                print("error querying for user")
                } else {
                    for specificRecord in results! {
                            let fetchedMormon = Mormon(record: specificRecord, database: self.publicDB, serverID: specificRecord.recordID.recordName)
                            let newMormon = NSEntityDescription.insertNewObjectForEntityForName("ChatBuddy", inManagedObjectContext: self.context) as! ChatBuddy
                            newMormon.name = fetchedMormon.name
                            newMormon.lastMessageDate = NSDate()
                            newMormon.userID = fetchedMormon.mormonUserID
                            let CDataArray = NSMutableArray()
                        
                            fetchedMormon.loadPhotos { images in
                                let profileImage = images[0]
                                let imageData : NSData = UIImagePNGRepresentation(profileImage)!
                                CDataArray.addObject(imageData)
                            }
                        
                            let coreDataObject = NSKeyedArchiver.archivedDataWithRootObject(CDataArray)
                            newMormon.profilePhotos = coreDataObject
                        
                            self.newMessageBuddies.append(newMormon)
                        }
                    
                        do {
                            try self.context.save()
                        } catch {
                            print("error saving context")
                        }
                    }
                })
            }
    }
    
    func handleNewMessage(senderID: String, recipientID: String) {
        self.handleChatBuddies(senderID)
        self.delegate?.newMessageReceived()
    }
    
    func receivedNewMessages() {
        self.delegate?.newMessageReceived()
    }
    
    func updateChatBuddyLastMessage(buddyID: String) {
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
}