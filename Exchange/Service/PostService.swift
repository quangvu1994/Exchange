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
    
    static func writePostImageToFIRStorage(_ imageList: [UIImage], completion: @escaping ([String]?) -> Void){
        var imagesURL = [String]()
        let dispGroup = DispatchGroup()
        
        for image in imageList {
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
                imagesURL.append(imageURL)
                dispGroup.leave()
            })
        }
        
        dispGroup.notify(queue: .main, execute: {
            completion(imagesURL)
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
}
