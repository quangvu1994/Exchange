//
//  ConfirmedRequestViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/20/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class RequestDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var request: Request?
    var segmentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
}

extension RequestDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade Partner Info", for: indexPath) as! PartnerTableViewCell
            if let request = request,
                let segmentIndex = segmentIndex {
                cell.address.text = request.posterItem[0].tradeLocation
                cell.message.text = request.message
                if segmentIndex == 0 {
                    cell.username.text = request.posterItem[0].poster.username
                    cell.phoneNumber.text = request.posterItem[0].poster.phoneNumber
                } else {
                    cell.username.text = request.requester.username
                    cell.phoneNumber.text = request.requester.phoneNumber
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection View Cell", for: indexPath) as! CollectionTableViewCell
            if let request = request {
                cell.itemList = request.requesterItems
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade For", for: indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection View Cell", for: indexPath) as! CollectionTableViewCell
            if let request = request {
                cell.itemList = request.posterItem
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath) as! ButtonTableViewCell
            return cell
            
        default:
            fatalError("Unrecognized index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        case 1:
            return 150
        case 2:
            return 40
        case 3:
            return 150
        case 4:
            return 80
        default:
            fatalError("Unrecognized index path row")
        }
    }
}
