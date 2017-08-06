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
    var cashAmount: String?
    var controller: DisplayItemDetailHandler?
    
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
        var numOfItems = itemList.count
        if let _ = cashAmount {
            numOfItems += 1
        }
        
        if numOfItems == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont(name: "Futura", size: 14)
            emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
            emptyLabel.numberOfLines = 2
            emptyLabel.text = "No items offered "
            collectionView.backgroundView = emptyLabel
        }
        return numOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item Cell", for: indexPath) as! MyItemPostImageCell
        // If there is cash
        if let cashAmount = cashAmount {
            // if this is the last cell
            if indexPath.row == itemList.count {
                cell.imageLabel.text = cashAmount
                cell.imageLabel.isHidden = false
                return cell
            }
        }

        if let controller = controller {
            cell.delegate = controller
            cell.gestureDisplayingItemDetailWithInfo()
        }
        
        let key = Array(itemList.keys)[indexPath.row]
        
        if let itemDataDict = itemList[key] as? [String : Any],
            let url = itemDataDict["image_url"] as? String,
            let itemTitle = itemDataDict["post_title"] as? String,
            let itemDescription = itemDataDict["post_description"] as? String {
                let imageURL = URL(string: url)
                cell.postImage.kf.setImage(with: imageURL)
                cell.itemImageURL = url
                cell.itemTitle = itemTitle
                cell.itemDescription = itemDescription
        }
        
        // Observe the availability of the item
        let itemRef = Database.database().reference().child("allItems/\(key)/availability")
        itemRef.observe(.value, with: { (snapshot) in
            guard let availability = snapshot.value as? Bool else {
                return
            }
            
            if !availability && self.status != "Confirmed"{
                cell.soldLabel.isHidden = false
            } else {
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

