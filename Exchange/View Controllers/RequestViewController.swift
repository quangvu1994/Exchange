//
//  RequestViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

class RequestViewController: UIViewController {
    
    @IBOutlet weak var requestSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var requestList = [Request]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // fetch outgoing request
        RequestService.retrieveIncomingRequest(completionHandler: { [weak self] (outgoingRequest) in
            self?.requestList = outgoingRequest
        })
    }
    @IBAction func switchRequestType(_ sender: UISegmentedControl) {
        switch requestSegmentControl.selectedSegmentIndex {
        case 0:
            // Fetch outgoing request
            RequestService.retrieveIncomingRequest(completionHandler: { [weak self] (outgoingRequest) in
                self?.requestList = outgoingRequest
            })
        case 1:
            // Fetch incoming request
            RequestService.retrieveOutgoingRequest(completionHandler: { [weak self] (incomingRequest) in
                self?.requestList = incomingRequest
            })
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Show Request Detail" {
                let detailViewController = segue.destination as! RequestDetailViewController
                detailViewController.request = requestList[tableView.indexPathForSelectedRow!.row]
            }
        }
    }
    
    @IBAction func unwindToRequestViewController(_ sender: UIStoryboardSegue) {
        print("unwinded")
    }
}

extension RequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Request Cell", for: indexPath) as! RequestTableViewCell
        cell.itemTitle.text = requestList[indexPath.row].posterItem.postTitle
        let imageURL = URL(string: requestList[indexPath.row].posterItem.imageURL)
        cell.itemImage.kf.setImage(with: imageURL)
        cell.poster.text = requestList[indexPath.row].posterItem.poster.username
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
