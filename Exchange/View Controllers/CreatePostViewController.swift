//
//  CreatePostViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import UIKit

protocol PostInformationRetriever {
    func getInformation() -> String?
}

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    
    var postTitleDelegate: PostInformationRetriever?
    var postDescriptionDelegate: PostInformationRetriever?
    var postCategoryDelegate: PostInformationRetriever?
    
    let photoHelper = EXPhotoHelper()
    var category: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postButton.layer.cornerRadius = 6
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
    }
    
    @IBAction func openPhotoHelper(_ sender: UIButton) {
        photoHelper.presentActionSheet(from: self)
    }
    
    @IBAction func postItem(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let selectedImage = photoHelper.selectedImage,
            let postTitle = postTitleDelegate?.getInformation(),
            let postDescription = postDescriptionDelegate?.getInformation(),
            let postCategory = postCategoryDelegate?.getInformation() else {
                UIApplication.shared.endIgnoringInteractionEvents()
                // Display an alert if user fail to fill out the required info
                let alertController = UIAlertController(title: nil, message: "Please fill out all information", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        
        PostService.writePostImageToFIRStorage(selectedImage, completion: { (downloadURL) in
            guard let downloadURL = downloadURL else {
                UIApplication.shared.endIgnoringInteractionEvents()
                print("Something wrong, try post again")
                return
            }
            
            let imageHeight = selectedImage.aspectHeight
            let post = Post(imageURL: downloadURL, imageHeight: imageHeight)
            post.postTitle = postTitle
            post.postDescription = postDescription
            post.postCategory = postCategory

            PostService.writePostToFIRDatabase(for: post, completion: { (completed) in
                if completed {
                    // Reload the table view with the original data
                    self.tableView.reloadData()
                    self.performSegue(withIdentifier: "showMarketplace", sender: self)
                }else {
                    print("Something wrong, try post again")
                }
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        })
    }

    @IBAction func unwindToCreatePost(_sender: UIStoryboardSegue) {
        // Update the category cell 
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CreatePostCategoryCell
        cell.categoryName.text = self.category
    }
}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CameraCell", for: indexPath) as! CreatePostCameraCell
            photoHelper.completionHandler = { (selectedImage) in
                cell.postImage.image = selectedImage
            }
            
            cell.postImage.image = nil
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = "Item Title"
            cell.placeHolder = "Item Title"
            self.postTitleDelegate = cell
            return cell
    
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = "Item Description"
            cell.placeHolder = "item Description"
            self.postDescriptionDelegate = cell
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CreatePostCategoryCell
            self.postCategoryDelegate = cell
            cell.categoryName.text = ""
            return cell

        default:
            fatalError("Unable to locate the current row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 200
        case 1:
            return 40
        case 2:
            return 150
        case 3:
            return 60
        default:
            fatalError("Unable to locate the current row")
        }
    }
}
