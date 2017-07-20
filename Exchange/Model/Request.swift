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
    var posterItem: [Post]
    var message: String = ""
    var status: String = "In Progress"
    var dictValue: [String: Any] {
        var items1 = [String: Any]()
        var items2 = [String: Any]()
        
        for i in 0..<requesterItems.count {
            items1[requesterItems[i].key!] = requesterItems[i].dictValue
        }
        
        for i in 0..<posterItem.count {
            items2[posterItem[i].key!] = posterItem[i].dictValue
        }
        
        return [
            "Requester Items": items1,
            "Poster Item": items2,
            "Message": message,
            "Status": status
        ]
    }
    
    init(requesterItems: [Post], posterItem: [Post]) {
        self.requesterItems = requesterItems
        self.posterItem = posterItem
    }
    

    init?(snapshot: DataSnapshot) {
        guard let basicInfoSnapshot = snapshot.value as? [String: Any],
            let message = basicInfoSnapshot["Message"] as? String,
            let status = basicInfoSnapshot["Status"] as? String else {
            return nil
        }
        if let posterItemSnapshot = snapshot.childSnapshot(forPath: "Poster Item").children.allObjects as? [DataSnapshot] {
            let posterItems: [Post] = posterItemSnapshot.reversed().flatMap {
                guard let item = Post(snapshot: $0) else {
                    return nil
                }
                
                return item
            }
            
            self.posterItem = posterItems
        } else {
            return nil
        }
        
        // offeredItemSnapshot can be empty - user can request without any item
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
        
        self.message = message
        self.status = status
    }
}
