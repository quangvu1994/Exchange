//
//  SignupViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/22/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        getStartedButton.layer.cornerRadius = 3
        phoneNumber.delegate = self
        username.delegate = self
        backgroundImage.image = resizeImage(image: UIImage(named: "Connect")!, newWidth: 1000)
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
    
    @IBAction func getStartedAction(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let user = Auth.auth().currentUser,
            let username = username.text,
            let phoneNumber = phoneNumber.text,
            !username.isEmpty,
            !phoneNumber.isEmpty else {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayWarningMessage(message: "Please fill out all information")
                return
        }
        
        activityIndicator.startAnimating()
        UserService.createNewUser(user, phoneNumber: phoneNumber, username: username, completion: { [unowned self] (user) in
            // Making sure that we do have our User
            guard let user = user else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            User.setCurrentUser(user, writeToUserDefaults: true)
            let initialViewController = UIStoryboard.initialViewController(type: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        performSegue(withIdentifier: "Cancel Signup", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Cancel Signup" {
                do {
                    try Auth.auth().signOut()
                    if Auth.auth().currentUser == nil {
                        FBSDKLoginManager().logOut()
                    } else {
                        print("Handle failed to sign out here")
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension SignupViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        
        if textField == phoneNumber {
            let maxCharacter = 10
            guard let currText = textField.text else  {return true}
            let newWordLength = currText.characters.count + string.characters.count - range.length
            return newWordLength <= maxCharacter
            
        } else {
            let maxCharacter = 20
            guard let currText = textField.text else  {return true}
            let newWordLength = currText.characters.count + string.characters.count - range.length
            return newWordLength <= maxCharacter
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumber {
            guard let number = phoneNumber.text else {
                return
            }
            
            if number.characters.count != 10 {
                phoneNumber.text = ""
            }
        }
    }
    
}
