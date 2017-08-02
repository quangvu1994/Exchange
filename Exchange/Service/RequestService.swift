//
//  RequestService.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import FirebaseDatabase

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
                data["allItems/\(postRef)/requested_by"] = [requesterID: true]
            }
            
            for reqRef in request.requesterItemsData.keys {
                data["allItems/\(reqRef)/requested_by"] = [requesterID: true]
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
}
