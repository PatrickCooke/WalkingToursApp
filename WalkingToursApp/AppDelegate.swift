//
//  AppDelegate.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let APP_ID = "264CD970-FFE4-9FD3-FF1E-539AE2DCE200"
    let SECRET_KEY = "A4893DA6-F33A-4CFF-FF77-B3D2768B2100"
    let VERSION_NUM = "v1"
    
    var backendless = Backendless.sharedInstance()

    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        UINavigationBar.appearance().barTintColor = UIColor().BeccaBlue()
        UINavigationBar.appearance().tintColor = UIColor().backgroundGrey()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor().backgroundGrey() ]
        return true
    }

}

