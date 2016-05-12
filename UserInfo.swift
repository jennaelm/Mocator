//
//  UserInfo.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

private let sharedUserInfo = UserInfo()

class UserInfo : NSObject {
    
    var container : CKContainer
    var userRecordID : CKRecordID!
    var contacts = [AnyObject]()
    
    var publicDB : CKDatabase!
    var me : CKDiscoveredUserInfo?
    var myRecord : CKRecord?
    var myRecordIDName : String?
    
    var firstNameCloud : String?
    var lastNameCloud : String?
    
    class var sharedInstance : UserInfo {
        return sharedUserInfo
    }
    
    override init () {
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
    }
    
    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        self.container.requestApplicationPermission(.UserDiscoverability, completionHandler: { (status, error) -> Void in
            self.container.fetchUserRecordIDWithCompletionHandler() {
                recordID, error in
                    if error != nil {
                        print(error!.localizedDescription)
                        complete(instance: nil, error: error)
                    } else {
                        complete(instance: recordID, error: nil)
                        self.container.discoverUserInfoWithUserRecordID(recordID!, completionHandler: { (info, error) -> Void in
                            self.me = info
                            if self.me != nil {
                                self.publicDB.fetchRecordWithID(recordID!, completionHandler: { (record, error) -> Void in
                                    self.myRecord = record
                                        self.publicDB.saveRecord(record!, completionHandler: { record, error in
                                        if let saveError = error {
                                            print("An error occurred while saving CloudKit Record \(saveError)")
                                        } else {
                                            // do nothing
                                        }
                                    })
                                })
                            }
                        })
            
                    }
                }
        })
    }
    
    
}