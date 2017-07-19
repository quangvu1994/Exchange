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
    
    static func writePostImageToFIRStorage(_ postImage: UIImage, completion: @escaping (String?) -> Void){
        // Convert image to Data and lower the quality (Read class description) -> faster to upload
        guard let imageData = UIImageJPEGRepresentation(postImage, 0.1) else {
            return
        }
        // Construct reference path
        let ref = FIRStorageUtilities.constructReferencePath()
        ref.putData(imageData, metadata: nil, completion: { (metaData, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            // Retrieve the downloadURL
            guard let downloadURL = metaData?.downloadURL() else {
                return completion(nil)
            }
            
            let imageURL = downloadURL.absoluteString
            completion(imageURL)
        })
    }
    
    static func writePostToFIRDatabase(for post: Post, completion: @escaping (Bool) -> Void) {
        let currentUID = User.currentUser.uid
        let postRef = Database.database().reference().child("items").child(currentUID).childByAutoId()
        postRef.updateChildValues(post.dictValue)
        // Also write to all post parent node
        let allPostRef = Database.database().reference().child("allItems").child("allCategories").childByAutoId()
        allPostRef.updateChildValues(post.dictValue)
        completion(true)

    }
    
    /**
     Fetch all items from the provided database reference path
    */
    static func fetchPost(fromPath reference: DatabaseReference, completionHandler: @escaping ([Post]) -> Void) {
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
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
}
