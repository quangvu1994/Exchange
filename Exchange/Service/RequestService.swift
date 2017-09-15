//
//  RequestService.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import FirebaseDatabase
import OneSignal

class RequestService {
    
    /**
     Write a new request to our database
    */
    static func writeNewRequest(for requesterID: String, and posterID: String, with request: Request, completionHandler: @escaping (Bool) -> Void) {
    
        let allRequestRef = Database.database().reference().child("Requests").childByAutoId()
        // Update child value -> don't want to wipe every others info
        allRequestRef.setValue(request.dictValue, withCompletionBlock: { (error, snapshot) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completionHandler(false)
            }
            
            var data: [String: Any] = [
                "users/\(requesterID)/Outgoing Request/\(snapshot.key)": true,
                "users/\(posterID)/Incoming Request/\(snapshot.key)": true
            ]

            for postRef in request.posterItemsData.keys {
                data["allItems/\(postRef)/requested_by/\(requesterID)"] = true
            }
            
            for reqRef in request.requesterItemsData.keys {
                data["allItems/\(reqRef)/requested_by/\(requesterID)"] = true
            }
                        
            Database.database().reference().updateChildValues(data, withCompletionBlock: { (error, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completionHandler(false)
                }
            })
            
            completionHandler(true)
        })
    }
    
    /**
     Retrievei all incoming request for our current user
    */
    static func retrieveIncomingRequest(completionHandler: @escaping ([Request]) -> Void) {
        let outgoingRef = Database.database().reference().child("users/\(User.currentUser.uid)/Incoming Request")
        outgoingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.value as? [String: Bool] else {
                return completionHandler([])
            }
            // Obtains all request references
            let requestRefList: [String] = snapshot.reversed().flatMap {
                return $0.key
            }
            
            let dispatchGroup = DispatchGroup()
            var requestList = [Request]()

            for requestRef in requestRefList {
                dispatchGroup.enter()
                Database.database().reference().child("Requests/\(requestRef)").observeSingleEvent(of: .value, with: { snapshot in
                    guard let request = Request(snapshot: snapshot) else {
                        dispatchGroup.leave()
                        return
                    }
                    requestList.append(request)
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: .main, execute: {
                completionHandler(requestList)
            })
        })
    }
    
    
    /**
     Retrieve all outgoing request for our current user
    */
    static func retrieveOutgoingRequest(completionHandler: @escaping ([Request]) -> Void) {
        let outgoingRef = Database.database().reference().child("users/\(User.currentUser.uid)/Outgoing Request")
        outgoingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.value as? [String: Bool] else {
                return completionHandler([])
            }
            let requestRefList: [String] = snapshot.reversed().flatMap {
                return $0.key
            }
            
            let dispatchGroup = DispatchGroup()
            var requestList = [Request]()
            
            for requestRef in requestRefList {
                dispatchGroup.enter()
                Database.database().reference().child("Requests/\(requestRef)").observeSingleEvent(of: .value, with: { snapshot in
                    guard let request = Request(snapshot: snapshot) else {
                        dispatchGroup.leave()
                        return
                    }
                    requestList.append(request)
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completionHandler(requestList)
            })
        })
    }
    
    /**
     Delete the request reference that belongs to an user. When there is no one tight to a request, remove the request
     from the database
    */
    static func deleteRequest(from requestRef: DatabaseReference, requestID: String, completionHandler: @escaping (Bool) -> Void) {

        requestRef.removeValue(completionBlock: { (error, _) in
            if let error = error {
                assertionFailure("Failed to remove request reference from user: " + error.localizedDescription)
                return completionHandler(false)
            }
            
            // Update the participant number of the request
            let participantRef = Database.database().reference().child("Requests/\(requestID)/participant_num")
            participantRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currNum = mutableData.value as? Int ?? 2
                mutableData.value = currNum - 1
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, snapshot) in
                if let error = error {
                    assertionFailure("Failed to update request's participant number: " + error.localizedDescription)
                    return completionHandler(false)
                } else {
                    // Delete the entire request if there is no participant
                    if let participantNum = snapshot?.value as? Int {
                        if participantNum == 0 {
                            let ref = Database.database().reference().child("Requests/\(requestID)")
                            ref.setValue(nil)
                        }
                    }
                    return completionHandler(true)
                }
            })
        })
    }
    
    /**
     Update a request -> either cancel or reject a request. Update the status of the request, and
     the requester list of each requested items
    */
    static func updateRequest(for request: Request, withNewStatus status: String, completion: @escaping (Bool) -> Void) {
        guard let requestKey = request.requestKey else {
            return completion(false)
        }
        var data: [String: Any] = [
            "Requests/\(requestKey)/status": status
        ]
        let posterItemsKey = Array(request.posterItemsData.keys)
        for itemRef in posterItemsKey {
            if status == "Accepted" {
                data["allItems/\(itemRef)/availability"] = false
            }
            data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
        }
        
        let requesterItemsKey = Array(request.requesterItemsData.keys)
        for itemRef in requesterItemsKey {
            if status == "Accepted" {
                data["allItems/\(itemRef)/availability"] = false
            }
            data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
        }
        
        Database.database().reference().updateChildValues(data, withCompletionBlock: { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            return completion(true)
        })
    }
}


