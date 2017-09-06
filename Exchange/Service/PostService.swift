//
//  PostService.swift
//  Exchange
//
//  Created by Quang Vu on 7/9/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PostService {
    
    static func writePostImageToFIRStorage(_ imageList: [UIImage?], completion: @escaping ([String]?) -> Void){
        var imagesURL = [String?].init(repeating: nil, count: imageList.count)
        let dispGroup = DispatchGroup()
        
        for i in 0..<imageList.count {
            guard let image = imageList[i] else {
                continue
            }
            
            dispGroup.enter()
            guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
                dispGroup.leave()
                return completion(nil)
            }
            
            // Construct reference path
            let ref = FIRStorageUtilities.constructReferencePath()
            ref.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    dispGroup.leave()
                    return completion(nil)
                }
                
                // Retrieve the downloadURL
                guard let downloadURL = metaData?.downloadURL() else {
                    dispGroup.leave()
                    return completion(nil)
                }
                
                let imageURL = downloadURL.absoluteString
                imagesURL[i] = imageURL
                dispGroup.leave()
            })
        }
        
        dispGroup.notify(queue: .main, execute: {
            let finalizedImages: [String] = imagesURL.flatMap { return $0 }
            completion(finalizedImages)
        })
    }
    
    static func writePostToFIRDatabase(for post: Post, completion: @escaping (Bool) -> Void) {
        let currentUID = User.currentUser.uid
        let allPostRef = Database.database().reference().child("allItems").childByAutoId()
        allPostRef.updateChildValues(post.dictValue, withCompletionBlock: { (error, snapshot) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            let data = ["\(snapshot.key)": true]
            let postRef = Database.database().reference().child("items").child(currentUID)
            postRef.updateChildValues(data)
            completion(true)
        })
    }
    
    /**
     Update the existing post with a new data
    */
    static func updatePostOnFIR(for postID: String, with post: Post, completion: @escaping (Bool) -> Void) {
        let allPostRef = Database.database().reference().child("allItems/\(postID)")
        allPostRef.updateChildValues(post.dictValue, withCompletionBlock: { (error, snapshot) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            completion(true)
        })
    }
    
    /**
     Fetch all items from the "all items" object
    */
    static func fetchPost(completionHandler: @escaping ([Post]) -> Void) {
        
        let ref = Database.database().reference().child("allItems")

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completionHandler([])
            }
            
            let allPost: [Post] = snapshot.reversed().flatMap {
                guard let post = Post(snapshot: $0) else {
                    return nil
                }
                return post
            }
            completionHandler(allPost)
        })
    }
    
    /**
     Fetch a specific post
    */
    static func fetchSpecificPost(for postID: String, completionHandler: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("allItems/\(postID)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let post = Post(snapshot: snapshot)
            completionHandler(post)
        })
    }
    
    /**
     Fetch all post for a specific user
    */
    static func fetchPost(for userid: String, completionHandler: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference().child("items").child(userid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.value as? [String: Bool] else {
                return completionHandler([])
            }
            
            let allPostRef = snapshot.reversed().flatMap {
                return $0.key
            }
            
            let dispatchGroup = DispatchGroup()
            var postList = [Post]()
            
            for postRef in allPostRef {
                dispatchGroup.enter()
                Database.database().reference().child("allItems/\(postRef)").observeSingleEvent(of: .value, with: { snapshot in
                    guard let post = Post(snapshot: snapshot) else {
                        return
                    }
                    postList.append(post)
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: .main, execute: {
                completionHandler(postList)
            })
        })
    }
    
    /**
     Delete a specific post from the database
    */
    static func deleteSpecificPost(for postID: String, completionHandler: @escaping (Bool) -> Void) {
        Database.database().reference().child("allItems/\(postID)").removeValue(completionBlock: { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completionHandler(false)
            }
            
            let itemRef = Database.database().reference().child("items/\(User.currentUser.uid)/\(postID)")
            itemRef.removeValue(completionBlock: { (error, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completionHandler(false)
                }
                
                completionHandler(true)
            })
        })
    }
    
    /**
     Store all flagged post
    */
    static func flag(_ post: Post) {
        // Grab post key
        guard let postKey = post.key else { return }
        
        // Create reference
        let flaggedPostRef = Database.database().reference().child("flaggedPosts").child(postKey)
        
        // Data
        let flaggedDict: [String: Any] = ["image_url": post.imagesURL,
                           "poster_uid": post.poster.uid,
                           "reporter_uid": User.currentUser.uid]
        
        // Write
        flaggedPostRef.updateChildValues(flaggedDict)
        
        // Increment flag count
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            
            mutableData.value = currentCount + 1
            
            return TransactionResult.success(withValue: mutableData)
        })
    }
}
