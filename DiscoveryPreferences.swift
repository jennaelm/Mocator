//
//  DiscoveryPreferences.swift
//  Mocator
//
//  Created by Jenna Miller on 4/11/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import Foundation

class DiscoveryPreferences : NSObject, NSCoding {
    
    var maleBool : Bool?
    var femaleBool : Bool?
    var datesBool : Bool?
    var friendsBool : Bool?
    
    struct PropertyKey {
        static let maleKey = "malePreference"
        static let femaleKey = "femalePreference"
        static let datesKey = "datesPreference"
        static let friendsKey = "friendsPreference"
    }
    
// NSCoding 
    
    init(maleBool:Bool, femaleBool: Bool, datesBool:Bool, friendsBool:Bool) {
        self.maleBool = maleBool
        self.femaleBool = femaleBool
        self.datesBool = datesBool
        self.friendsBool = friendsBool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(maleBool!, forKey: PropertyKey.maleKey)
        aCoder.encodeBool(femaleBool!, forKey: PropertyKey.femaleKey)
        aCoder.encodeBool(datesBool!, forKey: PropertyKey.datesKey)
        aCoder.encodeBool(friendsBool!, forKey: PropertyKey.friendsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let maleBool = aDecoder.decodeBoolForKey(PropertyKey.maleKey)
        let femaleBool = aDecoder.decodeBoolForKey(PropertyKey.femaleKey)
        let datesBool = aDecoder.decodeBoolForKey(PropertyKey.datesKey)
        let friendsBool = aDecoder.decodeBoolForKey(PropertyKey.friendsKey)
        
        self.init(maleBool: maleBool, femaleBool: femaleBool, datesBool: datesBool, friendsBool: friendsBool)
        
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "discoveryPreferences")
    }
    
    class func loadSaved() -> DiscoveryPreferences? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("discoveryPreferences") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? DiscoveryPreferences
        }
        return nil
    }
    
    func returnArrayOfGenders() -> [String] {
        var arrayOfGenders = [String]()
        if self.maleBool == true {
            arrayOfGenders.append("male")
        }
        if self.femaleBool == true {
            arrayOfGenders.append("female")
        }
        
        return arrayOfGenders
    }
    
    func returnArrayOfTypes() -> [String] {
        var arrayOfTypes = [String]()
        
        if self.friendsBool == true {
            arrayOfTypes.append("friends")
        }
        if self.datesBool == true {
            arrayOfTypes.append("dates")
        }
        
        return arrayOfTypes
    }

}