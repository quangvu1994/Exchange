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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var scenario: EXScenarios = .post
    
    var photoHelper = EXPhotoHelper()
    var imageList = [UIImage?].init(repeating: nil, count: 4)
    var postKey: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var postTitle: String?
    var postDescription: String?
    var wishList: String?
    var category: String?
    var tradeLocation: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.cornerRadius = 3
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
        switch scenario {
        case .edit:
            if imageList[0] == nil {
                activityIndicator.startAnimating()
            }
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
        view.alpha = 0.9
        activityIndicator.startAnimating()

        guard let title = postTitle,
            let description = postDescription,
            let category = category,
            let location = tradeLocation,
            let wishList = wishList else {
                UIApplication.shared.endIgnoringInteractionEvents()
                activityIndicator.stopAnimating()
                view.alpha = 1
                // Display an alert if user fail to fill out the required info
                self.displayWarningMessage(message: "Please fill out all information")
                return
        }
        
        switch scenario {
        case .edit:
            PostService.writePostImageToFIRStorage(imageList, completion: { [weak self] (imagesURL) in
                guard let imagesURL = imagesURL,
                    let postKey = self?.postKey else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self?.activityIndicator.stopAnimating()
                    self?.view.alpha = 1
                    self?.displayWarningMessage(message: "Unable to upload image, please try again")
                    return
                }
                
                let post = Post(imagesURL: imagesURL.reversed())
                post.postTitle = title
                post.postDescription = description
                post.postCategory = category
                post.tradeLocation = location
                post.wishList = wishList
                
                PostService.updatePostOnFIR(for: postKey, with: post, completion: { [weak self] (success) in
                    if success {
                        self?.displayWarningMessage(message: "Item Edited")
                    }else {
                        self?.displayWarningMessage(message: "Unable to edit the post, please try again")
                    }
                    self?.activityIndicator.stopAnimating()
                    self?.view.alpha = 1
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
            
        default:
            PostService.writePostImageToFIRStorage(imageList, completion: { [weak self] (imagesURL) in
                guard let imagesURL = imagesURL else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self?.activityIndicator.stopAnimating()
                    self?.view.alpha = 1
                    self?.displayWarningMessage(message: "Unable to upload image, please try posting again")
                    return
                }
                
                let post = Post(imagesURL: imagesURL.reversed())
                post.postTitle = title
                post.postDescription = description
                post.postCategory = category
                post.tradeLocation = location
                post.wishList = wishList
                
                PostService.writePostToFIRDatabase(for: post, completion: { [weak self] (success) in
                    if success {
                        // Clear everything in the table view
                        self?.imageList = [UIImage?].init(repeating: nil, count: 4)
                        self?.postTitle = nil
                        self?.postDescription = nil
                        self?.wishList = nil
                        self?.category = nil
                        self?.tradeLocation = nil
                        self?.tableView.reloadData()
                        self?.performSegue(withIdentifier: "showMarketplace", sender: post.postCategory)
                    }else {
                        self?.displayWarningMessage(message: "Unable to upload the post, please try posting again")
                    }
                    self?.activityIndicator.stopAnimating()
                    self?.view.alpha = 1
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
        }
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
        // Update category cell
        tableView.reloadData()
    }
}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
                    cell.firstImage.contentMode = .scaleAspectFill
                case 1:
                    cell.secondImage.image = selectedImage
                    cell.secondImageSet = true
                    cell.secondImage.contentMode = .scaleAspectFill
                case 2:
                    cell.thirdImage.image = selectedImage
                    cell.thirdImageSet = true
                    cell.thirdImage.contentMode = .scaleAspectFill
                case 3:
                    cell.fourthImage.image = selectedImage
                    cell.fourthImageSet = true
                    cell.fourthImage.contentMode = .scaleAspectFill
                default:
                    fatalError("Unrecognized Image")
                }
                self.imageList[self.photoHelper.imageIdentifier] = selectedImage
            }
            

            if imageList[0] == nil {
                cell.firstImage.image = UIImage(named: "Camera")
                cell.secondImage.image = UIImage(named: "Camera")
                cell.thirdImage.image = UIImage(named: "Camera")
                cell.fourthImage.image = UIImage(named: "Camera")
                cell.firstImageSet = false
                cell.secondImageSet = false
                cell.thirdImageSet = false
                cell.fourthImageSet = false
                cell.firstImage.contentMode = .center
                cell.secondImage.contentMode = .center
                cell.thirdImage.contentMode = .center
                cell.fourthImage.contentMode = .center
            } else {
                for i in 0..<imageList.count {
                    guard let _ = imageList[i] else {
                        continue
                    }
                    
                    switch i {
                    case 0:
                        cell.firstImage.image = imageList[i]
                        cell.firstImageSet = true
                        cell.firstImage.contentMode = .scaleAspectFill
                    case 1:
                        cell.secondImage.image = imageList[i]
                        cell.secondImageSet = true
                        cell.secondImage.contentMode = .scaleAspectFill
                    case 2:
                        cell.thirdImage.image = imageList[i]
                        cell.thirdImageSet = true
                        cell.thirdImage.contentMode = .scaleAspectFill
                    case 3:
                        cell.fourthImage.image = imageList[i]
                        cell.fourthImageSet = true
                        cell.fourthImage.contentMode = .scaleAspectFill
                    default:
                        break
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
            cell.getInformation = { [weak self] (text) in
                self?.postTitle = text
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            
            if postTitle == nil || postTitle == "" {
                cell.descriptionText.textColor = UIColor.lightGray
                cell.descriptionText.text = "Item Title"
            } else {
                cell.descriptionText.text = postTitle
                cell.descriptionText.textColor = UIColor.darkGray
            }
            return cell
    
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            
            cell.headerText.text = "Description"
            cell.placeHolder = "Item Description"
            cell.getInformation = { [weak self] (text) in
                self?.postDescription = text
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            
            if postDescription == nil || postDescription == "" {
                cell.descriptionText.textColor = UIColor.lightGray
                cell.descriptionText.text = "Item Description"
            } else {
                cell.descriptionText.text = postDescription
                cell.descriptionText.textColor = UIColor.darkGray
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.headerText.text = "Wish List"
            cell.placeHolder = "What you would want in exchange"
            cell.getInformation = { [weak self] (text) in
                self?.wishList = text
            }
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            
            if wishList == "" || wishList == nil {
                cell.descriptionText.textColor = UIColor.lightGray
                cell.descriptionText.text = "What you would want in exchange"
            } else {
                cell.descriptionText.text = wishList
                cell.descriptionText.textColor = UIColor.darkGray
            }
            
            return cell

        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CreatePostCategoryCell
            
            if scenario == .exchange {
                cell.accessoryType = .none
                cell.isUserInteractionEnabled = false
            }
            
            if let text = category {
                cell.categoryName.text = text
            } else {
                cell.categoryName.text = ""
            }
        
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.view = view
            cell.headerText.text = "Trade Location"
            cell.placeHolder = "Where we'll meet"
            cell.getInformation = { [weak self] (text) in
                self?.tradeLocation = text
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            
            if tradeLocation == nil {
                cell.descriptionText.textColor = UIColor.lightGray
                cell.descriptionText.text = "Where we'll meet"
            } else {
                cell.descriptionText.text = tradeLocation
                cell.descriptionText.textColor = UIColor.darkGray
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
            return 150
        case 4:
            return 60
        case 5:
            return 150
        default:
            fatalError("Unable to locate the current row")
        }
    }
}
