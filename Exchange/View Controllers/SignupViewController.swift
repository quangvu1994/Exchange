//
//  SignupViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/22/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if !getStartedButton.isEnabled {
            getStartedButton.alpha = 0.5
        } else {
            getStartedButton.alpha = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        getStartedButton.layer.cornerRadius = 3
        phoneNumber.delegate = self
        username.delegate = self
    }
    
    @IBAction func getStartedAction(_ sender: UIButton) {
        
        guard let user = Auth.auth().currentUser,
            let username = username.text,
            let phoneNumber = phoneNumber.text else {
            return
        }
        
        UserService.createNewUser(user, phoneNumber: phoneNumber, username: username, completion: { (user) in
            // Making sure that we do have our User
            guard let user = user else {
                return
            }
            User.setCurrentUser(user, writeToUserDefaults: true)
            let initialViewController = UIStoryboard.initialViewController(type: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        })
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
                let alertController = UIAlertController(title: nil, message: "Incorrect phone number", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                phoneNumber.text = nil
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Enable if user has filled out everything
        if phoneNumber.text != "" && username.text != "" {
            self.getStartedButton.isEnabled = true
            self.getStartedButton.alpha = 1.0
        } else {
            self.getStartedButton.isEnabled = false
            self.getStartedButton.alpha = 0.5
        }
    }
    
}
