//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Jenna Miller on 4/14/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var senderID: String?
    @NSManaged var date: NSDate?
    @NSManaged var text: String?
    @NSManaged var recipientID: String?

}
