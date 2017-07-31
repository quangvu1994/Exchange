//
//  EXTableCollectionCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/31/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class EXTableCollectionCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var itemList = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension EXTableCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Collection Image Cell", for: indexPath) as! MyItemPostImageCell
        let url = URL(string: itemList[indexPath.row].imagesURL[0])
        cell.postImage.kf.setImage(with: url)
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
