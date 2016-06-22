//
//  LoginViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let loginManager = LoginManager.sharedInstance
    var currentuser = BackendlessUser()
    
    @IBOutlet private weak var emailTextField     :UITextField!
    @IBOutlet private weak var passwordTextField  :UITextField!
    @IBOutlet private weak var signupButton       :UIButton!
    @IBOutlet private weak var loginButton        :UIButton!
    
    //MARK: - Login Methods
    
    @IBAction private func signUpUser(button: UIButton) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        loginManager.signUpNewUser(email, password: password)
        blankFields()
    }
    
    @IBAction private func loginUser() {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        loginManager.loginUserFunc(email, password: password)
        blankFields()
    }
    
    func segueToViews() {
            print("Email: \(self.loginManager.currentuser.email), UserID: \(self.loginManager.currentuser.objectId)")
            print("user  has signed in")
            performSegueWithIdentifier("loggedIn", sender: currentuser)
    }
    
    //MARK: - Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            loginUser()
        default:
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
        return true
    }

    
    //MARK: - Basic Validation Functions
    
    @IBAction private func textFieldChanged() {
        signupButton.enabled = false
        loginButton.enabled = false
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        if isValidLogin(email, password: password) {
            signupButton.enabled = true
            loginButton.enabled = true
        }
    }
    
    private func isValidLogin (email: String, password: String) -> Bool {
        return email.characters.count > 5 && email.characters.contains("@") && password.characters.count > 4
    }
    
    private func blankFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        emailTextField.text = "cookepa1@gmail.com"
//        passwordTextField.text = "password"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(segueToViews), name: "recvLoginInfo", object: nil)
        emailTextField.becomeFirstResponder()
        textFieldChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
