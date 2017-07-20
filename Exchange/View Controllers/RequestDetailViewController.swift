//
//  RequestDetailViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/19/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

class RequestDetailViewController: UIViewController {
    
    @IBOutlet weak var negotiateButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestMessage: UITextView!
    
    @IBOutlet weak var requesterItemsCollectionView: UICollectionView!
    @IBOutlet weak var posterItemsCollectionView: UICollectionView!
    
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        guard let request = request else {
            fatalError("Request not found")
        }
        
        requestMessage.text = request.message
    }
    
    func configure() {
        negotiateButton.layer.cornerRadius = 3
        negotiateButton.layer.borderColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0).cgColor
        negotiateButton.layer.borderWidth = 1
        confirmButton.layer.cornerRadius = 3
        requestMessage.isUserInteractionEnabled = false
    }
}

extension RequestDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let request = request else {
            fatalError("Request not found")
        }
        if collectionView == self.requesterItemsCollectionView {
            return request.requesterItems.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let request = request else {
            fatalError("Request not found")
        }
        
        if collectionView == self.requesterItemsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Requester Item Cell", for: indexPath) as! MyItemPostImageCell
            let imageURL = URL(string: request.requesterItems[indexPath.row].imageURL)
            cell.postImage.kf.setImage(with: imageURL)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Poster Item Cell", for: indexPath) as! MyItemPostImageCell
            let imageURL = URL(string: request.posterItem.imageURL)
            cell.postImage.kf.setImage(with: imageURL)
            return cell
        }
    }
}

extension RequestDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: requesterItemsCollectionView.bounds.height, height: requesterItemsCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
