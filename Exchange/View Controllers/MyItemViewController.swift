//
//  MyItemViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class MyItemViewController: UIViewController {
    var userId: String?
    var username: String?
    var post = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        if let userId = userId {
            // fetch post for specific user
            PostService.fetchPost(for: userId, completionHandler: { [weak self] (allPosts) in
                self?.post = allPosts
            })
        } else {
            // fetch post for current user
            PostService.fetchPost(for: User.currentUser.uid, completionHandler: { [weak self] (allPosts) in
                self?.post = allPosts
            })
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = sender as? Int else {
            return
        }
        
        if let identifier = segue.identifier {
            if identifier == "showItemDetail" {
                let destinationViewController = segue.destination as! ItemDetailViewController
                destinationViewController.post = post[index]
                destinationViewController.scenario = .edit
            }
        }
    }
    
    @IBAction func unwindFromPersonalItemDetail(_ sender: UIStoryboardSegue) {
        print("unwinded")
    }
}

extension MyItemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as! MyItemPostImageCell
        let imageURL = URL(string: post[indexPath.row].imagesURL[0])
        cell.postImage.kf.setImage(with: imageURL)
        cell.delegate = self
        cell.addTapGestureToDisplayItemDetail()
        cell.index = indexPath.row
        return cell

    }
    
    // Display the collection view header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // If it is not the collection header
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Undefined collection view kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyItemCollectionHeader", for: indexPath) as! MyItemHeaderView
        if let username = username {
            headerView.username.text = username
        } else {
            headerView.username.text = User.currentUser.username
        }
        return headerView
    }
}

extension MyItemViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let spacingLength: CGFloat = 3
        
        let totalHorizontalSpacing = (numberOfColumns - 1) * spacingLength
        let cellWidth = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfColumns
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3.0, left: 0, bottom: 0, right: 0)
    }
    
    // Spacing between section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    // Spacing between cell items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension MyItemViewController: DisplayItemDetailHandler {
    
    func display(index: Int) {
        self.performSegue(withIdentifier: "showItemDetail", sender: index)
    }
}







