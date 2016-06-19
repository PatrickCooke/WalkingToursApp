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
//    var userInfoManager = UserInfoManager.sharedInstance
    
    func signUpNewUser(email: String, password: String) {
        let user = BackendlessUser()
        user.email = email
        user.password = password
        backendless.userService.registering(user, response: { (registeredUser) in
            print("Success Registering \(registeredUser.email)")
        }) { (error) in
            print("error registering \(error)")
        }
    }
    
    func loginUserFunc(email: String, password: String) {
        backendless.userService.login(email, password: password, response: { (loggedInUser) in
            print("Logged In \(loggedInUser.email)")
            self.currentuser = loggedInUser
            
//            self.userInfoManager.setUserInfo(self.currentuser.email, ownerId: self.currentuser.objectId)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvLoginInfo", object: nil))
        }) { (error) in
            print("LogIn Error: \(error)")
        }
        
    }
    
    
}
