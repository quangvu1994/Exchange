//
//  Request.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//
import FirebaseDatabase.FIRDataSnapshot

class Request {
    var requester: User
    var requesterItems: [Post]
    var posterItem: [Post]
    var message: String = ""
    var status: String = "In Progress"
    var dictValue: [String: Any] {
        var items1 = [String: Any]()
        var items2 = [String: Any]()
        let requesterData = [
            "requester_id": requester.uid,
            "requester_username": requester.username,
            "requester_phone": requester.phoneNumber
        ]
        
        for i in 0..<requesterItems.count {
            items1[requesterItems[i].key!] = requesterItems[i].dictValue
        }
        
        for i in 0..<posterItem.count {
            items2[posterItem[i].key!] = posterItem[i].dictValue
        }
        
        return [
            "requester": requesterData,
            "requester_items": items1,
            "poster_items": items2,
            "message": message,
            "status": status
        ]
    }
    
    init(requester: User, requesterItems: [Post], posterItem: [Post]) {
        self.requesterItems = requesterItems
        self.posterItem = posterItem
        self.requester = requester
    }
    

    init?(snapshot: DataSnapshot) {
        guard let basicInfoSnapshot = snapshot.value as? [String: Any],
            let message = basicInfoSnapshot["message"] as? String,
            let status = basicInfoSnapshot["status"] as? String,
            let requester = basicInfoSnapshot["requester"] as? [String: String],
            let requesterID = requester["requester_id"],
            let requesterName = requester["requester_username"],
            let requesterPhone = requester["requester_phone"] else {
            return nil
        }
        if let posterItemSnapshot = snapshot.childSnapshot(forPath: "poster_items").children.allObjects as? [DataSnapshot] {
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
        if let offeredItemSnapshot = snapshot.childSnapshot(forPath: "requester_items").children.allObjects as? [DataSnapshot] {
            
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
        self.requester = User(uid: requesterID, username: requesterName, phoneNumber: requesterPhone)
    }
}
