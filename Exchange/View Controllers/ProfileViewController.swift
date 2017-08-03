//
//  ProfileViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/3/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    let options = ["Outgoing Requests", "Incoming Requests", "Log Out"]
    var photoHelper = EXPhotoHelper()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = true
        // If there is profile picture -> set it
        if let profilePictureURL = User.currentUser.profilePictureURL {
            profilePicture.contentMode = .scaleAspectFill
            profilePicture.kf.setImage(with: URL(string: profilePictureURL))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
        username.text = User.currentUser.username
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.openPhotoPicker)))
        
        // Handle taken picture
        photoHelper.completionHandler = { [weak self] (image) in
            self?.profilePicture.contentMode = .scaleAspectFill
            self?.profilePicture.image = image
            // Store image on Firebase Storage
            guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
                return
            }
            
            let ref = FIRStorageUtilities.constructReferencePath()
            ref.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return
                }
                
                guard let downloadURL = metaData?.downloadURL() else {
                    return
                }
                
                let imageURL = downloadURL.absoluteString
                
                // Store the profile picture on FIRDatabase and update user default
                let userRef = Database.database().reference().child("users/\(User.currentUser.uid)/profilePicture")
                userRef.setValue(imageURL)
                
                // Update user default
                User.currentUser.profilePictureURL = imageURL
                User.setCurrentUser(User.currentUser, writeToUserDefaults: true)
            })
            
        }
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
    
    func openPhotoPicker() {
        photoHelper.presentActionSheet(from: self)
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
        if indexPath.row == 3 {
            cell.accessoryType = .none
        }
        cell.optionName.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "Show Request", sender: nil)
        case 1:
            self.performSegue(withIdentifier: "Show Request", sender: nil)
        case 2:
            // Handle log out
            let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    if Auth.auth().currentUser == nil {
                        FBSDKLoginManager().logOut()
                        let initialViewController = UIStoryboard.initialViewController(type: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        print("Handle failed to sign out here")
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            })
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)

        default:
            fatalError("Unrecognized index path")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
