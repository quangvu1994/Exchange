//
//  UserService.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    /**
     Write a new user in the database
    */
    static func createNewUser(_ user: FIRUser, phoneNumber: String, username: String, completion: @escaping (User?) -> Void){
        //  Store username
        let data = [
            "username": username,
            "phoneNumber": phoneNumber
        ]
        // Generate a path in our FIRDatabase
        let userPath = Database.database().reference().child("users").child(user.uid)
        userPath.setValue(data, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure("Error occurred when writing new user to the database \(error.localizedDescription)")
                return
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let newUser = User(snapshot: snapshot)
                completion(newUser)
            })
        })
    }
    
    /**
     Retrieve user information from our database
    */
    static func retrieveUser(_ userID: String, completion: @escaping (User?) -> Void) {
        // Generate a path to our FIRDatabase
        let userPath = Database.database().reference().child("users").child(userID)
        userPath.observeSingleEvent(of: .value, with: { (snapshot) in
            let newUser = User(snapshot: snapshot)
            completion(newUser)
        })

    }
}
