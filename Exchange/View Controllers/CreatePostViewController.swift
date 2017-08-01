//
//  CreatePostViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    
    var currentPost: Post?
    var scenario: EXScenarios = .post
    
    var photoHelper = EXPhotoHelper()
    var category: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.cornerRadius = 3
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
        switch scenario {
        case .edit:
            self.navigationItem.title = "Edit Item"
            actionButton.setTitle("Save Changes", for: .normal)
        default:
            actionButton.setTitle("Post Item", for: .normal)
        }
    }

    func openImagePicker(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else {
            return
        }
        photoHelper.imageIdentifier = view.tag
        photoHelper.presentActionSheet(from: self)
    }
    
    @IBAction func performAction(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        switch scenario {
        case .edit:
            print("Save Changes")
            
        default:
            var imageList: [UIImage]?
            var postTitle: String?
            var postDescription: String?
            var postCategory: String?
            var tradeLocation: String?
            
            for row in 0..<tableView.numberOfRows(inSection: 0) {
                switch row {
                case 0:
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! CreatePostCameraCell
                    imageList = cell.getImageInformation()
                case 1:
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! CreatePostDescriptionCell
                    postTitle = cell.getInformation()
                case 2:
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! CreatePostDescriptionCell
                    postDescription = cell.getInformation()
                    
                case 3:
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! CreatePostCategoryCell
                    postCategory = cell.getInformation()
                case 4:
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! CreatePostDescriptionCell
                    tradeLocation = cell.getInformation()
                default:
                    fatalError("Unrecognized row")
                }
            }
            
            guard let selectedImages = imageList,
                let title = postTitle,
                let description = postDescription,
                let category = postCategory,
                let location = tradeLocation else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    // Display an alert if user fail to fill out the required info
                    self.displayWarningMessage(message: "Please fill out all information")
                    return
            }
            
            PostService.writePostImageToFIRStorage(selectedImages, completion: { [weak self] (imagesURL) in
                guard let imagesURL = imagesURL else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self?.displayWarningMessage(message: "Unable to upload image, please try posting again")
                    return
                }
                
                let post = Post(imagesURL: imagesURL)
                post.postTitle = title
                post.postDescription = description
                post.postCategory = category
                post.tradeLocation = location
                
                PostService.writePostToFIRDatabase(for: post, completion: { [weak self] (completed) in
                    if completed {
                        // Clear everything in the table view
                        self?.tableView.reloadData()
                        self?.performSegue(withIdentifier: "showMarketplace", sender: post.postCategory)
                    }else {
                        self?.displayWarningMessage(message: "Unable to upload the post, please try posting again")
                    }
                })
            })
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showMarketplace" {
                let marketplaceView = segue.destination as! MarketplaceViewController
                guard let category = sender as? String else {
                    marketplaceView.category = "others"
                    return
                }
                marketplaceView.category = category
            }
        }
    }

    @IBAction func unwindFromCategorySelection(_ sender: UIStoryboardSegue) {
        // Update the category cell
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CreatePostCategoryCell
        cell.categoryName.text = self.category
    }
}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CameraCell", for: indexPath) as! CreatePostCameraCell
            
            cell.firstImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreatePostViewController.openImagePicker(gesture:))))
            cell.secondImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreatePostViewController.openImagePicker(gesture:))))
            cell.thirdImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(CreatePostViewController.openImagePicker(gesture:))))
            cell.fourthImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(CreatePostViewController.openImagePicker(gesture:))))
            
            photoHelper.completionHandler = { [unowned self] (selectedImage) in
                switch self.photoHelper.imageIdentifier {
                case 0:
                    cell.firstImage.image = selectedImage
                    cell.firstImageSet = true
                case 1:
                    cell.secondImage.image = selectedImage
                    cell.secondImageSet = true
                case 2:
                    cell.thirdImage.image = selectedImage
                    cell.thirdImageSet = true
                case 3:
                    cell.fourthImage.image = selectedImage
                    cell.fourthImageSet = true
                default:
                    fatalError("Unrecognized Image")
                }
            }
            
            if let currentPost = currentPost {
                for i in 0..<currentPost.imagesURL.count {
                    let url = URL(string: currentPost.imagesURL[i])
                    switch i {
                    case 0:
                        cell.firstImage.kf.setImage(with: url)
                    case 1:
                        cell.secondImage.kf.setImage(with: url)
                    case 2:
                        cell.thirdImage.kf.setImage(with: url)
                    case 3:
                        cell.fourthImage.kf.setImage(with: url)
                    default:
                        fatalError("Unrecognized image index")
                    }
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell

            cell.headerText.text = "Title"
            cell.placeHolder = "Item Title"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.postTitle
            } else {
                if let text = cell.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Item Title"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell
    
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            
            cell.headerText.text = "Description"
            cell.placeHolder = "Item Description"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.postDescription
            } else {
                if let text = cell.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Item Description"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CreatePostCategoryCell
            if let currentPost = currentPost {
                cell.categoryName.text = currentPost.postCategory
                self.category = currentPost.postCategory
                
            }else {
                if let text = cell.getInformation() {
                    cell.categoryName.text = text
                } else {
                    cell.categoryName.text = ""
                }
            }
            
            if scenario == .exchange {
                cell.accessoryType = .none
                cell.isUserInteractionEnabled = false
            }
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.view = view
            cell.headerText.text = "Trade Location"
            cell.placeHolder = "Where we'll meet"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.tradeLocation
            } else {
                if let text = cell.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Where we'll meet"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
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
            return 100
        case 2:
            return 150
        case 3:
            return 60
        case 4:
            return 150
        default:
            fatalError("Unable to locate the current row")
        }
    }
}
