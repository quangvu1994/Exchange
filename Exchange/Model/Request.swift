//
//  Request.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//
import FirebaseDatabase.FIRDataSnapshot

class Request {
    var requestKey: String?
    var participantNum = 2
    var requesterID: String
    var requesterName: String
    var requesterPhone: String
    var requesterOneSignalID: String
    var posterID: String
    var posterName: String
    var posterPhone: String
    var posterOneSignalID: String
    var firstPostTitle: String
    var firstPostImageURL: String
    var requesterItemsData = [String: Any]()
    var posterItemsData = [String: Any]()
    var message: String = ""
    var tradeLocation: String
    var status = "In Progress"
    var cashAmount: String = ""
    
    var dictValue: [String: Any] {
        
        return [
            "participant_num": participantNum,
            "requester_id": requesterID,
            "requester_name": requesterName,
            "requester_phone": requesterPhone,
            "requester_osid": requesterOneSignalID,
            "poster_id": posterID,
            "poster_name": posterName,
            "poster_phone": posterPhone,
            "poster_osid": posterOneSignalID,
            "requester_items": requesterItemsData,
            "poster_items": posterItemsData,
            "first_posterItem": firstPostTitle,
            "first_posterItem_imageURL": firstPostImageURL,
            "trade_location": tradeLocation,
            "message": message,
            "cash_amount": cashAmount,
            "status": status
        ]
    }
    
    init(requesterItems: [Post], posterItems: [Post]) {
        self.requesterID = User.currentUser.uid
        self.requesterName = User.currentUser.username
        self.requesterPhone = User.currentUser.phoneNumber
        self.requesterOneSignalID = User.currentUser.oneSignalID
        self.posterID = posterItems[0].poster.uid
        self.posterName = posterItems[0].poster.username
        self.posterPhone = posterItems[0].poster.phoneNumber
        self.posterOneSignalID = posterItems[0].poster.oneSignalID
        self.firstPostTitle = posterItems[0].postTitle
        self.firstPostImageURL = posterItems[0].imagesURL[0]
        self.tradeLocation = posterItems[0].tradeLocation
        
        for i in 0..<requesterItems.count {
            let itemData: [String: Any] = [
                "image_url": requesterItems[i].imagesURL[0],
                "post_title": requesterItems[i].postTitle,
                "post_description": requesterItems[i].postDescription
            ]
            self.requesterItemsData[requesterItems[i].key!] = itemData
        }
        
        for i in 0..<posterItems.count {
            let itemData: [String: Any] = [
                "image_url": posterItems[i].imagesURL[0],
                "post_title": posterItems[i].postTitle,
                "post_description": posterItems[i].postDescription
            ]
            
            self.posterItemsData[posterItems[i].key!] = itemData
        }
    }

    init?(snapshot: DataSnapshot) {
        guard let basicInfoSnapshot = snapshot.value as? [String: Any],
            let imageURL = basicInfoSnapshot["first_posterItem_imageURL"] as? String,
            let message = basicInfoSnapshot["message"] as? String,
            let firstPostTitle = basicInfoSnapshot["first_posterItem"] as? String,
            let status = basicInfoSnapshot["status"] as? String,
            let cashAmount = basicInfoSnapshot["cash_amount"] as? String,
            let participantNum = basicInfoSnapshot["participant_num"] as? Int,
            let requesterID = basicInfoSnapshot["requester_id"] as? String,
            let requesterName = basicInfoSnapshot["requester_name"] as? String,
            let requesterPhone = basicInfoSnapshot["requester_phone"] as? String,
            let requesterOneSignalID = basicInfoSnapshot["requester_osid"] as? String,
            let posterID = basicInfoSnapshot["poster_id"] as? String,
            let posterName = basicInfoSnapshot["poster_name"] as? String,
            let posterPhone = basicInfoSnapshot["poster_phone"] as? String,
            let posterOneSignalID = basicInfoSnapshot["poster_osid"] as? String,
            let tradeLocation = basicInfoSnapshot["trade_location"] as? String else {
            return nil
        }
        
        if let data = snapshot.childSnapshot(forPath: "poster_items").value as? [String: Any] {
            self.posterItemsData = data
        } else {
            return nil
        }
        
        if let data = snapshot.childSnapshot(forPath: "requester_items").value as? [String: Any] {
            self.requesterItemsData = data
        }
        
        self.participantNum = participantNum
        self.requesterID = requesterID
        self.requesterName = requesterName
        self.requesterPhone = requesterPhone
        self.requesterOneSignalID = requesterOneSignalID
        self.posterID = posterID
        self.posterName = posterName
        self.posterPhone = posterPhone
        self.posterOneSignalID = posterOneSignalID
        self.requestKey = snapshot.key
        self.firstPostImageURL = imageURL
        self.firstPostTitle = firstPostTitle
        self.message = message
        self.status = status
        self.cashAmount = cashAmount
        self.tradeLocation = tradeLocation
    }
    
}
