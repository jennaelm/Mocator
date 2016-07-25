//
//  MessagePlainObject.swift
//  Mocator
//
//  Created by Jenna Miller on 4/7/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation
import CloudKit

class MessagePlainObject : NSObject {
    var value : String
    var recipientID : String
    var senderID : String
    var date : NSDate
    
    var record : CKRecord
    var database : CKDatabase
    var serverID : String
    var delegate : MessageHandlerDelegate?
        
    init(record : CKRecord, database: CKDatabase, serverID: String) {
        self.record = record
        self.database = database
        self.serverID = serverID
            
        self.value = record.objectForKey("Text") as! String
        self.recipientID = record.objectForKey("RecipientID") as! String
        self.senderID = record.objectForKey("SenderID") as! String
        self.date = record.objectForKey("Date") as! NSDate
    }
    
    func messageDescription() -> String {
        return value + " FROM: " + recipientID + " DATE: " + date.description
    }
    
}
