//
//  Request.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

class Request {
    var arrayOfYoursItems: [Post]
    var theirItem: Post
    var message: String = ""
    var dictValue: [String: Any] {
        var myItemsValue = [String: Any]()
        
        for i in 0..<arrayOfYoursItems.count {
            myItemsValue[arrayOfYoursItems[i].key!] = arrayOfYoursItems[i].dictValue
        }
        
        return [
            "myItems": myItemsValue,
            "theirItems": theirItem.dictValue,
            "message": message
        ]
    }
    
    init(arrayOfYoursItems: [Post], theirItem: Post) {
        self.arrayOfYoursItems = arrayOfYoursItems
        self.theirItem = theirItem
    }
}
