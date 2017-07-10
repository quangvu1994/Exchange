//
//  PopularCategoriesViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class PopularCategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
    
}

extension PopularCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreCategoryCell", for: indexPath) as! ExploreCategoryCell
        switch indexPath.row {
        case 0:
            let backgroundImage = UIImage(named: "RoomEssential.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("ROOM ESSENTIAL", for: .normal)
            
        case 1:
            let backgroundImage = UIImage(named: "Clothes.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("CLOTHES", for: .normal)
            
        case 2:
            let backgroundImage = UIImage(named: "Electronic.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("ELECTRONIC", for: .normal)
            
        case 3:
            let backgroundImage = UIImage(named: "Book.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("BOOKS", for: .normal)
            
        default:
            fatalError("Unable to locate the current row")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // Dynamically set the height of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
