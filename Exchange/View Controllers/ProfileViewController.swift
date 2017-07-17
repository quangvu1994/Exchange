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
    let options = ["Personal Info", "Your Request"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
        hideKeyboardOnTap()
        username.text = User.currentUser.username
    }
    
    func configuration() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // Round profile picture
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
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
        default:
            fatalError("Unrecognized index path")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
