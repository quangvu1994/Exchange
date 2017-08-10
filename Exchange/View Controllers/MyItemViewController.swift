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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var user: User?
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
        activityIndicator.startAnimating()
        collectionView.backgroundView = nil
        if let user = user {
            // fetch post for specific user
            PostService.fetchPost(for: user.uid, completionHandler: { [weak self] (allPosts) in
                self?.post = allPosts
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self?.view.bounds.width)!, height: (self?.view.bounds.height)!))
                emptyLabel.textAlignment = .center
                emptyLabel.font = UIFont(name: "Futura", size: 16)
                emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
                emptyLabel.numberOfLines = 2
                
                if self?.post.count == 0 {
                    emptyLabel.text = "\(user.username) doesn't have any item on the market"
                    self?.collectionView.backgroundView = emptyLabel
                }
                self?.activityIndicator.stopAnimating()
            })
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            // fetch post for current user
            PostService.fetchPost(for: User.currentUser.uid, completionHandler: { [weak self] (allPosts) in
                self?.post = allPosts
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self?.view.bounds.width)!, height: (self?.view.bounds.height)!))
                emptyLabel.textAlignment = .center
                emptyLabel.font = UIFont(name: "Futura", size: 16)
                emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
                emptyLabel.numberOfLines = 2
                
                if self?.post.count == 0 {
                    emptyLabel.text = "You've not listed any item on the market"
                    self?.collectionView.backgroundView = emptyLabel
                }
                self?.activityIndicator.stopAnimating()
            })
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
        cell.gestureDisplayingItemDetailWithIndex()
        cell.index = indexPath.row
        
        let itemRef = Database.database().reference().child("allItems/\(post[indexPath.row].key!)/availability")
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
    
    // Display the collection view header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // If it is not the collection header
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Undefined collection view kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyItemCollectionHeader", for: indexPath) as! MyItemHeaderView
        if let user = user {
            headerView.username.text = user.username
            headerView.userID = user.uid
            headerView.shopBriefDescription.text = user.storeDescription
            headerView.editButton.isHidden = true
        } else {
            headerView.username.text = User.currentUser.username
            headerView.userID = User.currentUser.uid
            headerView.shopBriefDescription.text = User.currentUser.storeDescription
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
    
    func displayWithIndex(index: Int) {
        self.performSegue(withIdentifier: "showItemDetail", sender: index)
    }
   
    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String) {
        // Not needed here
    }
}






