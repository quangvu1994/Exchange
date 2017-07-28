//
//  CollectionTableViewCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/20/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CollectionTableViewCell: UITableViewCell {

    var status: String?
    var itemList = [String: Any]() {
        didSet {
            collectionView.reloadData()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension CollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item Cell", for: indexPath) as! MyItemPostImageCell
        let key = Array(itemList.keys)[indexPath.row]
        
        if let itemDataDict = itemList[key] as? [String : Any],
            let url = itemDataDict["image_url"] as? String {
                let imageURL = URL(string: url)
                cell.postImage.kf.setImage(with: imageURL)
        }
        
        // Observe the availability of the item
        let itemRef = Database.database().reference().child("allItems/\(key)/availability")
        itemRef.observe(.value, with: { (snapshot) in
            guard let availability = snapshot.value as? Bool else {
                return
            }
            
            if !availability && self.status != "Confirmed"{
                cell.postImage.alpha = 0.5
                cell.soldLabel.isHidden = false
            } else {
                cell.postImage.alpha = 1.0
                cell.soldLabel.isHidden = true
            }
        })
        return cell
    }
}

extension CollectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

