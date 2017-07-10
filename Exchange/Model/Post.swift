//
//  Post.swift
//  Exchange
//
//  Created by Quang Vu on 7/8/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    var imageURL: String
    var imageHeight: CGFloat
    var key: String?
    var creationDate: Date
    let poster: User
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username]
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo,
                "poster" : userDict]
    }
    
    init(imageURL: String, imageHeight: CGFloat){
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.poster = User.currentUser
        self.creationDate = Date()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let postData = snapshot.value as? [String: Any],
            let imageURL = postData["image_url"] as? String,
            let imageHeight = postData["image_height"] as? CGFloat,
            let poster = postData["poster"] as? [String: Any],
            let creationDate = postData["created_at"] as? TimeInterval,
            let uid = poster["uid"] as? String,
            let username = poster["username"] as? String
            else {return nil}
        
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        self.poster = User(uid: uid, username: username)
    }
    
}