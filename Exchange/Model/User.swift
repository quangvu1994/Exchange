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
    
    // Singleton User
    private static var _current: User?
    
    init(uid: String, username: String){
        self.uid = uid
        self.username = username
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
