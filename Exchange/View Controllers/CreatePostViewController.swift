//
//  CreatePostViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import UIKit

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    
    let photoHelper = EXPhotoHelper()
    var postOriginalStateInfo = [
        "postTitlePlaceHolder": "Item Titlte",
        "postDescriptionPlaceHolder": "Post Description"
        ]
    var resetImage = false
    
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
        guard let selectedImage = photoHelper.selectedImage else {
            // No Image Selected -> do something
            return
        }
        PostService.writePostImageToFIRStorage(selectedImage, completion: { (completed) in
            if completed {
                // Reload the table view with the original data
                self.resetImage = true
                self.tableView.reloadData()
                self.performSegue(withIdentifier: "showMarketplace", sender: self)
            }else {
                print("Something Wrong, try post again")
            }
        })
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
            
            if resetImage {
                photoHelper.selectedImage = nil
                cell.postImage.image = nil
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = postOriginalStateInfo["postTitlePlaceHolder"]
            cell.placeHolder = postOriginalStateInfo["postTitlePlaceHolder"]
            return cell
    
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = postOriginalStateInfo["postDescriptionPlaceHolder"]
            cell.placeHolder = postOriginalStateInfo["postDescriptionPlaceHolder"]
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CreatePostCategoryCell
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
