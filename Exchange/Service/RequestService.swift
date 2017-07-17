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
    static func writeNewRequest(at databaseReference: DatabaseReference, for request: Request) {
        databaseReference.setValue(request.dictValue)
    }
    
    /**
     Retrievei all incoming request for our current user
    */
    static func retrieveIncomingRequest() {
        
    }
    
    
    /**
     Retrieve all outgoing request for our current user
    */
    static func retrieveOutgoingRequest() {
        
    }
}
