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
    
    static func writePostImageToFIRStorage(_ postImage: UIImage){
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
            self.writePostToFIRDatabase(imageURL: imageURL, imageHeight: imageHeight)
        })
    }
    
    static func writePostToFIRDatabase(imageURL: String, imageHeight: CGFloat) {
        let currentUID = User.currentUser.uid
        let post = Post(imageURL: imageURL, imageHeight: imageHeight)
        let postRef = Database.database().reference().child("posts").child(currentUID).childByAutoId()
        // Write
        postRef.updateChildValues(post.dictValue)
    }
    
    static func fetchAllPost() {
        
    }
    
}
