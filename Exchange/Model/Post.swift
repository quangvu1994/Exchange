//
//  Post.swift
//  Exchange
//
//  Created by Quang Vu on 7/8/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

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
    
}
