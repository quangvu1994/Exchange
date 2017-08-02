//
//  User.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
    // MARK: - Properties
    var uid: String
    var username: String
    var phoneNumber: String
    var storeDescription: String = "Welcome to my store!"
    
    // Singleton User
    private static var _current: User?
    
    init(uid: String, username: String, phoneNumber: String){
        self.uid = uid
        self.username = username
        self.phoneNumber = phoneNumber
    }
    
    init?(snapshot: DataSnapshot){
        guard let snapshotValue = snapshot.value as? [String: Any],
            let username = snapshotValue["username"] as? String,
            let phoneNumber = snapshotValue["phoneNumber"] as? String,
            let storeDescription = snapshotValue["storeDescription"] as? String,
                !username.isEmpty,
                !phoneNumber.isEmpty else {
            return nil
        }
        
        self.uid = snapshot.key
        self.username = username
        self.phoneNumber = phoneNumber
        self.storeDescription = storeDescription
    }
        
    static func setCurrentUser(_ user: User){
        _current = user
    }
    
    static var currentUser: User {
        guard let currentUser = _current else {
            fatalError("There is no current user found")
        }
        return currentUser
    }
}
