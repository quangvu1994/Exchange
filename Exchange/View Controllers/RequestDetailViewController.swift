//
//  RequestDetailViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/19/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class RequestDetailViewController: UIViewController {
    
    @IBOutlet weak var negotiateButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestMessage: UITextView!
    
    @IBOutlet weak var requesterItemsCollectionView: UICollectionView!
    @IBOutlet weak var posterItemsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        negotiateButton.layer.cornerRadius = 3
        negotiateButton.layer.borderColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0).cgColor
        negotiateButton.layer.borderWidth = 1
        confirmButton.layer.cornerRadius = 3
        
    }
}

extension RequestDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.requesterItemsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Requester Item Cell", for: indexPath) as! MyItemPostImageCell
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Poster Item Cell", for: indexPath) as! MyItemPostImageCell
            return cell
        }
    }
    
}
