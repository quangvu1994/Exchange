//
//  CategoriesViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import Foundation
import UIKit

class CategoriesViewController: UIViewController {
    
    var categoryList = [
        "Clothes", "Room Essential", "Books", "Electronic", "Others"
    ]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifer = segue.identifier {
            if identifer == "FinishSelectingCategory" {
                let viewController = segue.destination as! CreatePostViewController
                let indexPath = tableView.indexPathForSelectedRow!
                let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
                viewController.category = cell.categoryName.text!
            }
        }
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryName.text = categoryList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
