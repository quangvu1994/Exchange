//
//  MarketplaceViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class MarketplaceViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureCategoryButton()
    }
    
    func configureTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
    
    func configureCategoryButton() {
    }
}

extension MarketplaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreCategoryCell", for: indexPath) as! ExploreCategoryCell
        switch indexPath.row {
        case 0:
            let backgroundImage = UIImage(named: "RoomEssential.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("Room Essential", for: .normal)

        case 1:
            let backgroundImage = UIImage(named: "Clothes.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("Clothes", for: .normal)

        case 2:
            let backgroundImage = UIImage(named: "Electronic.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("Electronic", for: .normal)

        case 3:
            let backgroundImage = UIImage(named: "Book.png")
            cell.categoryBackgroundView.image = backgroundImage!
            cell.categoryButton.setTitle("Book", for: .normal)

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
