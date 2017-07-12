//
//  ItemDetailViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/12/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var selectedPost: Post?

    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        deleteButton.layer.cornerRadius = 6
    }
    
}

extension ItemDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Camera Cell", for: indexPath) as! CreatePostCameraCell
            let imageURL = URL(string: (selectedPost?.imageURL)!)
            cell.postImage.kf.setImage(with: imageURL)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Description Cell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.text = selectedPost?.postTitle
            cell.placeHolder = "Item Title"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Description Cell", for: indexPath) as! CreatePostDescriptionCell
            cell.descriptionText.text = selectedPost?.postDescription
            cell.placeHolder = "Item Description"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category Cell", for: indexPath) as! CreatePostCategoryCell
            cell.categoryName.text = selectedPost?.postCategory
            return cell
            
        default:
            fatalError("No such row")
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
