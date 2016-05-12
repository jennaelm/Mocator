//
//  ChatBuddy+CoreDataProperties.swift
//  
//
//  Created by Jenna Miller on 4/19/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ChatBuddy {

    @NSManaged var userID: String?
    @NSManaged var imageString: String?
    @NSManaged var name: String?
    @NSManaged var lastMessageDate: NSDate?

}
