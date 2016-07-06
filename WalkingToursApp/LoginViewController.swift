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
    @IBOutlet weak var messageView              :UIView!
    @IBOutlet weak var messageLabel             :UILabel!
    
    //MARK: - Onscreen Alert Methods
    
    func fadeInMessageView(message : String) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.messageLabel.text = message
            self.messageView.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOutMessageView() {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.messageView.alpha = 0.0
                }, completion: nil)
        })
    }
    
    func loginfailed() {
        messageLabel.text = "Logged Failed"
        fadeOutMessageView()
    }
    
    func signUpSuccess() {
        messageLabel.text = "Account Created"
        fadeOutMessageView()
    }
    
    func signUpFailed() {
        messageLabel.text = "Error: Account Not Created"
        fadeOutMessageView()
    }
    
    //MARK: - Login Methods
    
    @IBAction private func signUpUser(button: UIButton) {
        fadeInMessageView("Creating Account")
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
        fadeInMessageView("Signing In")
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        loginManager.loginUserFunc(email, password: password)
        blankFields()
    }
    
    @IBAction private func logoutUser() {
        Types.tryblock({ () -> Void in
            self.loginManager.backendless.userService.logout()
//            print("User logged out")
            },
                       catchblock: { (exception) -> Void in
//                        print("Server reported an error: \(exception as! Fault)")
        })
    }
    
    func segueToViews() {
        performSegueWithIdentifier("loggedIn", sender: currentuser)
        fadeOutMessageView()
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
        messageView.alpha = 0.0
        emailTextField.text = "cookepa1@gmail.com"
        passwordTextField.text = "password"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(segueToViews), name: "recvLoginInfo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginfailed), name: "loginInFailed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpSuccess), name: "signUpSuccess", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpFailed), name: "signUpFailed", object: nil)
        emailTextField.becomeFirstResponder()
        textFieldChanged()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        messageView.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
