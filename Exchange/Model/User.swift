//
//  User.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    // MARK: - Properties
    var uid: String
    var username: String
    var phoneNumber: String
    var oneSignalID: String = ""
    var profilePictureURL: String?
    var storeDescription: String = "Welcome to my store!"
    
    // Singleton User
    private static var _current: User?
    
    init(uid: String, username: String, phoneNumber: String){
        self.uid = uid
        self.username = username
        self.phoneNumber = phoneNumber
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decode to grab our user info
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String,
            let phoneNumber = aDecoder.decodeObject(forKey: Constants.UserDefaults.phoneNumber) as? String,
            let storeDescription = aDecoder.decodeObject(forKey: Constants.UserDefaults.storeDescription) as? String,
            let oneSignalID = aDecoder.decodeObject(forKey: Constants.UserDefaults.oneSignalID) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        self.phoneNumber = phoneNumber
        self.storeDescription = storeDescription
        self.profilePictureURL = aDecoder.decodeObject(forKey: Constants.UserDefaults.profilePicture) as? String
        self.oneSignalID = oneSignalID
        super.init()
    }
    
    init?(snapshot: DataSnapshot){
        guard let snapshotValue = snapshot.value as? [String: Any],
            let username = snapshotValue["username"] as? String,
            let phoneNumber = snapshotValue["phoneNumber"] as? String,
            let oneSignalID = snapshotValue["oneSignalID"] as? String,
            let storeDescription = snapshotValue["storeDescription"] as? String,
                !username.isEmpty,
                !phoneNumber.isEmpty else {
            return nil
        }
        
        self.uid = snapshot.key
        self.username = username
        self.phoneNumber = phoneNumber
        self.storeDescription = storeDescription
        self.oneSignalID = oneSignalID
        self.profilePictureURL = snapshotValue["profilePicture"] as? String
        super.init()
    }
        
    class func setCurrentUser(_ user: User, writeToUserDefaults: Bool = false) {
        // Write user to user default
        if writeToUserDefaults {
            // Turn user object into data
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            // Store the data
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        
        _current = user
    }
    
    static var currentUser: User {
        guard let currentUser = _current else {
            fatalError("There is no current user found")
        }
        return currentUser
    }
}

extension User: NSCoding {
    // Encode our user information in User Default
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
        aCoder.encode(phoneNumber, forKey: Constants.UserDefaults.phoneNumber)
        aCoder.encode(storeDescription, forKey: Constants.UserDefaults.storeDescription)
        aCoder.encode(profilePictureURL, forKey: Constants.UserDefaults.profilePicture)
        aCoder.encode(oneSignalID, forKey: Constants.UserDefaults.oneSignalID)
    }
}
