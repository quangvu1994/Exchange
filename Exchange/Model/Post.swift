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
    var index: Int?
    var imageURL: String
    var imageHeight: CGFloat
    var key: String?
    var creationDate: Date
    var postTitle: String
    var postDescription: String
    var postCategory: String
    var tradeLocation: String
    var availability: Bool = true
    var requestedBy = [String: Bool]()
    let poster: User
    var selected: Bool = false
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username,
                        "phoneNumber": poster.phoneNumber]
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "post_title": postTitle,
                "post_description": postDescription,
                "post_category": postCategory,
                "trade_location": tradeLocation,
                "availability": availability,
                "created_at" : createdAgo,
                "poster" : userDict,
                "requested_by": requestedBy
        ]
    }
    
    init(imageURL: String, imageHeight: CGFloat){
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.poster = User.currentUser
        self.creationDate = Date()
        self.postDescription = ""
        self.postTitle = ""
        self.postCategory = "Others"
        self.tradeLocation = ""
    }
    
    init?(snapshot: DataSnapshot) {
        guard let postData = snapshot.value as? [String: Any],
            let imageURL = postData["image_url"] as? String,
            let imageHeight = postData["image_height"] as? CGFloat,
            let postTitle = postData["post_title"] as? String,
            let postDescription = postData["post_description"] as? String,
            let postCategory = postData["post_category"] as? String,
            let tradeLocation = postData["trade_location"] as? String,
            let availability = postData["availability"] as? Bool,
            let poster = postData["poster"] as? [String: Any],
            let creationDate = postData["created_at"] as? TimeInterval,
            let uid = poster["uid"] as? String,
            let username = poster["username"] as? String,
            let phoneNumber = poster["phoneNumber"] as? String
            else {return nil}
        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.postTitle = postTitle
        self.postDescription = postDescription
        self.tradeLocation = tradeLocation
        self.postCategory = postCategory
        self.availability = availability
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        self.poster = User(uid: uid, username: username, phoneNumber: phoneNumber)
    }
    
}
