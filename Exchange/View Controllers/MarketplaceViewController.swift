//
//  MarketplaceViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class MarketplaceViewController: UIViewController {
    
    var post = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch all post
        let allPostReference = Database.database().reference().child("allPosts").child("allCategories")
        PostService.fetchPost(fromPath: allPostReference, completionHandler: { (allPosts) in
            self.post = allPosts
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = sender as? Int else {
            return
        }
        
        if let identifier = segue.identifier {
            if identifier == "displayItemDetail" {
                let viewControllerDestination = segue.destination as! ItemDetailViewController
                viewControllerDestination.selectedPost = post[index]
            }
        }
    }
}

extension MarketplaceViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostThumbImageCell", for: indexPath) as! PostThumbImageCell
        let imageURL = URL(string: post[indexPath.row].imageURL)
        cell.postImage.kf.setImage(with: imageURL)
        cell.delegate = self
        cell.addTapGestureToDisplayItemDetail()
        cell.index = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Unexpected element kind.")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MarketplaceHeaderView", for: indexPath) as! MarketplaceHeaderView
        
        return headerView
    }
}


extension MarketplaceViewController: UICollectionViewDelegateFlowLayout {
    
    // Set the size of each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 3
        // 2 spaces multiply by the length of each space = total horizontal spacing
        let totalHorizontalSpacing = (columns - 1) * spacing
        
        // Total width - the horizontal spacing = total width of all columns
        // Divide by number of columns to find the width of one column
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        // Instantiate a CGSize
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension MarketplaceViewController: DisplayItemDetailHandler {
    
    func display(index: Int) {
        self.performSegue(withIdentifier: "displayItemDetail", sender: index)
    }
    
}
