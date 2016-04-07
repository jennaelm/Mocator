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
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func refresh() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Person", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    print("error loading: \(error)")
                }
            } else {
                self.items.removeAll(keepCapacity: true)
                for record in results! {
                    let mormon = Mormon(record: record, database:self.publicDB)
                    self.items.append(mormon)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    print("")
                }
            }
        }
    }
    
    func fetchPersons(location:CLLocation,
        radiusInMeters:CLLocationDistance) {
            
            let radiusInKilometers = radiusInMeters / 1000.0
            
            let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
                "Location",
                location,
                radiusInKilometers)
            
            let query = CKQuery(recordType: PersonType,
                predicate:  locationPredicate)
            
            publicDB.performQuery(query, inZoneWithID: nil) {
                results, error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.errorUpdating(error!)
                        return
                    }
                } else {
                    self.items.removeAll(keepCapacity: true)
                    for record in results! {
                        let mormon = Mormon(record: record, database: self.publicDB)
                        self.items.append(mormon)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.modelUpdated()
                        return
                    }
                }
            }
    }
    
    
}



let modelSingletonGlobal = Model()