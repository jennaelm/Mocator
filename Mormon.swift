//
//  Person.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation
import CloudKit

class Mormon : NSObject {
    
    var record : CKRecord!
    var name : String!
    var location : CLLocation!
    var profilePhotos : [CKAsset]!
    var facebookLinkString : String!
    var mormonUserID : String!
    var about : String?
    var fbID : String!
    weak var database : CKDatabase!
    var friends : [String]?
    
    var serverID : String
    
    init(record : CKRecord, database: CKDatabase, serverID: String) {
        self.record = record
        self.database = database
        self.serverID = serverID
        
        self.name = record.objectForKey("Name") as! String
        self.location = record.objectForKey("Location") as! CLLocation
        self.profilePhotos = record.objectForKey("Photos") as! [CKAsset]
        self.facebookLinkString = record.objectForKey("FacebookLink") as! String
        self.mormonUserID = record.objectForKey("UserID") as! String
        self.about = record.objectForKey("About") as! String?
        self.fbID = record.objectForKey("FbID") as! String
        self.friends = record.objectForKey("FriendList") as! [String]?
    }
    
    func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)){
                    var image: UIImage!
                    let coverAsset = self.profilePhotos[0]
                    let imageData = NSData(contentsOfURL: coverAsset.fileURL)
                    image = UIImage(data: imageData!)
                    completion(photo: image)
        }
    }
    
    func loadPhotos(completion:(photos: [UIImage]!) -> ()) {
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)){
                    var images = [UIImage]()
                    let coverAssets = self.profilePhotos
                    for asset in coverAssets {
                       let imageData = NSData(contentsOfURL: asset.fileURL)
                        if let image = UIImage(data: imageData!) {
                        images.append(image)
                        }
                    }
                    
                    
                    completion(photos: images)
        }
    }
    
    func mormonDescription() -> String {
        return self.name + "ID" + self.serverID
    }

}