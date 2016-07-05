//
//  LoginManager.swift
//  ApartmentMGR-Homework
//
//  Created by Patrick Cooke on 5/18/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class LoginManager: NSObject {
    static let sharedInstance = LoginManager()
    
    let backendless = Backendless.sharedInstance()
    var currentuser = BackendlessUser()
    
    func signUpNewUser(email: String, password: String) {
        let user = BackendlessUser()
        user.email = email
        user.password = password
        backendless.userService.registering(user, response: { (registeredUser) in
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "signUpSuccess", object: nil))
        }) { (error) in
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "signUpFailed", object: nil))
        }
    }
    
    func loginUserFunc(email: String, password: String) {
        backendless.userService.login(email, password: password, response: { (loggedInUser) in
            self.currentuser = loggedInUser
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvLoginInfo", object: nil))
        }) { (error) in
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "loginInFailed", object: nil))
        }
    }
    
}
