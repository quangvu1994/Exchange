//
//  EXTableCollectionCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/31/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EXTableCollectionCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var itemList = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var controller: DisplayItemDetailHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension EXTableCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if itemList.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont(name: "Futura", size: 14)
            emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
            emptyLabel.numberOfLines = 2
            emptyLabel.text = "No items offered "
            collectionView.backgroundView = emptyLabel
        }
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Collection Image Cell", for: indexPath) as! MyItemPostImageCell
        if let controller = controller {
            cell.delegate = controller
            cell.gestureDisplayingItemDetailWithInfo()
        }
        
        let url = URL(string: itemList[indexPath.row].imagesURL[0])
        cell.itemImageURL = itemList[indexPath.row].imagesURL[0]
        cell.itemDescription = itemList[indexPath.row].postDescription
        cell.itemTitle = itemList[indexPath.row].postTitle
        
        cell.postImage.kf.setImage(with: url)
        let itemRef = Database.database().reference().child("allItems/\(itemList[indexPath.row].key!)/availability")
        itemRef.observe(.value, with: { (snapshot) in 
            guard let availability = snapshot.value as? Bool else {
                return
            }
            
            if !availability {
                cell.imageLabel.isHidden = false
            } else {
                cell.imageLabel.isHidden = true
            }
        })
        return cell
    }
}


extension EXTableCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
