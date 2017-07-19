//
//  RequestViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController {
    
    @IBOutlet weak var requestSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // fetch outgoing request
    }
    @IBAction func switchRequestType(_ sender: UISegmentedControl) {
        switch requestSegmentControl.selectedSegmentIndex {
        case 0:
            // Fetch outgoing request
            print("Sent")
        case 1:
            print("Received")
        default:
            break
        }
    }
}

extension RequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Request Cell", for: indexPath) as! RequestTableViewCell
        return cell
    }
}
