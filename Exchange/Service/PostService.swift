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
    
    static func writePostImageToFIRStorage(_ postImage: UIImage, completion: @escaping (Bool) -> Void){
        // Convert image to Data and lower the quality (Read class description) -> faster to upload
        guard let imageData = UIImageJPEGRepresentation(postImage, 0.1) else {
            return
        }
        // Construct reference path
        let ref = FIRStorageUtilities.constructReferencePath()
        ref.putData(imageData, metadata: nil, completion: { (metaData, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            // Retrieve the downloadURL
            guard let downloadURL = metaData?.downloadURL() else {
                return
            }
            let imageURL = downloadURL.absoluteString
            let imageHeight = postImage.aspectHeight
            self.writePostToFIRDatabase(imageURL: imageURL, imageHeight: imageHeight, completion: completion)
        })
    }
    
    static func writePostToFIRDatabase(imageURL: String, imageHeight: CGFloat, completion: @escaping (Bool) -> Void) {
        let currentUID = User.currentUser.uid
        let post = Post(imageURL: imageURL, imageHeight: imageHeight)
        let postRef = Database.database().reference().child("posts").child(currentUID).childByAutoId()
        postRef.updateChildValues(post.dictValue)
        // Also write to all post parent node
        let allPostRef = Database.database().reference().child("allPosts").child("allCategories").childByAutoId()
        allPostRef.updateChildValues(post.dictValue)
        completion(true)
        
    }
    
    /**
     Fetch all posts from the provided database reference path
    */
    static func fetchPost(fromPath postRef: DatabaseReference, completionHandler: @escaping ([Post]) -> Void) {
        
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
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
