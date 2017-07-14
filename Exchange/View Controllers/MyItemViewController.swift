//
//  MyItemViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class MyItemViewController: UIViewController {
    var post = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch post
        let postRef = Database.database().reference().child("posts").child(User.currentUser.uid)
        PostService.fetchPost(fromPath: postRef, completionHandler: { (allPosts) in
            self.post = allPosts
        })
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = sender as? Int else {
            return
        }
        
        if let identifier = segue.identifier {
            if identifier == "displayItemDetail" {
                let destinationViewController = segue.destination as! CreatePostViewController
                destinationViewController.currentPost = post[index]
                destinationViewController.scenario = .edit
            }
        }
    }
}

extension MyItemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as! MyItemPostImageCell
        let imageURL = URL(string: post[indexPath.row].imageURL)
        cell.postImage.kf.setImage(with: imageURL)
        cell.delegate = self
        cell.addTapGestureToDisplayItemDetail()
        cell.index = indexPath.row
        return cell

    }
    
    // Display the collection view header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // If it is not the collection header
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Undefined collection view kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyItemCollectionHeader", for: indexPath) as! MyItemHeaderView
        headerView.username.text = User.currentUser.username
        
        return headerView
    }
}

extension MyItemViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 2
        let spacingLength: CGFloat = 3
        
        let totalHorizontalSpacing = (numberOfColumns - 1) * spacingLength
        let cellWidth = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfColumns
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        return cellSize
    }
    
    // Spacing between section and cell items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    // Spacing between cell items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension MyItemViewController: DisplayItemDetailHandler {
    
    func display(index: Int) {
        self.performSegue(withIdentifier: "displayItemDetail", sender: index)
    }
}







