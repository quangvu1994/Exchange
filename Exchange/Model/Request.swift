//
//  Request.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//
import FirebaseDatabase.FIRDataSnapshot

class Request {
    var requesterItems: [Post]
    var posterItem: Post
    var message: String = ""
    var status: Bool = false
    var dictValue: [String: Any] {
        var items = [String: Any]()
        
        for i in 0..<requesterItems.count {
            items[requesterItems[i].key!] = requesterItems[i].dictValue
        }
        
        return [
            "Requester Items": items,
            "Poster Item": posterItem.dictValue,
            "Message": message,
            "Status": status
        ]
    }
    
    init(requesterItems: [Post], posterItem: Post) {
        self.requesterItems = requesterItems
        self.posterItem = posterItem
    }
    

    init?(snapshot: DataSnapshot) {
        guard let basicInfoSnapshot = snapshot.value as? [String: Any],
            let message = basicInfoSnapshot["Message"] as? String,
            let status = basicInfoSnapshot["Status"] as? Bool else {
            return nil
        }
        let posterItemSnapshot = snapshot.childSnapshot(forPath: "Poster Item")
        // offeredItemSnapshot can be nil - user can request without any item
        if let offeredItemSnapshot = snapshot.childSnapshot(forPath: "Requester Items").children.allObjects as? [DataSnapshot] {
            
            let offeredItems: [Post] = offeredItemSnapshot.reversed().flatMap {
                guard let item = Post(snapshot: $0) else {
                    return nil
                }
                
                return item
            }
            
            self.requesterItems = offeredItems
        } else {
            self.requesterItems =  []
        }
        guard let item = Post(snapshot: posterItemSnapshot) else {
            return nil
        }
        self.posterItem = item
        self.message = message
        self.status = status
    }
}
