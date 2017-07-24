//
//  Request.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//
import FirebaseDatabase.FIRDataSnapshot

class Request {
    let requester: User
    let poster: User
    var requesterItemsRefList: [String]
    var posterItemsRefList: [String]
    var message: String = ""
    var status: String = "In Progress"
    
    var dictValue: [String: Any] {
        var items1 = [String: Bool]()
        var items2 = [String: Bool]()
        let requesterData = [
            "requester_id": requester.uid,
            "requester_username": requester.username,
            "requester_phone": requester.phoneNumber
        ]
        
        let posterData = [
            "poster_id": poster.uid,
            "poster_username": poster.username,
            "poster_phone": poster.phoneNumber
        ]
        
        for i in 0..<requesterItemsRefList.count {
            items1[requesterItemsRefList[i]] = true
        }
        
        for i in 0..<posterItemsRefList.count {
            items2[posterItemsRefList[i]] = true
        }
        
        return [
            "requester": requesterData,
            "poster": posterData,
            "requester_items": items1,
            "poster_items": items2,
            "message": message,
            "status": status
        ]
    }
    
    init(requester: User, poster: User, requesterItemsRefList: [String], posterItemsRefList: [String]) {
        self.requesterItemsRefList = requesterItemsRefList
        self.posterItemsRefList = posterItemsRefList
        self.requester = requester
        self.poster = poster
    }
    

    init?(snapshot: DataSnapshot) {
        guard let basicInfoSnapshot = snapshot.value as? [String: Any],
            let message = basicInfoSnapshot["message"] as? String,
            let status = basicInfoSnapshot["status"] as? String,
            let requester = basicInfoSnapshot["requester"] as? [String: String],
            let poster = basicInfoSnapshot["poster"] as? [String: String],
            let requesterID = requester["requester_id"],
            let requesterName = requester["requester_username"],
            let requesterPhone = requester["requester_phone"],
            let posterID = poster["poster_id"],
            let posterName = poster["poster_username"],
            let posterPhone = poster["poster_phone"] else {
            return nil
        }
        
        self.posterItemsRefList = []
        if let posterItemsRefList = snapshot.childSnapshot(forPath: "poster_items").value as? [String: Bool] {
            for ref in posterItemsRefList.keys {
                self.posterItemsRefList.append(ref)
            }
        } else {
            return nil
        }
        
        self.requesterItemsRefList = []
        if let requesterItemsRefList = snapshot.childSnapshot(forPath: "requester_items").value as? [String: Bool] {
            for ref in requesterItemsRefList.keys {
                self.requesterItemsRefList.append(ref)
            }
        }
        
        self.message = message
        self.status = status
        self.requester = User(uid: requesterID, username: requesterName, phoneNumber: requesterPhone)
    }
}
