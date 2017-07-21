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
        requestSegmentControl.layer.cornerRadius = 0
        requestSegmentControl.layer.borderColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0).cgColor
        requestSegmentControl.layer.borderWidth = 1
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
                detailViewController.segmentIndex = requestSegmentControl.selectedSegmentIndex
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
        if requestSegmentControl.selectedSegmentIndex == 0 {
            cell.poster.text = requestList[indexPath.row].posterItem[0].poster.username
            cell.briefDescription.text = requestList[indexPath.row].posterItem[0].postTitle
        } else {
            cell.poster.text = requestList[indexPath.row].requesterName
            cell.briefDescription.text = requestList[indexPath.row].message
        }
        
        let imageURL = URL(string: requestList[indexPath.row].posterItem[0].imageURL)
        cell.itemImage.kf.setImage(with: imageURL)
        cell.status.text = requestList[indexPath.row].status
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if requestSegmentControl.selectedSegmentIndex == 2 {
            //segue to confirmation page
        } else {
            self.performSegue(withIdentifier: "Show Request Detail", sender: self)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
