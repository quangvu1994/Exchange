//
//  SelectingMyItemsViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/25/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SelectingMyItemsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noItemView: UIView!
    
    var currItems = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var posterItems = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        // fetch post
        PostService.fetchPost(for: User.currentUser.uid, completionHandler: { [weak self] post in
            self?.currItems = post.filter {
                $0.availability == true
            }
            
            if (self?.currItems.isEmpty)! {
                self?.collectionView.backgroundView = self?.noItemView
            } else {
                self?.collectionView.backgroundView = nil
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifer = segue.identifier {
            if identifer == "Finish Selecting My Items" {
                let selectedItems = currItems.filter { $0.selected == true }
                let stepThreeViewController = segue.destination as! EXConfirmViewController
                stepThreeViewController.posterItems = posterItems
                stepThreeViewController.requesterItems = selectedItems
            }
        }
    }
    @IBAction func addItemAction(_ sender: UIButton) {
        // Filter myPost with only selected post
        self.performSegue(withIdentifier: "Finish Selecting My Items", sender: nil)
    }
    
    @IBAction func unwindFromStepThree(_ sender: UIStoryboardSegue) {
        print("Back")
    }
}

extension SelectingMyItemsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item Cell", for: indexPath) as! EXCollectionViewCell
        let imageURL = URL(string: currItems[indexPath.row].imagesURL[0])
        cell.checkMark.isHidden = !currItems[indexPath.row].selected
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
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Step 2 Header", for: indexPath)
        
        return header
    }
}

extension SelectingMyItemsViewController: UICollectionViewDelegateFlowLayout {
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

extension SelectingMyItemsViewController: ImageSelectHandler {
    func storeSelectedImages(for selectedCell: EXCollectionViewCell) {
        guard let index = selectedCell.index else {
            print("This cell doesn't have an assigned index")
            return
        }
        selectedCell.toggleSelectedCheckmark()
        currItems[index].selected = selectedCell.imageSelected
    }
}
