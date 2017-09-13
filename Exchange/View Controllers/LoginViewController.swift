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
import GoogleSignIn
import OneSignal

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var homeBackground: UIImageView!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginButtons()
        homeBackground.image = resizeImage(image: UIImage(named: "HomeScreen")!, newWidth: 1200)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func configureLoginButtons() {
        facebookLoginButton.layer.masksToBounds = true
        googleLoginButton.layer.masksToBounds = true
        facebookLoginButton.layer.cornerRadius = 6
        googleLoginButton.layer.cornerRadius = 6
    }
    
    /**
     Resize an image to the new specific size
     */
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func unwindToLoginView(_ sender: UIStoryboardSegue) {
        // Do nothing
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        facebookLoginButton.alpha = 0.8
        googleLoginButton.alpha = 0.8
        if let _ = error {
            self.activityIndicator.stopAnimating()
            self.facebookLoginButton.alpha = 1
            self.googleLoginButton.alpha = 1
            UIApplication.shared.endIgnoringInteractionEvents()
            let initialViewController = UIStoryboard.initialViewController(type: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: { (currentFIRAuthUser, error) in
            if let error = error {
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            guard let currentFIRAuthUser = currentFIRAuthUser else {
                self.activityIndicator.stopAnimating()
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            // Check to rsee if our database has this user
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
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        })
    }
    
    @IBAction func googleLoginAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        // Start the activity indicator
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        facebookLoginButton.alpha = 0.8
        googleLoginButton.alpha = 0.8
        // Initialize facebook login manager
        let fbManager = FBSDKLoginManager()
        fbManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            guard let result = result else {
                self.displayWarningMessage(message: "Fail to login")
                self.activityIndicator.stopAnimating()
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
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
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            if let error = error {
                assertionFailure("Failed to login \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            // Grab the Faebook access token
            guard let accessToken = FBSDKAccessToken.current() else {
                assertionFailure("Failed to retrieve Facebook access token")
                self.activityIndicator.stopAnimating()
                self.facebookLoginButton.alpha = 1
                self.googleLoginButton.alpha = 1
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
                    self.facebookLoginButton.alpha = 1
                    self.googleLoginButton.alpha = 1
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                // Make sure that user has logged in
                guard let currentFIRAuthUser = currentFIRAuthUser else {
                    self.activityIndicator.stopAnimating()
                    self.facebookLoginButton.alpha = 1
                    self.googleLoginButton.alpha = 1
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
                    self.facebookLoginButton.alpha = 1
                    self.googleLoginButton.alpha = 1
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
        }
    }
}

