//
//  ProfileViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/3/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    let options = ["Personal Info", "Outgoing Requests", "Incoming Requests"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
        username.text = User.currentUser.username
    }
    
    func configuration() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // Round profile picture
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2.0
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0).cgColor
        profilePicture.layer.borderWidth = 1.0
    }
    
    @IBAction func unwindToProfileView(_ sender: UIStoryboardSegue) {
        print("Unwinded")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Show Request" {
                let destination = segue.destination as! RequestViewController
                destination.index = tableView.indexPathForSelectedRow!.row
            }
        }
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileOptionCell
        cell.optionName.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "Show Profile Detail", sender: nil)
        case 1:
            self.performSegue(withIdentifier: "Show Request", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "Show Request", sender: nil)
        default:
            fatalError("Unrecognized index path")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
