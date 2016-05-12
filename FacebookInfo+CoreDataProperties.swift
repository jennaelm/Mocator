//
//  FacebookInfo+CoreDataProperties.swift
//  Mocator
//
//  Created by Jenna Miller on 4/5/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FacebookInfo {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var profileURL: String?
    @NSManaged var profilePhotos: NSData?
    @NSManaged var gender: String?
    @NSManaged var userID: String?
    @NSManaged var userDescription: String?
}

