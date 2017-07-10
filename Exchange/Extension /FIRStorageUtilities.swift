//
//  FIRStorageUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/9/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import FirebaseStorage

class FIRStorageUtilities {
    
    static let dateFormatter = ISO8601DateFormatter()

    
    static func constructReferencePath() -> StorageReference {
        let userID = User.currentUser.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(userID)/\(timestamp).jpg")
    }
}
