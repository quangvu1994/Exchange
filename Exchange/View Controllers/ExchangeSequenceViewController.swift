//
//  ExchangeSequenceViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/13/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ExchangeSequenceViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var currItems = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var posterItems = [Post]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch post
        PostService.fetchPost(for: posterItems[0].poster.uid, completionHandler: { [weak self] post in
            self?.currItems = post.filter {
                $0.requestedBy["\(User.currentUser.uid)"] != true && $0.availability == true
            }
        })
        collectionView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifer = segue.identifier {
            if identifer == "Finish Selecting Their Items" {
                let selectedItems = currItems.filter { $0.selected == true }
                let stepTwoViewController = segue.destination as! SelectingMyItemsViewController
                stepTwoViewController.posterItems = posterItems + selectedItems
            }
        }
    }
    @IBAction func addItemAction(_ sender: UIButton) {
        // Filter myPost with only selected post
        self.performSegue(withIdentifier: "Finish Selecting Their Items", sender: nil)
    }
    
    @IBAction func unwindFromStepTwo(_ sender: UIStoryboardSegue) {
        print("Back")
    }
}

extension ExchangeSequenceViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item Cell", for: indexPath) as! EXCollectionViewCell
        let imageURL = URL(string: currItems[indexPath.row].imagesURL[0])
        cell.itemImage.kf.setImage(with: imageURL)
        cell.delegate = self
        cell.addTapGesture()
        cell.index = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Undefined collection view kind")
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EX Header", for: indexPath)
        
        return header
    }
}

extension ExchangeSequenceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfRows: CGFloat = 3
        let spacingWidth: CGFloat = 3
        let totalHorizontalSpacing = (numberOfRows - 1) * spacingWidth
        let cellWidth = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfRows
        
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3.0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension ExchangeSequenceViewController: ImageSelectHandler {
    func storeSelectedImages(for selectedCell: EXCollectionViewCell) {
        guard let index = selectedCell.index else {
            print("This cell doesn't have an assigned index")
            return
        }
        selectedCell.toggleSelectedCheckmark()
        currItems[index].selected = selectedCell.buttonIsSelected
    }
}
