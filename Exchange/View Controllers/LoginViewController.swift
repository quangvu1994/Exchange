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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginButtons()
    }
    
    func configureLoginButtons() {
        facebookLoginButton.layer.cornerRadius = 6
    }
    
    @IBAction func unwindToLoginView(_ sender: UIStoryboardSegue) {
        print("Back to login")
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        // Start the activity indicator
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        // Initialize facebook login manager
        let fbManager = FBSDKLoginManager()
        fbManager.loginBehavior = .browser
        fbManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            guard let result = result else {
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            // If canceled, bring user back to main screen
            if result.isCancelled {
                // Transfer them to the main view
                let initialViewController = UIStoryboard.initialViewController(type: .login)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            if let error = error {
                assertionFailure("Failed to login \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            // Grab the Faebook access token
            guard let accessToken = FBSDKAccessToken.current() else {
                assertionFailure("Failed to retrieve Facebook access token")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
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
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                // Make sure that user has logged in
                guard let currentFIRAuthUser = currentFIRAuthUser else {
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                
                // Check to see if our database has this user
                UserService.retrieveUser(currentFIRAuthUser.uid, completion: { (userFromOurDatabase) in
                    // If we doesn't have an user, write the current user to the database
                    if let user = userFromOurDatabase {
                        User.setCurrentUser(user, writeToUserDefaults: true)
                        // Transfer them to the main view
                        let initialViewController = UIStoryboard.initialViewController(type: .main)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        self.performSegue(withIdentifier: "Show Sign Up", sender: nil)
                    }
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
        }
    }
}

