//
//  LoginViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginButtons()
    }
    
    func configureLoginButtons() {
        facebookLoginButton.layer.cornerRadius = 6
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        // Initialize facebook login manager
        let fbManager = FBSDKLoginManager()
        fbManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                assertionFailure("Failed to login \(error.localizedDescription)")
                return
            }
            // Grab the Faebook access token
            guard let accessToken = FBSDKAccessToken.current() else {
                assertionFailure("Failed to retrieve Facebook access token")
                return
            }
            // Use the access token to create the Firebase Facebook credential
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform the sign in using Firebase Authentication

            Auth.auth().signIn(with: credential, completion: { (currentFIRAuthUser, error) in
                if let error = error {
                    // Present an alert if the user fail to login
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                // Handle any case if we don't have a firebase user yet
                guard let currentFIRAuthUser = currentFIRAuthUser else {
                    return
                }
                
                // Check to see if our database has this user
                UserService.retrieveUser(currentFIRAuthUser.uid, completion: { (userFromOurDatabase) in
                    // If we doesn't have an user, write the current user to the database
                    if let user = userFromOurDatabase {
                        User.setCurrentUser(user)
                    } else {
                        // Handle case if the user doesn't have a display name
                        guard let username = currentFIRAuthUser.displayName else {
                            return
                        }
                        
                        UserService.createNewUser(currentFIRAuthUser, username: username, completion: { (user) in
                            // Making sure that we do have our User
                            guard let user = user else {
                                return
                            }
                            User.setCurrentUser(user)
                        })
                    }
                    
                    // Transfer them to the main view
                    let initialViewController = UIStoryboard.initialViewController(type: .main)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                })
            })
        }
    }
}

