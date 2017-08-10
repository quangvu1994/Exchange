//
//  FIRStorageUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/9/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import FirebaseStorage

class FIRStorageUtilities {
    
    @available(iOS 10.0, *)
    static let dateFormatter = ISO8601DateFormatter()

    
    static func constructReferencePath() -> StorageReference {
        let userID = User.currentUser.uid
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"

        let timestamp = df.string(from: date)
        
        return Storage.storage().reference().child("images/posts/\(userID)/\(timestamp).jpg")
    }
}
