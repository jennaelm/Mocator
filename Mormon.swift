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
    var about : String!
    var location : CLLocation!
    var coverPhotoData : CKAsset!
    var facebookLinkString : String!
    weak var database : CKDatabase!
    
    init(record : CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        
        self.name = record.objectForKey("Name") as! String
        self.location = record.objectForKey("Location") as! CLLocation
        self.about = record.objectForKey("About") as! String
        self.coverPhotoData = record.objectForKey("CoverPhoto") as! CKAsset
        self.facebookLinkString = record.objectForKey("FacebookLink") as! String
    }
    
    func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)){
                    var image: UIImage!
                    // 2
                    if let asset = self.record.objectForKey("CoverPhoto") as? CKAsset {
                        // 3
                        if let url = asset.fileURL as NSURL? {
                            let imageData = NSData(contentsOfFile: url.path!)!
                            // 4
                            image = UIImage(data: imageData)
                        }
                    }
                    // 5
                    completion(photo: image)
        }
    }

}