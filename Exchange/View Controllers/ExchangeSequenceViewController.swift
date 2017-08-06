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

    var posterItems = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var originalItem: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        guard let originalItem = originalItem else {
            return
        }
        // fetch post
        PostService.fetchPost(for: originalItem.poster.uid, completionHandler: { [weak self] post in
            self?.posterItems = post.filter {
                $0.requestedBy["\(User.currentUser.uid)"] != true && $0.availability == true
            }
            
            // Presect the original item
            for post in (self?.posterItems)! {
                if post.key == originalItem.key {
                    post.selected = true
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifer = segue.identifier {
            if identifer == "Finish Selecting Their Items" {
                let selectedItems = posterItems.filter { $0.selected == true }
                let stepTwoViewController = segue.destination as! SelectingMyItemsViewController
                stepTwoViewController.posterItems = selectedItems
            }
        }
    }
    @IBAction func addItemAction(_ sender: UIButton) {
        // Only continue if the user has selected at least one item
        let selectedItems = posterItems.filter { $0.selected == true }
        if !selectedItems.isEmpty {
            self.performSegue(withIdentifier: "Finish Selecting Their Items", sender: nil)
        } else {
            self.displayWarningMessage(message: "Please select at least one item")
        }
    }
    
    @IBAction func unwindFromStepTwo(_ sender: UIStoryboardSegue) {
        print("Back")
    }
}

extension ExchangeSequenceViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posterItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item Cell", for: indexPath) as! EXCollectionViewCell
        let imageURL = URL(string: posterItems[indexPath.row].imagesURL[0])
        cell.checkMark.isHidden = !posterItems[indexPath.row].selected
        if !cell.checkMark.isHidden {
            cell.itemImage.alpha = 0.5
            cell.imageSelected = true
        }
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
        posterItems[index].selected = selectedCell.imageSelected
    }
}
